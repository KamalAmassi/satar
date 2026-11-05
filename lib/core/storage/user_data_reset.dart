import 'dart:async';

import 'package:flutter/foundation.dart';

/// تنظيف حالة المستخدم الحالية (متحكمات وذاكرة) عند الخروج أو تبدّل الحساب.
///
/// الخطّافات تُسجَّل من التطبيق (AppBinding) فلا يعتمد core على الميزات. لا يمسّ
/// خدمات التطبيق الدائمة (Dio/الجلسة/الإشعارات). لا يحذف بيانات مخزّنة بمفتاح
/// مستخدم (كالسلة)؛ هذه تعود لصاحبها عند دخوله ثانية.
abstract final class UserDataReset {
  static final List<FutureOr<void> Function()> _hooks = [];

  static void register(FutureOr<void> Function() hook) => _hooks.add(hook);

  @visibleForTesting
  static void clearHooks() => _hooks.clear();

  static Future<void> run() async {
    for (final h in List.of(_hooks)) {
      try {
        await h();
      } catch (_) {
        // فشل خطّاف واحد لا يوقف البقية.
      }
    }
  }
}
