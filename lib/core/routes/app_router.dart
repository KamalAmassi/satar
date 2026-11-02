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
import 'package:project/customer/features/checkout/presentation/views/payment_correction_view.dart';
import 'package:project/customer/features/checkout/presentation/views/payment_review_view.dart';
import 'package:project/customer/features/checkout/presentation/views/payment_approved_view.dart';
import 'package:project/customer/features/orders/presentation/views/orders_view.dart';
import 'package:project/customer/features/orders/presentation/views/order_details_view.dart';
import 'package:project/customer/features/tracking/presentation/views/live_tracking_view.dart';
import 'package:project/customer/features/tracking/presentation/views/cancel_order_view.dart';
import 'package:project/customer/features/tracking/presentation/views/rating_view.dart';
import 'package:project/customer/features/tracking/presentation/views/share_tracking_view.dart';
import 'package:project/customer/features/tracking/presentation/views/public_tracking_view.dart';
import 'package:project/customer/features/notifications/presentation/views/notifications_view.dart';
import 'package:project/customer/features/orders/presentation/views/receipt_view.dart';
import 'package:project/customer/features/orders/presentation/views/activity_log_view.dart';
import 'package:project/customer/features/tracking/presentation/views/delivery_failure_view.dart';
import 'package:project/customer/features/tracking/presentation/views/assigning_driver_view.dart';
import 'package:project/customer/features/tracking/presentation/views/driver_unavailable_view.dart';
import 'package:project/customer/features/tracking/presentation/views/rating_error_view.dart';
import 'package:project/customer/features/tracking/presentation/views/share_link_ready_view.dart';
import 'package:project/customer/features/tracking/presentation/views/share_stopped_view.dart';

abstract final class AppRouter {
  static const initial = SharedRoutes.splash;

  static const _transition = Transition.cupertino; // يدعم RTL تلقائياً

  static final List<GetPage<dynamic>> pages = [
    ..._shared,
    GetPage(name: CustomerRoutes.login, page: () => const LoginView(), transition: _transition),
    GetPage(name: CustomerRoutes.otp, page: () => const OtpView(), transition: _transition),
    GetPage(name: CustomerRoutes.completeProfile, page: () => const CompleteProfileView(), transition: _transition),
    GetPage(name: CustomerRoutes.success, page: () => const SuccessView(), transition: _transition),
    GetPage(name: CustomerRoutes.home, page: () => const HomeView(), transition: _transition),
    GetPage(name: CustomerRoutes.categories, page: () => const CategoriesView(), transition: _transition),
    GetPage(name: CustomerRoutes.products, page: () => const CategoryProductsView(), transition: _transition),
    GetPage(name: CustomerRoutes.search, page: () => const SearchView(), transition: _transition),
    GetPage(name: CustomerRoutes.searchResults, page: () => const SearchResultsView(), transition: _transition),
    GetPage(name: CustomerRoutes.productDetails, page: () => const ProductDetailsView(), transition: _transition),
    GetPage(name: CustomerRoutes.aiAssistant, page: () => const AiAssistantView(), transition: _transition),
    GetPage(name: CustomerRoutes.printing, page: () => const PrintingView(), transition: _transition),
    GetPage(name: CustomerRoutes.uploadFiles, page: () => const UploadFilesView(), transition: _transition),
    GetPage(name: CustomerRoutes.printSpecs, page: () => const PrintSpecsView(), transition: _transition),
    GetPage(name: CustomerRoutes.cart, page: () => const CartView(), transition: _transition),
    GetPage(name: CustomerRoutes.addresses, page: () => const AddressesView(), transition: _transition),
    GetPage(name: CustomerRoutes.offer, page: () => const OfferView(), transition: _transition),
    GetPage(name: CustomerRoutes.payment, page: () => const PaymentView(), transition: _transition),
    GetPage(name: CustomerRoutes.paymentCorrection, page: () => const PaymentCorrectionView(), transition: _transition),
    GetPage(name: CustomerRoutes.paymentReview, page: () => const PaymentReviewView(), transition: _transition),
    GetPage(name: CustomerRoutes.paymentApproved, page: () => const PaymentApprovedView(), transition: _transition),
    GetPage(name: CustomerRoutes.orders, page: () => const OrdersView(), transition: _transition),
    GetPage(name: CustomerRoutes.orderDetails, page: () => const OrderDetailsView(), transition: _transition),
    GetPage(name: CustomerRoutes.liveTracking, page: () => const LiveTrackingView(), transition: _transition),
    GetPage(name: CustomerRoutes.cancelOrder, page: () => const CancelOrderView(), transition: _transition),
    GetPage(name: CustomerRoutes.rating, page: () => const RatingView(), transition: _transition),
    GetPage(name: CustomerRoutes.shareTracking, page: () => const ShareTrackingView(), transition: _transition),
    GetPage(name: CustomerRoutes.publicTracking, page: () => const PublicTrackingView(), transition: _transition),
    GetPage(name: CustomerRoutes.notifications, page: () => const NotificationsView(), transition: _transition),
    GetPage(name: CustomerRoutes.receipt, page: () => const ReceiptView(), transition: _transition),
    GetPage(name: CustomerRoutes.activityLog, page: () => const ActivityLogView(), transition: _transition),
    GetPage(name: CustomerRoutes.deliveryFailure, page: () => const DeliveryFailureView(), transition: _transition),
    GetPage(name: CustomerRoutes.assigningDriver, page: () => const AssigningDriverView(), transition: _transition),
    GetPage(name: CustomerRoutes.driverUnavailable, page: () => const DriverUnavailableView(), transition: _transition),
    GetPage(name: CustomerRoutes.ratingError, page: () => const RatingErrorView(), transition: _transition),
    GetPage(name: CustomerRoutes.shareLinkReady, page: () => const ShareLinkReadyView(), transition: _transition),
    GetPage(name: CustomerRoutes.shareStopped, page: () => const ShareStoppedView(), transition: _transition),
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
          CustomerRoutes.paymentCorrection,
          CustomerRoutes.paymentReview,
          CustomerRoutes.paymentApproved,
          CustomerRoutes.orders,
          CustomerRoutes.orderDetails,
          CustomerRoutes.liveTracking,
          CustomerRoutes.cancelOrder,
          CustomerRoutes.rating,
          CustomerRoutes.shareTracking,
          CustomerRoutes.publicTracking,
          CustomerRoutes.notifications,
          CustomerRoutes.receipt,
          CustomerRoutes.activityLog,
          CustomerRoutes.deliveryFailure,
          CustomerRoutes.assigningDriver,
          CustomerRoutes.driverUnavailable,
          CustomerRoutes.ratingError,
          CustomerRoutes.shareLinkReady,
          CustomerRoutes.shareStopped,
        ].contains(r)))
      _placeholder(route),
    for (final route in DriverRoutes.all) _placeholder(route),
  ];

  static final List<GetPage<dynamic>> _shared = [
    GetPage(
      name: SharedRoutes.splash,
      page: () => const SplashView(),
      binding: WelcomeBinding(),
      transition: Transition.fade,
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
