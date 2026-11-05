import 'package:firebase_messaging/firebase_messaging.dart';

/// حالة إذن الإشعارات من النظام.
enum PushPermission { granted, denied, notDetermined }

/// رسالة FCM مبسّطة (بلا اعتماد على أنواع Firebase خارج هذا الملف).
class PushMessage {
  const PushMessage({this.id, this.title, this.body, this.data = const {}});
  final String? id;
  final String? title;
  final String? body;
  final Map<String, dynamic> data;
}

/// واجهة فوق FirebaseMessaging حتى تُختبر خدمة الإشعارات بلا Firebase.
abstract class PushMessaging {
  Future<PushPermission> requestPermission();
  Future<PushPermission> permissionStatus();
  Future<String?> getToken();
  Future<void> deleteToken();
  Stream<String> get onTokenRefresh;
  Stream<PushMessage> get onMessage;
  Stream<PushMessage> get onMessageOpenedApp;
  Future<PushMessage?> getInitialMessage();
}

/// عرض رسالة FCM أثناء عمل التطبيق في الواجهة (فقط — لا إشعارات محلية مُجدولة).
abstract class ForegroundPresenter {
  Future<void> init(void Function(Map<String, dynamic> data) onTap);
  Future<void> show(PushMessage message);
}

class FirebasePushMessaging implements PushMessaging {
  const FirebasePushMessaging();

  FirebaseMessaging get _m => FirebaseMessaging.instance;

  @override
  Future<PushPermission> requestPermission() async =>
      _map((await _m.requestPermission(alert: true, badge: true, sound: true)).authorizationStatus);

  @override
  Future<PushPermission> permissionStatus() async => _map((await _m.getNotificationSettings()).authorizationStatus);

  @override
  Future<String?> getToken() => _m.getToken();

  @override
  Future<void> deleteToken() => _m.deleteToken();

  @override
  Stream<String> get onTokenRefresh => _m.onTokenRefresh;

  @override
  Stream<PushMessage> get onMessage => FirebaseMessaging.onMessage.map(_msg);

  @override
  Stream<PushMessage> get onMessageOpenedApp => FirebaseMessaging.onMessageOpenedApp.map(_msg);

  @override
  Future<PushMessage?> getInitialMessage() async {
    final m = await _m.getInitialMessage();
    return m == null ? null : _msg(m);
  }

  static PushPermission _map(AuthorizationStatus s) => switch (s) {
        AuthorizationStatus.authorized || AuthorizationStatus.provisional => PushPermission.granted,
        AuthorizationStatus.denied => PushPermission.denied,
        AuthorizationStatus.notDetermined => PushPermission.notDetermined,
      };

  static PushMessage _msg(RemoteMessage m) => PushMessage(
        id: m.messageId,
        title: m.notification?.title ?? m.data['title'] as String?,
        body: m.notification?.body ?? m.data['body'] as String?,
        data: m.data,
      );
}
