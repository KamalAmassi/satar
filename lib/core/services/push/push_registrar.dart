/// تسجيل رمز FCM على الخادم لدور معيّن (زبون/سائق). التطبيقات خارج core.
abstract class PushRegistrar {
  /// يرسل الرمز للخادم. true عند النجاح.
  Future<bool> register(String token);

  /// يزيل الرمز من الخادم. true عند قبول الخادم.
  Future<bool> unregister();

  /// قيمة has_fcm_token من ملف الحساب (null إن تعذّر التحقق).
  Future<bool?> serverHasToken();
}
