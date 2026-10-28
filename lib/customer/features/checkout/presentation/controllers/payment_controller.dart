import 'package:get/get.dart';
import 'package:project/core/routes/app_routes.dart';

class PaymentController extends GetxController {
  void submitPayment() {
    Get.toNamed(CustomerRoutes.orders);
  }
}
