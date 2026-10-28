import 'package:get/get.dart';
import 'package:project/welcome/data/datasources/welcome_local_datasource.dart';
import 'package:project/welcome/data/repositories/welcome_repository_impl.dart';
import 'package:project/welcome/domain/repositories/welcome_repository.dart';
import 'package:project/welcome/domain/usecases/complete_onboarding_usecase.dart';
import 'package:project/welcome/domain/usecases/is_onboarding_seen_usecase.dart';
import 'package:project/welcome/presentation/controllers/onboarding_controller.dart';
import 'package:project/welcome/presentation/controllers/role_choice_controller.dart';
import 'package:project/welcome/presentation/controllers/splash_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Binding واحد للشاشات الثلاث (Splash / Onboarding / RoleChoice).
class WelcomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WelcomeLocalDataSource>(
          () => WelcomeLocalDataSourceImpl(Get.find<SharedPreferences>()),
      fenix: true,
    );
    Get.lazyPut<WelcomeRepository>(
          () => WelcomeRepositoryImpl(Get.find()),
      fenix: true,
    );
    Get.lazyPut(() => IsOnboardingSeenUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => CompleteOnboardingUseCase(Get.find()), fenix: true);

    Get.lazyPut(() => SplashController(Get.find()));
    Get.lazyPut(() => OnboardingController(Get.find()));
    Get.lazyPut(() => RoleChoiceController());
  }
}