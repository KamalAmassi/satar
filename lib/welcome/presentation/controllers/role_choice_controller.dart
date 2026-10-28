import 'package:get/get.dart';
import 'package:project/core/routes/app_routes.dart';

class RoleChoiceController extends GetxController {
  void continueAsCustomer() => Get.toNamed(CustomerRoutes.login);

  void continueAsDriver() => Get.toNamed(DriverRoutes.login);
}