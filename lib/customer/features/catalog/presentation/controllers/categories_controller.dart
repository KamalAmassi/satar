import 'package:get/get.dart';
import 'package:project/core/routes/app_routes.dart';

class CategoriesController extends GetxController {
  final currentTab = 2.obs;

  void changeTab(int index) {
    currentTab.value = index;
    if (index == 0) {
      Get.offAllNamed(CustomerRoutes.home);
    } else if (index == 1) {
      Get.toNamed(CustomerRoutes.orders);
    }
  }

  void goToCategoryProducts(String categoryName) {
    Get.toNamed(CustomerRoutes.products, arguments: categoryName);
  }

  void goToSearch() {
    Get.toNamed(CustomerRoutes.search);
  }
}
