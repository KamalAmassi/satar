import 'package:get/get.dart';
import 'package:project/core/routes/app_routes.dart';
import 'package:project/customer/features/cart/presentation/bindings/cart_binding.dart';
import 'package:project/customer/features/cart/presentation/views/cart_view.dart';
import 'package:project/customer/features/printing/presentation/bindings/printing_binding.dart';
import 'package:project/customer/features/printing/presentation/views/print_specs_view.dart';
import 'package:project/customer/features/printing/presentation/views/printing_landing_view.dart';

/// صفحات مسار الشراء (حلا): الطباعة والسلة.
abstract final class PurchasingPages {
  static const routes = {
    CustomerRoutes.printing,
    CustomerRoutes.printPreview,
    CustomerRoutes.cart,
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
      ];
}
