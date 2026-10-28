import 'package:get/get.dart';
import 'package:project/core/routes/app_routes.dart';

class ProductDetailsController extends GetxController {
  final quantity = 1.obs;
  final selectedColor = 0.obs;
  final selectedExtras = <String>[].obs;
  final basePrice = 12.00.obs;

  double get totalPrice => (basePrice.value + (selectedExtras.length * 2.5)) * quantity.value;

  void increment() {
    quantity.value++;
  }

  void decrement() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }

  void toggleExtra(String extra) {
    if (selectedExtras.contains(extra)) {
      selectedExtras.remove(extra);
    } else {
      selectedExtras.add(extra);
    }
  }

  void addToCart() {
    Get.snackbar(
      'تمت الإضافة',
      'تم إضافة المنتج إلى السلة بنجاح',
      snackPosition: SnackPosition.BOTTOM,
    );
    Get.toNamed(CustomerRoutes.cart);
  }
}
