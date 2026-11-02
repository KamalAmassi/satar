import 'package:get/get.dart';
import 'package:project/core/routes/app_routes.dart';
import 'package:project/core/widgets/placeholder_view.dart';
import 'package:project/driver/features/auth/presentation/bindings/auth_binding.dart';
import 'package:project/driver/features/auth/presentation/views/login_view.dart';
import 'package:project/driver/features/current_task/presentation/bindings/current_task_binding.dart';
import 'package:project/driver/features/current_task/presentation/views/pickup_confirmation_view.dart';
import 'package:project/driver/features/delivery_confirmation/presentation/bindings/delivery_binding.dart';
import 'package:project/driver/features/delivery_confirmation/presentation/views/delivery_confirmation_view.dart';
import 'package:project/driver/features/delivery_confirmation/presentation/views/delivery_success_view.dart';
import 'package:project/driver/features/delivery_failure/presentation/bindings/delivery_failure_binding.dart';
import 'package:project/driver/features/delivery_failure/presentation/views/delivery_failure_view.dart';
import 'package:project/driver/features/delivery_failure/presentation/views/failure_recorded_view.dart';
import 'package:project/driver/features/earnings_cash/presentation/bindings/earnings_cash_binding.dart';
import 'package:project/driver/features/earnings_cash/presentation/views/earnings_cash_view.dart';
import 'package:project/driver/features/home/presentation/views/location_required_view.dart';
import 'package:project/driver/features/map_navigation/presentation/bindings/map_navigation_binding.dart';
import 'package:project/driver/features/map_navigation/presentation/views/map_navigation_view.dart';
import 'package:project/driver/features/notifications/presentation/bindings/notifications_binding.dart';
import 'package:project/driver/features/notifications/presentation/views/notifications_view.dart';
import 'package:project/driver/features/order_details/presentation/bindings/order_details_binding.dart';
import 'package:project/driver/features/order_details/presentation/views/order_details_view.dart';
import 'package:project/driver/features/order_details/presentation/views/task_details_view.dart';
import 'package:project/driver/features/tasks_history/presentation/bindings/tasks_history_binding.dart';
import 'package:project/driver/features/tasks_history/presentation/views/tasks_history_view.dart';
import 'package:project/driver/shell/driver_shell_binding.dart';
import 'package:project/driver/shell/driver_shell_view.dart';
import 'package:project/welcome/presentation/bindings/welcome_binding.dart';
import 'package:project/welcome/presentation/views/onboarding_view.dart';
import 'package:project/welcome/presentation/views/role_choice_view.dart';
import 'package:project/welcome/presentation/views/splash_view.dart';

abstract final class AppRouter {
  static const initial = SharedRoutes.splash;

  static const _transition = Transition.cupertino; // يدعم RTL تلقائياً

  static final List<GetPage<dynamic>> pages = [
    ..._shared,
    ..._driver,
    for (final route in CustomerRoutes.all) _placeholder(route),
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

  static final List<GetPage<dynamic>> _driver = [
    GetPage(
      name: DriverRoutes.login,
      page: () => const DriverLoginView(),
      binding: DriverAuthBinding(),
      transition: _transition,
    ),
    // الـ shell: 4 تابات (الرئيسية / المتاح / المهمة / حسابي).
    GetPage(
      name: DriverRoutes.home,
      page: () => const DriverShellView(),
      binding: DriverShellBinding(),
      transition: Transition.fadeIn,
    ),
    // مسارات قديمة تفتح نفس الـ shell (للتوافق).
    GetPage(
      name: DriverRoutes.availableOrders,
      page: () => const DriverShellView(),
      binding: DriverShellBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: DriverRoutes.currentTask,
      page: () => const DriverShellView(),
      binding: DriverShellBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: DriverRoutes.profile,
      page: () => const DriverShellView(),
      binding: DriverShellBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: DriverRoutes.orderDetails,
      page: () => const DriverOrderDetailsView(),
      binding: DriverOrderDetailsBinding(),
      transition: _transition,
    ),
    GetPage(
      name: DriverRoutes.taskDetails,
      page: () => const DriverTaskDetailsView(),
      binding: DriverTaskDetailsBinding(),
      transition: _transition,
    ),
    GetPage(
      name: DriverRoutes.pickupConfirmation,
      page: () => const DriverPickupConfirmationView(),
      binding: DriverPickupConfirmationBinding(),
      transition: _transition,
    ),
    GetPage(
      name: DriverRoutes.mapNavigation,
      page: () => const DriverMapNavigationView(),
      binding: DriverMapNavigationBinding(),
      transition: _transition,
    ),
    GetPage(
      name: DriverRoutes.deliveryConfirmation,
      page: () => const DriverDeliveryConfirmationView(),
      binding: DriverDeliveryBinding(),
      transition: _transition,
    ),
    GetPage(
      name: DriverRoutes.deliverySuccess,
      page: () => const DriverDeliverySuccessView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: DriverRoutes.deliveryFailure,
      page: () => const DriverDeliveryFailureView(),
      binding: DriverDeliveryFailureBinding(),
      transition: _transition,
    ),
    GetPage(
      name: DriverRoutes.failureRecorded,
      page: () => const DriverFailureRecordedView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: DriverRoutes.tasksHistory,
      page: () => const DriverTasksHistoryView(),
      binding: DriverTasksHistoryBinding(),
      transition: _transition,
    ),
    GetPage(
      name: DriverRoutes.earningsCash,
      page: () => const DriverEarningsCashView(),
      binding: DriverEarningsCashBinding(),
      transition: _transition,
    ),
    GetPage(
      name: DriverRoutes.notifications,
      page: () => const DriverNotificationsView(),
      binding: DriverNotificationsBinding(),
      transition: _transition,
    ),
    GetPage(
      name: DriverRoutes.locationRequired,
      page: () => const DriverLocationRequiredView(),
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
