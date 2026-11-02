import 'package:get/get.dart';
import 'package:project/core/routes/app_routes.dart';
import 'package:project/driver/features/auth/domain/usecases/logout_driver_usecase.dart';
import 'package:project/driver/features/home/presentation/controllers/driver_session_controller.dart';
import 'package:project/driver/shared/driver_models.dart';

class DriverProfileController extends GetxController {
  DriverProfileController({required this.logoutDriverUseCase});

  final LogoutDriverUseCase logoutDriverUseCase;

  final isLoggingOut = false.obs;

  Rxn<Driver> get profile => Get.find<DriverSessionController>().profile;

  Future<void> logout() async {
    if (isLoggingOut.value) return;
    isLoggingOut.value = true;
    // المستودع يمسح التوكن محلياً حتى لو فشل الاتصال.
    await logoutDriverUseCase.call();
    isLoggingOut.value = false;
    Get.offAllNamed(DriverRoutes.login);
  }

  void openHistory() => Get.toNamed(DriverRoutes.tasksHistory);
  void openEarnings() => Get.toNamed(DriverRoutes.earningsCash);
  void openNotifications() => Get.toNamed(DriverRoutes.notifications);
}
