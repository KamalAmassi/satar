import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/design/widgets.dart';
import 'package:project/core/storage/session_store.dart';
import 'package:project/customer/features/entry/presentation/entry_page.dart' show SystemStateScreen;

/// انتهاء الجلسة. منقولة من d1d6084:lib/features/entry/entry.dart (SessionExpiredScreen).
class SessionExpiredScreen extends StatefulWidget {
  const SessionExpiredScreen({super.key});
  @override
  State<SessionExpiredScreen> createState() => _SessionExpiredScreenState();
}

class _SessionExpiredScreenState extends State<SessionExpiredScreen> {
  late final bool driver = Get.find<SessionStore>().isDriver;
  @override
  void initState() {
    super.initState();
    // نلغي الجلسة المحلية فقط؛ السلة تبقى محفوظة على الجهاز.
    Get.find<SessionStore>().signOut();
  }

  @override
  Widget build(BuildContext context) => SystemStateScreen(
      ill: 'lock',
      title: 'انتهت جلستك',
      text: driver ? 'سجّل الدخول مرة أخرى للمتابعة.' : 'سجّل الدخول مرة أخرى للمتابعة. سلتك محفوظة.',
      actions: [SBtn('تسجيل الدخول', full: true, onTap: () => driver ? Get.offAllNamed('/driver/login') : Get.offAllNamed('/auth/phone'))]);
}
