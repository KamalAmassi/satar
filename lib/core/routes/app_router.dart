import 'package:get/get.dart';
import 'package:project/core/routes/app_routes.dart';
import 'package:project/core/widgets/placeholder_view.dart';
import 'package:project/welcome/presentation/bindings/welcome_binding.dart';
import 'package:project/welcome/presentation/views/onboarding_view.dart';
import 'package:project/welcome/presentation/views/role_choice_view.dart';
import 'package:project/welcome/presentation/views/splash_view.dart';
import 'package:project/customer/features/auth/presentation/views/login_view.dart';
import 'package:project/customer/features/auth/presentation/views/otp_view.dart';
import 'package:project/customer/features/auth/presentation/views/complete_profile_view.dart';
import 'package:project/customer/features/auth/presentation/views/success_view.dart';
import 'package:project/customer/features/home/presentation/views/home_view.dart';
import 'package:project/customer/features/catalog/presentation/views/categories_view.dart';
import 'package:project/customer/features/catalog/presentation/views/category_products_view.dart';
import 'package:project/customer/features/catalog/presentation/views/search_view.dart';
import 'package:project/customer/features/catalog/presentation/views/search_results_view.dart';
import 'package:project/customer/features/catalog/presentation/views/product_details_view.dart';
import 'package:project/customer/features/ai_assistant/presentation/views/ai_assistant_view.dart';
import 'package:project/customer/features/printing/presentation/views/printing_view.dart';
import 'package:project/customer/features/printing/presentation/views/upload_files_view.dart';
import 'package:project/customer/features/printing/presentation/views/print_specs_view.dart';
import 'package:project/customer/features/cart/presentation/views/cart_view.dart';
import 'package:project/customer/features/addresses/presentation/views/addresses_view.dart';
import 'package:project/customer/features/orders/presentation/views/offer_view.dart';
import 'package:project/customer/features/checkout/presentation/views/payment_view.dart';
import 'package:project/customer/features/orders/presentation/views/orders_view.dart';
import 'package:project/customer/features/orders/presentation/views/order_details_view.dart';

abstract final class AppRouter {
  static const initial = SharedRoutes.splash;

  static const _transition = Transition.cupertino; // يدعم RTL تلقائياً

  static final List<GetPage<dynamic>> pages = [
    ..._shared,
    GetPage(
      name: CustomerRoutes.login,
      page: () => const LoginView(),
      transition: _transition,
    ),
    GetPage(
      name: CustomerRoutes.otp,
      page: () => const OtpView(),
      transition: _transition,
    ),
    GetPage(
      name: CustomerRoutes.completeProfile,
      page: () => const CompleteProfileView(),
      transition: _transition,
    ),
    GetPage(
      name: CustomerRoutes.success,
      page: () => const SuccessView(),
      transition: _transition,
    ),
    GetPage(
      name: CustomerRoutes.home,
      page: () => const HomeView(),
      transition: _transition,
    ),
    GetPage(
      name: CustomerRoutes.categories,
      page: () => const CategoriesView(),
      transition: _transition,
    ),
    GetPage(
      name: CustomerRoutes.products,
      page: () => const CategoryProductsView(),
      transition: _transition,
    ),
    GetPage(
      name: CustomerRoutes.search,
      page: () => const SearchView(),
      transition: _transition,
    ),
    GetPage(
      name: CustomerRoutes.searchResults,
      page: () => const SearchResultsView(),
      transition: _transition,
    ),
    GetPage(
      name: CustomerRoutes.productDetails,
      page: () => const ProductDetailsView(),
      transition: _transition,
    ),
    GetPage(
      name: CustomerRoutes.aiAssistant,
      page: () => const AiAssistantView(),
      transition: _transition,
    ),
    GetPage(
      name: CustomerRoutes.printing,
      page: () => const PrintingView(),
      transition: _transition,
    ),
    GetPage(
      name: CustomerRoutes.uploadFiles,
      page: () => const UploadFilesView(),
      transition: _transition,
    ),
    GetPage(
      name: CustomerRoutes.printSpecs,
      page: () => const PrintSpecsView(),
      transition: _transition,
    ),
    GetPage(
      name: CustomerRoutes.cart,
      page: () => const CartView(),
      transition: _transition,
    ),
    GetPage(
      name: CustomerRoutes.addresses,
      page: () => const AddressesView(),
      transition: _transition,
    ),
    GetPage(
      name: CustomerRoutes.offer,
      page: () => const OfferView(),
      transition: _transition,
    ),
    GetPage(
      name: CustomerRoutes.payment,
      page: () => const PaymentView(),
      transition: _transition,
    ),
    GetPage(
      name: CustomerRoutes.orders,
      page: () => const OrdersView(),
      transition: _transition,
    ),
    GetPage(
      name: CustomerRoutes.orderDetails,
      page: () => const OrderDetailsView(),
      transition: _transition,
    ),
    for (final route in CustomerRoutes.all.where((r) => ![
          CustomerRoutes.login,
          CustomerRoutes.otp,
          CustomerRoutes.completeProfile,
          CustomerRoutes.success,
          CustomerRoutes.home,
          CustomerRoutes.categories,
          CustomerRoutes.products,
          CustomerRoutes.search,
          CustomerRoutes.searchResults,
          CustomerRoutes.productDetails,
          CustomerRoutes.aiAssistant,
          CustomerRoutes.printing,
          CustomerRoutes.uploadFiles,
          CustomerRoutes.printSpecs,
          CustomerRoutes.cart,
          CustomerRoutes.addresses,
          CustomerRoutes.offer,
          CustomerRoutes.payment,
          CustomerRoutes.orders,
          CustomerRoutes.orderDetails,
        ].contains(r)))
      _placeholder(route),
    for (final route in DriverRoutes.all) _placeholder(route),
  ];

  static final List<GetPage<dynamic>> _shared = [
    GetPage(
      name: SharedRoutes.splash,
      page: () => const SplashView(),
      binding: WelcomeBinding(),
      transition: _transition,
    ),
    GetPage(
      name: SharedRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: WelcomeBinding(),
      transition: _transition,
    ),
    GetPage(
      name: SharedRoutes.roleChoice,
      page: () => const RoleChoiceView(),
      binding: WelcomeBinding(),
      transition: _transition,
    ),
  ];

  static GetPage<dynamic> get unknown => GetPage(
    name: '/not-found',
    page: () => const PlaceholderView(routeName: 'Not found'),
    transition: _transition,
  );

  static GetPage<dynamic> _placeholder(String name) => GetPage(
    name: name,
    page: () => PlaceholderView(routeName: name),
    transition: _transition,
  );
}
