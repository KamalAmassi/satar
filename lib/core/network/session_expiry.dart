import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:project/core/design/shell.dart' show showToast;
import 'package:project/core/l10n/app_localizations.dart';
import 'package:project/core/storage/session_store.dart';

/// إنهاء الجلسة عند 401 من استدعاء موثّق: مسح الجلسة ثم شاشة دخول الدور مع رسالة.
abstract final class SessionExpiry {
  /// خطّاف يضبطه التطبيق لتنظيف بيانات المستخدم (يُوصل في AppBinding).
  static Future<void> Function()? onSignedOut;

  static Future<void> handle() async {
    final s = Get.find<SessionStore>();
    if (!s.isSignedIn) return;
    await s.signOut();
    await onSignedOut?.call();
    Get.offAllNamed(s.loginRoute);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = Get.context;
      final msg = ctx == null ? null : AppLocalizations.of(ctx)?.sessionExpiredSnack;
      if (msg != null) showToast(msg, icon: 'alertC');
    });
  }
}
