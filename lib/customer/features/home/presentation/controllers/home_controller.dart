import 'package:get/get.dart';
import 'package:project/core/routes/app_routes.dart';

class CustomerHomeController extends GetxController {
  final currentTab = 0.obs;

  void changeTab(int index) {
    currentTab.value = index;
    if (index == 1) {
      Get.toNamed(CustomerRoutes.orders);
    } else if (index == 2) {
      Get.toNamed(CustomerRoutes.categories);
    }
  }
}
