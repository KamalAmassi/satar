import 'package:project/core/services/push/push_registrar.dart';
import 'package:project/data/backend.dart';

/// مسجّل رمز FCM عبر الباكند لدور الزبون (PUT /me/fcm-token) أو السائق
/// (PUT /driver/me/fcm-token — غير موثّق في مجموعة Postman، يُؤكَّد عبر has_fcm_token).
class BackendPushRegistrar implements PushRegistrar {
  BackendPushRegistrar(this.backend, {required this.driver});
  final Backend backend;
  final bool driver;

  @override
  Future<bool> register(String token) async => (await backend.setFcmToken(token, driver: driver)).isRight();

  /// إلغاء التسجيل غير موثّق: (1) نفس المسار بـ {"token": null}، ثم (2) DELETE.
  @override
  Future<bool> unregister() async {
    if ((await backend.setFcmToken(null, driver: driver)).isRight()) return true;
    return (await backend.deleteFcmToken(driver: driver)).isRight();
  }

  @override
  Future<bool?> serverHasToken() async {
    if (driver) return (await backend.driverMe()).fold((_) => null, (m) => m.hasFcmToken);
    return (await backend.me()).fold((_) => null, (m) => m.hasFcmToken);
  }
}
