import 'package:get/get.dart';
import 'package:project/core/routes/app_routes.dart';

class PrintingController extends GetxController {
  void startPrinting() {
    Get.toNamed(CustomerRoutes.uploadFiles);
  }
}
