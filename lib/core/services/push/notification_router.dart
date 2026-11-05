import 'package:get/get.dart';

typedef NotificationTarget = ({String route, Map<String, dynamic>? args});

/// موجّه الإشعارات: يحوّل event/data إلى مسار حسب دور الجلسة الحالية.
/// يُستخدم للضغط من الواجهة والخلفية والإقلاع البارد وقائمة الإشعارات.
abstract final class NotificationRouter {
  /// [role]: 'customer' | 'driver' | null (غير مسجّل ⇒ تجاهل).
  static NotificationTarget? resolve(Map<String, dynamic> data, {required String? role}) {
    if (role != 'customer' && role != 'driver') return null;
    final event = '${data['event'] ?? data['destination'] ?? data['target'] ?? ''}'.toLowerCase();
    final raw = data['order_id'] ?? data['orderId'] ?? data['order'];
    final orderId = raw is num ? raw.toInt() : int.tryParse('${raw ?? ''}');

    if (role == 'driver') {
      if (event.contains('cash')) return (route: '/driver/cash', args: null);
      if (event.contains('available') || event.contains('new_order') || event.contains('nearby')) {
        return (route: '/driver/available', args: null);
      }
      // مهمة مُسندة/محدّثة: شاشة المهمة الحالية تحمّل الطلب بنفسها.
      if (orderId != null || event.contains('task') || event.contains('assign')) return (route: '/driver/task', args: null);
      return (route: '/driver/notifications', args: null);
    }

    if (orderId != null && (event.contains('offer') || event.contains('price'))) {
      return (route: '/offer', args: {'order_id': orderId});
    }
    if (orderId != null) return (route: '/order', args: {'order_id': orderId});
    return (route: '/notifications', args: null);
  }

  static void route(Map<String, dynamic> data, {required String? role}) {
    final t = resolve(data, role: role);
    if (t == null) return;
    if (t.args == null && Get.currentRoute == t.route) return;
    Get.toNamed(t.route, arguments: t.args);
  }

  /// اسم مريح للواجهة: يوجّه حسب كون الجلسة سائقًا أم زبونًا.
  static void routePayload(Map<String, dynamic> data, {required bool isDriver}) => route(data, role: isDriver ? 'driver' : 'customer');
}
