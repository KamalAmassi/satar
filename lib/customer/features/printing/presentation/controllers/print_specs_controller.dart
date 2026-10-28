import 'package:get/get.dart';
import 'package:project/core/routes/app_routes.dart';

class PrintSpecsController extends GetxController {
  final quantity = 2.obs;
  final selectedSize = 0.obs; // 0: A4, 1: A3, etc.
  final selectedColor = 0.obs; // 0: ملون, 1: أبيض وأسود
  final selectedType = 0.obs; // 0: وجهان, 1: وجه واحد
  final selectedBinding = 0.obs; // 0: تجليد سخري, 1: كرتون, 2: كبس

  void increment() => quantity.value++;
  void decrement() {
    if (quantity.value > 1) quantity.value--;
  }

  void reviewPrice() {
    Get.toNamed(CustomerRoutes.cart);
  }
}
