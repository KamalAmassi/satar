import 'package:get/get.dart';

/// يرجع إلى [route] إن كان في المكدس؛ وإلا يرجع لأول شاشة ثم يفتحه.
/// بديل آمن لـ Get.until الذي يُفرغ المكدس إذا لم يجد المسار.
void backTo(String route) {
  final navigator = Get.key.currentState;
  if (navigator == null) return;
  var found = false;
  navigator.popUntil((r) {
    if (r.settings.name == route) found = true;
    return found || r.isFirst;
  });
  if (!found) Get.toNamed(route);
}

/// يرجع إلى أول شاشة خارج [flow] (أو أول شاشة في المكدس).
void leaveFlow(Set<String> flow) {
  Get.key.currentState
      ?.popUntil((r) => r.isFirst || !flow.contains(r.settings.name));
}

/// يفتح [route] ويزيل من المكدس كل شاشات [flow] التي فوق أول شاشة خارجه،
/// حتى لا يعيد زر الرجوع المستخدم إلى مسار انتهى (مثل الدفع بعد إنشاء الطلب).
void leaveFlowTo(String route, Set<String> flow, {Object? arguments}) {
  Get.offNamedUntil(
    route,
    (r) => r.isFirst || !flow.contains(r.settings.name),
    arguments: arguments,
  );
}
