import 'package:get/get.dart';
import 'package:project/core/routes/app_routes.dart';

class OrdersController extends GetxController {
  final currentTab = 1.obs;
  final currentSegment = 0.obs;

  void changeNavTab(int index) {
    currentTab.value = index;
    if (index == 0) {
      Get.offAllNamed(CustomerRoutes.home);
    } else if (index == 2) {
      Get.toNamed(CustomerRoutes.categories);
    }
  }

  void goToOrderDetails() {
    Get.toNamed(CustomerRoutes.orderDetails);
  }
}
