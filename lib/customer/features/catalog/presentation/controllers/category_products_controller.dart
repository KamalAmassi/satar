import 'package:get/get.dart';
import 'package:project/core/routes/app_routes.dart';

class CategoryProductsController extends GetxController {
  final categoryName = 'قرطاسية'.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      categoryName.value = Get.arguments.toString();
    }
  }

  void goToProductDetails() {
    Get.toNamed(CustomerRoutes.productDetails);
  }

  void goToSearch() {
    Get.toNamed(CustomerRoutes.search);
  }
}
