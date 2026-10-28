import 'package:get/get.dart';
import 'package:project/core/routes/app_routes.dart';

class CartController extends GetxController {
  final deliveryType = 0.obs; // 0: حسب العنوان, 1: استلام من المركز

  void proceedToDelivery() {
    Get.toNamed(CustomerRoutes.addresses);
  }
}
