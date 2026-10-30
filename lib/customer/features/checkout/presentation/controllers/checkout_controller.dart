import 'dart:async';

import 'package:get/get.dart';
import 'package:project/core/config/remote_config.dart';
import 'package:project/core/config/remote_config_repository.dart';
import 'package:project/core/errors/api_error_codes.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/storage/session_store.dart';
import 'package:project/core/utils/usecase.dart';
import 'package:project/customer/features/cart/presentation/controllers/cart_controller.dart';
import 'package:project/customer/features/checkout/domain/entities/checkout_address.dart';
import 'package:project/customer/features/checkout/domain/entities/checkout_details.dart';
import 'package:project/customer/features/checkout/domain/entities/order_submission.dart';
import 'package:project/customer/features/checkout/domain/entities/placed_order.dart';
import 'package:project/customer/features/checkout/domain/entities/quote.dart';
import 'package:project/customer/features/checkout/domain/entities/quote_draft.dart';
import 'package:project/customer/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:project/customer/features/checkout/domain/usecases/get_addresses_usecase.dart';
import 'package:project/customer/features/checkout/domain/usecases/place_order_usecase.dart';
import 'package:project/customer/features/checkout/domain/usecases/request_quote_usecase.dart';

enum QuoteState {
  idle,
  loading,
  ready,

  /// المدخلات تغيّرت بعد التسعيرة: يلزم تسعير جديد.
  stale,
  expired,
  used,
  failed,
}

enum SubmitState { idle, submitting, created, rejected, uncertain }

class CheckoutController extends GetxController {
  CheckoutController({
    required this.cart,
    required RemoteConfigRepository config,
    required SessionStore session,
    required CheckoutRepository repository,
    required GetAddressesUseCase getAddresses,
    required RequestQuoteUseCase requestQuote,
    required PlaceOrderUseCase placeOrder,
    DateTime Function()? clock,
  })  : _config = config,
        _session = session,
        _repository = repository,
        _getAddresses = getAddresses,
        _requestQuote = requestQuote,
        _placeOrder = placeOrder,
        _now = clock ?? DateTime.now;

  final CartController cart;
  final RemoteConfigRepository _config;
  final SessionStore _session;
  final CheckoutRepository _repository;
  final GetAddressesUseCase _getAddresses;
  final RequestQuoteUseCase _requestQuote;
  final PlaceOrderUseCase _placeOrder;
  final DateTime Function() _now;

  // ------------------------------------------------------------ details step
  final details = const CheckoutDetails().obs;
  final addresses = <CheckoutAddress>[].obs;
  final addressesLoading = false.obs;
  final addressesFailure = Rxn<Failure>();

  /// عناوين رفضها الخادم بـ out_of_zone أثناء التسعير.
  final outOfZoneAddressIds = <int>{}.obs;
  final remoteConfig = Rxn<RemoteConfig>();

  // -------------------------------------------------------------- quote step
  final quoteState = QuoteState.idle.obs;
  final quote = Rxn<Quote>();
  final quoteFailure = Rxn<Failure>();

  /// التسعيرة التي راجعها الزبون آخر مرة.
  final previousQuote = Rxn<Quote>();

  /// التسعيرة الحالية تختلف عن التي راجعها الزبون: يلزم قبول صريح.
  final needsPriceAcceptance = false.obs;

  /// تغيّرت طريقة الدفع منذ آخر مراجعة (التسعيرة أُعيد إصدارها لها).
  final paymentTermsChanged = false.obs;
  final remaining = Duration.zero.obs;

  // ------------------------------------------------------------- submission
  final submitState = SubmitState.idle.obs;
  final submitFailure = Rxn<Failure>();
  final createdOrder = Rxn<PlacedOrder>();
  OrderSubmission? _submission;

  int _quoteSeq = 0;
  Timer? _ticker;
  final List<Worker> _workers = [];

  @override
  void onInit() {
    super.onInit();
    _workers
      ..add(ever(cart.revision, (_) => _checkStale()))
      ..add(ever(details, (_) => _checkStale()));
  }

  Future<void> start() async {
    await cart.ensureLoaded();
    final guard = _session.guard();
    final configResult = await _config.load();
    if (!guard.isCurrent) return;
    configResult.fold((_) {}, (c) => remoteConfig.value = c);
    final userId = _session.userId;
    if (userId != null && _submission == null) {
      final pending = _repository.pendingSubmission(userId);
      if (pending != null) {
        _submission = pending;
        submitState.value = SubmitState.uncertain;
      }
    }
    await loadAddresses();
  }

