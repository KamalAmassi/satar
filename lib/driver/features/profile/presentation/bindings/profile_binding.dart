import 'package:get/get.dart';
import 'package:project/driver/features/profile/presentation/controllers/profile_controller.dart';

class DriverProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverProfileController>(
      () => DriverProfileController(logoutDriverUseCase: Get.find()),
    );
  }
}
