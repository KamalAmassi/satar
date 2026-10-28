import 'package:get/get.dart';
import 'package:project/core/routes/app_routes.dart';

class OfferController extends GetxController {
  void acceptOffer() {
    Get.toNamed(CustomerRoutes.payment);
  }

  void rejectOffer() {
    Get.back();
  }
}