  // ---------------------------------------------------------------- details

  Future<void> loadAddresses() async {
    addressesLoading.value = true;
    addressesFailure.value = null;
    final guard = _session.guard();
    final result = await _getAddresses(const NoParams());
    if (!guard.isCurrent) return;
    addressesLoading.value = false;
    result.fold((f) => addressesFailure.value = f, (list) {
      addresses.assignAll(list);
      final selected = details.value.addressId;
      if (selected == null || list.every((a) => a.id != selected)) {
        final preferred =
            list.where((a) => a.isDefault).firstOrNull ?? list.firstOrNull;
        if (preferred != null) selectAddress(preferred.id);
      }
    });
  }

  void selectAddress(int id) =>
      details.value = details.value.copyWith(addressId: id);

  void setRecipientName(String v) =>
      details.value = details.value.copyWith(recipientName: v);

  void setRecipientPhone(String v) =>
      details.value = details.value.copyWith(recipientPhone: v);

  void setDeliveryNotes(String v) =>
      details.value = details.value.copyWith(deliveryNotes: v);

  void setPaymentMethod(String method) =>
      details.value = details.value.copyWith(paymentMethod: method);

  /// رقم المستلم اختياري؛ إن وُجد يطابق نمط الإعداد.
  bool get isRecipientPhoneValid {
    final phone = details.value.recipientPhone.replaceAll(' ', '');
    if (phone.isEmpty) return true;
    final pattern = remoteConfig.value?.recipientPhonePattern ??
        RegExp(r'^\+?[0-9]{7,15}$');
    return pattern.hasMatch(phone);
  }

  bool get canContinueFromDelivery =>
      details.value.addressId != null &&
      !outOfZoneAddressIds.contains(details.value.addressId) &&
      isRecipientPhoneValid;

  List<String> get availablePaymentMethods {
    final c = remoteConfig.value;
    if (c == null) return const [];
    return [
      if (c.supportsCash) PaymentMethod.cash,
      if (c.supportsTransfer) PaymentMethod.transfer,
    ];
  }

  // ------------------------------------------------------------------ quote

  (QuoteDraft?, Set<DraftBlocker>) currentDraft() => QuoteDraft.build(
        products: cart.products.toList(),
        printJobs: cart.printJobs.toList(),
        substitutionPreference: cart.substitutionPreference.value,
        details: details.value,
      );

  Future<void> requestQuote() async {
    final (draft, blockers) = currentDraft();
    if (draft == null) {
      quoteState.value = QuoteState.failed;
      quoteFailure.value = null;
      return;
    }
    final seq = ++_quoteSeq;
    final guard = _session.guard();
    quoteState.value = QuoteState.loading;
    quoteFailure.value = null;
    final result = await _requestQuote(draft);
    // ردّ قديم (طلب أحدث أُرسل بعده) أو من جلسة سابقة: يُتجاهل.
    if (seq != _quoteSeq || !guard.isCurrent) return;
    result.fold(
      (failure) => _onQuoteFailure(failure, draft),
      (fresh) {
        cart.applyFieldErrors(
          productIndexToLineId: draft.productIndexToLineId,
          printIndexToJobId: draft.printIndexToJobId,
          fieldErrors: const {},
        );
        final reviewed = previousQuote.value;
        needsPriceAcceptance.value =
            reviewed != null && reviewed.pricesDifferFrom(fresh);
        paymentTermsChanged.value =
            reviewed != null && reviewed.paymentMethod != fresh.paymentMethod;
        if (!needsPriceAcceptance.value) previousQuote.value = fresh;
        quote.value = fresh;
        quoteState.value = QuoteState.ready;
        _startTicker();
      },
    );
  }

  void _onQuoteFailure(Failure failure, QuoteDraft draft) {
    quote.value = null;
    quoteFailure.value = failure;
    quoteState.value = QuoteState.failed;
    if (failure is ValidationFailure) {
      cart.applyFieldErrors(
        productIndexToLineId: draft.productIndexToLineId,
        printIndexToJobId: draft.printIndexToJobId,
        fieldErrors: failure.fieldErrors,
      );
    }
    if (failure.code == ApiErrorCodes.outOfZone) {
      final id = details.value.addressId;
      if (id != null) outOfZoneAddressIds.add(id);
    }
  }

  /// قبول السعر الجديد بعد تغيّره.
  void acceptNewPrice() {
    final q = quote.value;
    if (q == null) return;
    previousQuote.value = q;
    needsPriceAcceptance.value = false;
  }

