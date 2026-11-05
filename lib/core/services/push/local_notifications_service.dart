import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:project/core/services/push/push_messaging.dart';

/// يعرض رسالة FCM القادمة أثناء عمل التطبيق في الواجهة فقط (لا جدولة ولا إشعارات مصطنعة).
class LocalNotificationsService implements ForegroundPresenter {
  LocalNotificationsService._();
  static final LocalNotificationsService instance = LocalNotificationsService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  /// يطابق default_notification_channel_id في AndroidManifest.
  static const String channelId = 'satr_high_importance_channel';
  static const String channelName = 'سطر - الإشعارات العاجلة';
  static const String channelDescription = 'إشعارات الطلبات وتحديثات حالة التوصيل والمقترحات السعرية.';

  bool _initialized = false;

  @override
  Future<void> init(void Function(Map<String, dynamic> data) onTap) async {
    if (_initialized) return;
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(requestAlertPermission: false, requestBadgePermission: false, requestSoundPermission: false),
    );
    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        final p = response.payload;
        if (p == null || p.isEmpty) return;
        try {
          onTap(Map<String, dynamic>.from(jsonDecode(p) as Map));
        } catch (_) {}
      },
    );
    const androidChannel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: Importance.max,
    );
    await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(androidChannel);
    _initialized = true;
  }

  @override
  Future<void> show(PushMessage message) async {
    final title = message.title ?? '';
    final body = message.body ?? '';
    if (title.isEmpty && body.isEmpty) return;
    const details = NotificationDetails(
      android: AndroidNotificationDetails(channelId, channelName,
          channelDescription: channelDescription, importance: Importance.max, priority: Priority.high, icon: '@mipmap/ic_launcher'),
      iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
    );
    await _plugin.show((message.id ?? '$title$body').hashCode, title, body, details, payload: jsonEncode(message.data));
  }
}
