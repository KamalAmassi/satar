import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:project/core/l10n/app_localizations.dart';
import 'package:project/core/routes/app_routes.dart';
import 'package:project/customer/features/cart/presentation/controllers/cart_controller.dart';
import 'package:project/customer/features/checkout/domain/usecases/get_addresses_usecase.dart';
import 'package:project/customer/features/checkout/domain/usecases/place_order_usecase.dart';
import 'package:project/customer/features/checkout/domain/usecases/request_quote_usecase.dart';
import 'package:project/customer/features/checkout/presentation/controllers/checkout_controller.dart';
import 'package:project/customer/features/checkout/presentation/views/quote_review_view.dart';

import '../../helpers/purchasing_fakes.dart';

Widget _page(String name) => Scaffold(body: Text(name));

// Live sandbox case (STR-000026): system Back on "order created" went back to
// the payment method and delivery pages with an empty cart.
void main() {
  tearDown(Get.reset);

  testWidgets('system Back after the order is created leaves the purchase flow',
      (tester) async {
    final session = await signedInSession(userId: 1);
    final api = offlineApi(session);
    final cart = CartController(
        FakeCartRepository(), FakeUploadRepository(api), session);
    await cart.ensureLoaded();
    final repo = FakeCheckoutRepository();
    final checkout = Get.put(CheckoutController(
      cart: cart,
      config: FakeRemoteConfigRepository(api),
      session: session,
      repository: repo,
      getAddresses: GetAddressesUseCase(repo),
      requestQuote: RequestQuoteUseCase(repo),
      placeOrder: PlaceOrderUseCase(repo),
    ));
    checkout.createdOrder.value =
        orderFromJson(id: 76, status: 'awaiting_pricing', method: 'cash');
    checkout.submitState.value = SubmitState.created;

    await tester.pumpWidget(GetMaterialApp(
      locale: const Locale('ar'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      initialRoute: '/hub',
      getPages: [
        GetPage(name: '/hub', page: () => _page('/hub')),
        for (final r in [
          CustomerRoutes.cart,
          CustomerRoutes.checkout,
          CustomerRoutes.paymentMethod,
        ])
          GetPage(name: r, page: () => _page(r)),
        GetPage(
            name: CustomerRoutes.priceReview,
            page: () => const QuoteReviewView()),
      ],
    ));
    for (final r in [
      CustomerRoutes.cart,
      CustomerRoutes.checkout,
      CustomerRoutes.paymentMethod,
      CustomerRoutes.priceReview,
    ]) {
      Get.toNamed(r);
      await tester.pumpAndSettle();
    }

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('/hub'), findsOneWidget);
    expect(checkout.submitState.value, SubmitState.idle);
  });
}
