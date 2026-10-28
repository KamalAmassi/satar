import 'package:get/get.dart';
import 'package:project/core/routes/app_routes.dart';
import 'package:project/core/utils/usecase.dart';
import 'package:project/welcome/domain/usecases/is_onboarding_seen_usecase.dart';

class SplashController extends GetxController {
  SplashController(this._isOnboardingSeen);

  final IsOnboardingSeenUseCase _isOnboardingSeen;

  final isLoading = false.obs;

  Future<void> onContinue() async {
    if (isLoading.value) return;
    isLoading.value = true;

    final result = await _isOnboardingSeen(const NoParams());
    final seen = result.getOrElse(() => false);

    isLoading.value = false;
    Get.offNamed(seen ? SharedRoutes.roleChoice : SharedRoutes.onboarding);
  }
}