import 'package:get/get.dart';

/// قراءة معاملات التنقل المتفق عليها بين الميزات.
///
/// عقد الطلب: `Get.toNamed(route, arguments: {'order_id': id})`.
abstract final class RouteArgs {
  static const orderId = 'order_id';

  static int? readOrderId() {
    final args = Get.arguments;
    if (args is int) return args;
    if (args is Map && args[orderId] != null) {
      final v = args[orderId];
      return v is int ? v : int.tryParse('$v');
    }
    return int.tryParse(Get.parameters[orderId] ?? '');
  }

  static Map<String, dynamic> order(int id) => {orderId: id};
}
