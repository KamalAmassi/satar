import 'package:get/get.dart';
import 'package:project/core/routes/app_routes.dart';

class CustomerSuccessController extends GetxController {
  void continueToHome() {
    Get.offAllNamed(CustomerRoutes.home);
  }
}
