import 'package:get/get.dart';
import 'package:get/get.dart';
import 'package:project/core/routes/app_routes.dart';
import 'package:project/core/widgets/placeholder_view.dart';
import 'package:project/welcome/presentation/bindings/welcome_binding.dart';
import 'package:project/welcome/presentation/views/onboarding_view.dart';
import 'package:project/welcome/presentation/views/role_choice_view.dart';
import 'package:project/welcome/presentation/views/splash_view.dart';
abstract final class AppRouter {
  static const initial = SharedRoutes.splash;

  static const _transition = Transition.cupertino; // يدعم RTL تلقائياً

  static final List<GetPage<dynamic>> pages = [
    ..._shared,
    for (final route in CustomerRoutes.all) _placeholder(route),
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