  void _checkStale() {
    final q = quote.value;
    if (q == null || submitState.value == SubmitState.submitting) return;
    final (draft, _) = currentDraft();
    if (draft?.fingerprint != q.fingerprint) {
      quoteState.value = QuoteState.stale;
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _tick();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final q = quote.value;
    if (q == null) return _ticker?.cancel();
    remaining.value = q.remainingAt(_now());
    if (q.isExpiredAt(_now()) && quoteState.value == QuoteState.ready) {
      quoteState.value = QuoteState.expired;
      _ticker?.cancel();
    }
  }

  /// يمكن التأكيد فقط بتسعيرة صالحة، لنفس المحتوى، وتمت مراجعتها.
  bool get canConfirm {
    final q = quote.value;
    if (q == null || quoteState.value != QuoteState.ready) return false;
    if (needsPriceAcceptance.value || q.isExpiredAt(_now())) return false;
    final (draft, _) = currentDraft();
    return draft?.fingerprint == q.fingerprint &&
        submitState.value != SubmitState.submitting;
  }

  // ------------------------------------------------------------- submission

  Future<void> confirmOrder() async {
    if (submitState.value == SubmitState.submitting) return;
    if (!canConfirm) return;
    final q = quote.value!;
    final (draft, _) = currentDraft();
    if (_submission?.quoteToken != q.token) {
      _submission = OrderSubmission.start(
        quoteToken: q.token,
        note: cart.note.value,
        productRevisions: draft!.productRevisions,
        printRevisions: draft.printRevisions,
      );
    }
    await _send();
  }

  /// إعادة إرسال نفس المحاولة بنفس المفتاح ونفس الجسم للتحقق من النتيجة.
  Future<void> recheckSubmission() async {
    if (submitState.value == SubmitState.submitting || _submission == null) {
      return;
    }
    await _send();
  }

  Future<void> _send() async {
    final submission = _submission!;
    final userId = _session.userId;
    final guard = _session.guard();
    submitState.value = SubmitState.submitting;
    submitFailure.value = null;
    if (userId != null) {
      await _repository.savePendingSubmission(userId, submission);
    }
    final outcome = await _placeOrder(submission);
    if (!guard.isCurrent) return;
    switch (outcome) {
      case SubmitCreated(:final order):
        if (userId != null) {
          await _repository.savePendingSubmission(userId, null);
        }
        cart.removeSubmitted(
          productRevisions: submission.productRevisions,
          printRevisions: submission.printRevisions,
        );
        _submission = null;
        _ticker?.cancel();
        quote.value = null;
        previousQuote.value = null;
        paymentTermsChanged.value = false;
        quoteState.value = QuoteState.idle;
        createdOrder.value = order;
        submitState.value = SubmitState.created;
      case SubmitRejected(:final failure):
        await _onRejected(failure, userId);
      case SubmitUncertain(:final failure):
        submitFailure.value = failure;
        submitState.value = SubmitState.uncertain;
    }
  }

  Future<void> _onRejected(Failure failure, int? userId) async {
    submitFailure.value = failure;
    // 429: لم يُعالج الطلب؛ يمكن إعادة نفس المحاولة لاحقًا بنفس المفتاح.
    if (failure.code == ApiErrorCodes.tooManyRequests) {
      submitState.value = SubmitState.rejected;
      return;
    }
    if (userId != null) await _repository.savePendingSubmission(userId, null);
    _submission = null;
    submitState.value = SubmitState.rejected;
    switch (failure.code) {
      case ApiErrorCodes.quoteExpired:
        quoteState.value = QuoteState.expired;
      case ApiErrorCodes.quoteUsed:
        quoteState.value = QuoteState.used;
      case ApiErrorCodes.conflict:
        // quote_payload_mismatch: المحتوى لا يطابق التسعيرة.
        quoteState.value = QuoteState.stale;
      default:
        quote.value = null;
        quoteFailure.value = failure;
        quoteState.value = QuoteState.failed;
    }
  }

  /// بعد عرض حالة النجاح أو الانتقال لطلباتي.
  void resetAfterExit() {
    if (submitState.value == SubmitState.created) {
      submitState.value = SubmitState.idle;
      createdOrder.value = null;
    }
  }

  @override
  void onClose() {
    _ticker?.cancel();
    for (final w in _workers) {
      w.dispose();
    }
    super.onClose();
  }
}
