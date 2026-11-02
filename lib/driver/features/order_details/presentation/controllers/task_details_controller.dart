import 'package:get/get.dart';
import 'package:project/driver/features/order_details/presentation/order_details_args.dart';
import 'package:project/driver/shared/driver_models.dart';
import 'package:url_launcher/url_launcher.dart';

/// تفاصيل مهمة حالية أو سابقة (بعد القبول: العنوان الكامل وبيانات الزبون ظاهرة).
class DriverTaskDetailsController extends GetxController {
  late final OrderDetailsArgs args = Get.arguments as OrderDetailsArgs;

  DriverOrder get order => args.order;
  OrderDetailsMode get mode => args.mode;

  Future<void> call(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    await launchUrl(Uri(scheme: 'tel', path: phone));
  }
}
