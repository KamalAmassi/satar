import 'package:get/get.dart';
import 'package:project/core/routes/app_routes.dart';
import 'package:project/customer/features/cart/presentation/bindings/cart_binding.dart';
import 'package:project/customer/features/cart/presentation/views/cart_view.dart';
import 'package:project/customer/features/checkout/presentation/bindings/checkout_binding.dart';
import 'package:project/customer/features/checkout/presentation/views/delivery_view.dart';
import 'package:project/customer/features/checkout/presentation/views/payment_method_view.dart';
import 'package:project/customer/features/checkout/presentation/views/quote_review_view.dart';
import 'package:project/customer/features/library_offer/presentation/bindings/offer_binding.dart';
import 'package:project/customer/features/library_offer/presentation/views/offer_view.dart';
import 'package:project/customer/features/payment/presentation/bindings/transfer_payment_binding.dart';
import 'package:project/customer/features/payment/presentation/views/transfer_payment_view.dart';
import 'package:project/customer/features/printing/presentation/bindings/printing_binding.dart';
import 'package:project/customer/features/printing/presentation/views/print_specs_view.dart';
import 'package:project/customer/features/printing/presentation/views/printing_landing_view.dart';

/// صفحات مسار الشراء (حلا): الطباعة، السلة، الدفع، التحويل، عرض المكتبة.
abstract final class PurchasingPages {
  static const routes = {
    CustomerRoutes.printing,
    CustomerRoutes.printPreview,
    CustomerRoutes.cart,
    CustomerRoutes.checkout,
    CustomerRoutes.paymentMethod,
    CustomerRoutes.priceReview,
    CustomerRoutes.payment,
    CustomerRoutes.offer,
  };

  static List<GetPage<dynamic>> pages({required Transition transition}) => [
        GetPage(
          name: CustomerRoutes.printing,
          page: () => const PrintingLandingView(),
          binding: PrintingBinding(),
          transition: transition,
        ),
        GetPage(
          name: CustomerRoutes.printPreview,
          page: () => const PrintSpecsView(),
          binding: PrintingBinding(),
          transition: transition,
        ),
        GetPage(
          name: CustomerRoutes.cart,
          page: () => const CartView(),
          binding: CartBinding(),
          transition: transition,
        ),
        GetPage(
          name: CustomerRoutes.checkout,
          page: () => const DeliveryView(),
          binding: CheckoutBinding(),
          transition: transition,
        ),
        GetPage(
          name: CustomerRoutes.paymentMethod,
          page: () => const PaymentMethodView(),
          binding: CheckoutBinding(),
          transition: transition,
        ),
        GetPage(
          name: CustomerRoutes.priceReview,
          page: () => const QuoteReviewView(),
          binding: CheckoutBinding(),
          transition: transition,
        ),
        GetPage(
          name: CustomerRoutes.payment,
          page: () => const TransferPaymentView(),
          binding: TransferPaymentBinding(),
          transition: transition,
        ),
        GetPage(
          name: CustomerRoutes.offer,
          page: () => const OfferView(),
          binding: OfferBinding(),
          transition: transition,
        ),
      ];
}
