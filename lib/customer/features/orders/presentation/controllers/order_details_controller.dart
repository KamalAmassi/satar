import 'package:get/get.dart';

class OrderDetailsController extends GetxController {
  void reviewOffer() {
    Get.snackbar('مراجعة السعر', 'جاري عرض تفاصيل السعر');
  }

  void rateOrder() {
    Get.snackbar('تقييم الطلب', 'شكراً لتقييمك!');
  }
}
