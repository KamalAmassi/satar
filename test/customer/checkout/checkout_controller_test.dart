import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:project/core/errors/api_error_codes.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/storage/session_store.dart';
import 'package:project/customer/features/cart/domain/entities/cart_product_line.dart';
import 'package:project/customer/features/cart/presentation/controllers/cart_controller.dart';
import 'package:project/customer/features/checkout/domain/entities/checkout_details.dart';
import 'package:project/customer/features/checkout/domain/entities/order_submission.dart';
import 'package:project/customer/features/checkout/domain/entities/quote_draft.dart';
import 'package:project/customer/features/checkout/domain/usecases/get_addresses_usecase.dart';
import 'package:project/customer/features/checkout/domain/usecases/place_order_usecase.dart';
import 'package:project/customer/features/checkout/domain/usecases/request_quote_usecase.dart';
import 'package:project/customer/features/checkout/presentation/controllers/checkout_controller.dart';

import '../../helpers/purchasing_fakes.dart';

void main() {
  late SessionStore session;
  late CartController cart;
  late FakeCheckoutRepository repo;
  late CheckoutController checkout;
  late DateTime now;

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  Future<QuoteDraft> quoteReady(
      {String token = 'qt_1',
      int total = 2800,
      String paymentMethod = 'cash'}) async {
    final call = checkout.requestQuote();
    final draft = repo.drafts.last;
    repo.quoteCalls.last.complete(
      Right(quoteFor(draft,
          token: token,
          total: total,
          receivedAt: now,
          paymentMethod: paymentMethod)),
    );
    await call;
    return draft;
  }

  setUp(() async {
    session = await signedInSession(userId: 1);
    final api = offlineApi(session);
    cart = CartController(
        FakeCartRepository(), FakeUploadRepository(api), session);
    await cart.ensureLoaded();
    repo = FakeCheckoutRepository();
    now = DateTime(2026, 10, 29, 12);
    checkout = Get.put(CheckoutController(
      cart: cart,
      config: FakeRemoteConfigRepository(api),
      session: session,
      repository: repo,
      getAddresses: GetAddressesUseCase(repo),
      requestQuote: RequestQuoteUseCase(repo),
      placeOrder: PlaceOrderUseCase(repo),
      clock: () => now,
    ));
    await checkout.start();
    cart.addProduct(const CartItemRequest(productId: 60, quantity: 1));
    checkout.setPaymentMethod(PaymentMethod.cash);
  });

  tearDown(Get.reset);

  test('default address is selected through the address contract', () {
    expect(checkout.details.value.addressId, 10);
  });

  group('quote body', () {
    test('sends product ids and option keys, never prices', () async {
      final draft = await quoteReady();
      final body = draft.body;
      expect(body['dropoff_address_id'], 10);
      expect(body['fields'], {'order_type': 'products'});
      expect(body['cart'], [
        {'product_id': 60, 'qty': 1},
      ]);
      expect(draft.fingerprint.contains('price'), isFalse);
      expect(body.containsKey('pickup'), isTrue);
    });

    test('order_type follows the real contents', () {
      expect(
          QuoteDraft.orderTypeFor(products: true, printing: false), 'products');
      expect(
          QuoteDraft.orderTypeFor(products: false, printing: true), 'printing');
      expect(QuoteDraft.orderTypeFor(products: true, printing: true), 'mixed');
    });

    test('an empty cart cannot be quoted (server would accept it)', () {
      final (draft, blockers) = QuoteDraft.build(
        products: const [],
        printJobs: const [],
        substitutionPreference: null,
        details: const CheckoutDetails(
            addressId: 1, paymentMethod: 'cash_on_delivery'),
      );
      expect(draft, isNull);
      expect(blockers, contains(DraftBlocker.emptyCart));
    });
  });

  group('quote invalidation', () {
    test('editing the cart makes the quote stale and blocks confirm', () async {
      await quoteReady();
      expect(checkout.canConfirm, isTrue);
      cart.setQuantity(cart.products.single.id, 2);
      await settle();
      expect(checkout.quoteState.value, QuoteState.stale);
      expect(checkout.canConfirm, isFalse);
    });

    test('changing delivery details makes the quote stale', () async {
      await quoteReady();
      checkout.setDeliveryNotes('Ring the bell');
      await settle();
      expect(checkout.quoteState.value, QuoteState.stale);
    });

    test('the order note does not invalidate the quote (sent at order time)',
        () async {
      await quoteReady();
      cart.setNote('Please wrap it');
      await settle();
      expect(checkout.canConfirm, isTrue);
    });

    test('an expired quote cannot be confirmed', () async {
      await quoteReady();
      now = now.add(const Duration(seconds: 600 - 10));
      expect(checkout.canConfirm, isFalse, reason: 'inside the safety margin');
    });

    test('a changed total requires explicit acceptance', () async {
      await quoteReady(total: 2000);
      cart.setQuantity(cart.products.single.id, 2);
      await quoteReady(token: 'qt_2', total: 2200);
      expect(checkout.needsPriceAcceptance.value, isTrue);
      expect(checkout.canConfirm, isFalse);
      checkout.acceptNewPrice();
      expect(checkout.canConfirm, isTrue);
    });

    // Live sandbox case: cash → transfer re-quoted at the same 40.00 and the
    // app showed "price changed" 40.00 → 40.00.
    test('changing only the payment method re-quotes without a price warning',
        () async {
      final cashDraft = await quoteReady(total: 4000);
      checkout.setPaymentMethod(PaymentMethod.transfer);
      await settle();
      expect(checkout.quoteState.value, QuoteState.stale,
          reason: 'the cash quote must not be used for a transfer order');

      final transferDraft = await quoteReady(
          token: 'qt_2', total: 4000, paymentMethod: 'bank_transfer');
      expect(transferDraft.fingerprint, isNot(cashDraft.fingerprint));
      expect(checkout.needsPriceAcceptance.value, isFalse);
      expect(checkout.paymentTermsChanged.value, isTrue);
      expect(checkout.canConfirm, isTrue);
      expect(checkout.quote.value!.token, 'qt_2');
    });

    test('a payment change that also changes the total still needs acceptance',
        () async {
      await quoteReady(total: 4000);
      checkout.setPaymentMethod(PaymentMethod.transfer);
      await settle();
      await quoteReady(
          token: 'qt_2', total: 4500, paymentMethod: 'bank_transfer');
      expect(checkout.needsPriceAcceptance.value, isTrue);
      expect(checkout.canConfirm, isFalse);
    });

    test('an older quote response arriving late is ignored', () async {
      final first = checkout.requestQuote();
      final firstDraft = repo.drafts.last;
      final second = checkout.requestQuote();
      final secondDraft = repo.drafts.last;
      repo.quoteCalls[1].complete(
          Right(quoteFor(secondDraft, token: 'new', receivedAt: now)));
      await second;
      repo.quoteCalls[0]
          .complete(Right(quoteFor(firstDraft, token: 'old', receivedAt: now)));
      await first;
      expect(checkout.quote.value!.token, 'new');
    });
  });

  group('order submission', () {
    test('uncertain result is rechecked with the same key and body', () async {
      await quoteReady();
      repo.outcomes.addAll([
        const SubmitUncertain(TimeoutFailure()),
        SubmitCreated(orderFromJson()),
      ]);
      await checkout.confirmOrder();
      expect(checkout.submitState.value, SubmitState.uncertain);
      expect(repo.pending[1], isNotNull,
          reason: 'kept for recovery after restart');

      await checkout.recheckSubmission();
      expect(repo.submissions, hasLength(2));
      expect(repo.submissions[0].idempotencyKey,
          repo.submissions[1].idempotencyKey);
      expect(repo.submissions[0].toBody(), repo.submissions[1].toBody());
      expect(checkout.submitState.value, SubmitState.created);
      expect(repo.pending[1], isNull);
    });

    test('5xx is uncertain, 4xx is a definite rejection', () {
      expect(
        SubmitOutcome.fromFailure(
            const ServerFailure(code: 'server_error', statusCode: 500)),
        isA<SubmitUncertain>(),
      );
      expect(SubmitOutcome.fromFailure(const NetworkFailure()),
          isA<SubmitUncertain>());
      expect(
        SubmitOutcome.fromFailure(
            const ServerFailure(code: 'quote_used', statusCode: 410)),
        isA<SubmitRejected>(),
      );
    });

    test('cart edits made during submission survive success', () async {
      await quoteReady();
      final submittedLine = cart.products.single.id;
      repo.outcomes.add(SubmitCreated(orderFromJson()));
      final future = checkout.confirmOrder();
      cart.addProduct(const CartItemRequest(productId: 61)); // added mid-flight
      await future;
      expect(cart.products.map((l) => l.productId), [61]);
      expect(cart.products.any((l) => l.id == submittedLine), isFalse);
    });

    test('a new quote gets a new idempotency key', () async {
      await quoteReady(token: 'qt_a');
      repo.outcomes.add(const SubmitRejected(
        ServerFailure(code: ApiErrorCodes.tooManyRequests, statusCode: 429),
      ));
      await checkout.confirmOrder();
      final firstKey = repo.submissions.single.idempotencyKey;

      repo.outcomes.add(const SubmitRejected(
        ServerFailure(code: ApiErrorCodes.tooManyRequests, statusCode: 429),
      ));
      await checkout.confirmOrder();
      expect(repo.submissions.last.idempotencyKey, firstKey,
          reason: 'same quote');

      cart.setQuantity(cart.products.single.id, 2);
      await quoteReady(token: 'qt_b');
      checkout.acceptNewPrice();
      repo.outcomes.add(SubmitCreated(orderFromJson()));
      await checkout.confirmOrder();
      expect(repo.submissions.last.idempotencyKey, isNot(firstKey));
    });

    test('quote_expired and quote_used map to their own states', () async {
      await quoteReady();
      repo.outcomes.add(const SubmitRejected(
        ServerFailure(code: ApiErrorCodes.quoteExpired, statusCode: 410),
      ));
      await checkout.confirmOrder();
      expect(checkout.quoteState.value, QuoteState.expired);

      await quoteReady(token: 'qt_2');
      repo.outcomes.add(const SubmitRejected(
        ServerFailure(code: ApiErrorCodes.quoteUsed, statusCode: 410),
      ));
      await checkout.confirmOrder();
      expect(checkout.quoteState.value, QuoteState.used);
    });

    test('a quote network failure shows the failed state and retry recovers',
        () async {
      final call = checkout.requestQuote();
      repo.quoteCalls.last.complete(const Left(NetworkFailure()));
      await call;
      expect(checkout.quoteState.value, QuoteState.failed);
      expect(checkout.quoteFailure.value, isA<NetworkFailure>());
      expect(checkout.canConfirm, isFalse);

      await quoteReady(token: 'qt_retry');
      expect(checkout.quoteState.value, QuoteState.ready);
      expect(checkout.quoteFailure.value, isNull);
    });

    // Stock fell below the cart quantity after the cart was filled (cannot be
    // triggered live without editing product stock on the dashboard).
    test('out_of_stock on quote fails without a quote and keeps the code',
        () async {
      cart.setQuantity(cart.products.single.id, 5);
      final call = checkout.requestQuote();
      repo.quoteCalls.last.complete(const Left(ServerFailure(
        code: ApiErrorCodes.outOfStock,
        statusCode: 422,
        details: {'product_id': 60, 'available': 3},
      )));
      await call;
      expect(checkout.quoteState.value, QuoteState.failed);
      expect(checkout.quote.value, isNull);
      expect(checkout.quoteFailure.value!.code, ApiErrorCodes.outOfStock);
      expect(checkout.canConfirm, isFalse);
    });

    test('out_of_zone remembers the address so it is marked in delivery',
        () async {
      final call = checkout.requestQuote();
      repo.quoteCalls.last.complete(const Left(ServerFailure(
        code: ApiErrorCodes.outOfZone,
        statusCode: 422,
      )));
      await call;
      expect(checkout.quoteState.value, QuoteState.failed);
      expect(checkout.outOfZoneAddressIds, contains(10));
    });

    test('a pending submission is restored as uncertain on start', () async {
      repo.pending[1] = OrderSubmission.start(quoteToken: 'qt_x', note: '');
      Get.reset();
      final api = offlineApi(session);
      final restored = CheckoutController(
        cart: cart,
        config: FakeRemoteConfigRepository(api),
        session: session,
        repository: repo,
        getAddresses: GetAddressesUseCase(repo),
        requestQuote: RequestQuoteUseCase(repo),
        placeOrder: PlaceOrderUseCase(repo),
      );
      await restored.start();
      expect(restored.submitState.value, SubmitState.uncertain);
    });
  });

  test('recipient phone uses the configured pattern', () {
    checkout.setRecipientPhone('abc');
    expect(checkout.isRecipientPhoneValid, isFalse);
    checkout.setRecipientPhone('0599 000 000');
    expect(checkout.isRecipientPhoneValid, isTrue);
    checkout.setRecipientPhone('');
    expect(checkout.isRecipientPhoneValid, isTrue);
  });
}
