import 'package:get/get.dart';
import 'package:project/core/routes/app_routes.dart';

class LiveTrackingController extends GetxController {
  void callDriver() {
    Get.snackbar('اتصال', 'جاري الاتصال بالسائق...');
  }

  void goToCancelOrder() {
    Get.toNamed(CustomerRoutes.cancelOrder);
  }

  void goToShareTracking() {
    Get.toNamed(CustomerRoutes.shareTracking);
  }
}
