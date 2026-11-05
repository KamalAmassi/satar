import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:project/core/services/push/notification_router.dart';
import 'package:project/core/services/push/push_messaging.dart';
import 'package:project/core/services/push/push_registrar.dart';
import 'package:project/core/services/push/push_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeMessaging implements PushMessaging {
  PushPermission permission = PushPermission.granted;
  String? token = 'tok-AAAAAA';
  int deleted = 0;
  final refresh = StreamController<String>.broadcast();

  @override
  Future<PushPermission> requestPermission() async => permission;
  @override
  Future<PushPermission> permissionStatus() async => permission;
  @override
  Future<String?> getToken() async => token;
  @override
  Future<void> deleteToken() async => deleted++;
  @override
  Stream<String> get onTokenRefresh => refresh.stream;
  @override
  Stream<PushMessage> get onMessage => const Stream.empty();
  @override
  Stream<PushMessage> get onMessageOpenedApp => const Stream.empty();
  @override
  Future<PushMessage?> getInitialMessage() async => null;
}

class _FakeRegistrar implements PushRegistrar {
  final registered = <String>[];
  int unregisters = 0;
  int failNext = 0;
  bool? server = true;

  @override
  Future<bool> register(String token) async {
    if (failNext > 0) {
      failNext--;
      return false;
    }
    registered.add(token);
    return true;
  }

  @override
  Future<bool> unregister() async {
    unregisters++;
    return true;
  }

  @override
  Future<bool?> serverHasToken() async => server;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeMessaging messaging;
  late _FakeRegistrar registrar;
  late SharedPreferences prefs;
  late bool signedIn;

  Future<PushService> service() async => PushService(
        messaging: messaging,
        prefs: prefs,
        supported: true,
        registrar: () => signedIn ? registrar : null,
        retryDelay: Duration.zero,
      );

  setUp(() async {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    messaging = _FakeMessaging();
    registrar = _FakeRegistrar();
    signedIn = true;
  });

  test('toggle ON: permission granted → token registered, pref saved, switch on', () async {
    final s = await service();
    final r = await s.setEnabled(true);
    expect(r, PushToggleResult.enabled);
    expect(registrar.registered, ['tok-AAAAAA']);
    expect(prefs.getBool(PushService.prefKey), isTrue);
    expect(s.isEnabled.value, isTrue);
  });

  test('toggle ON with denied permission → stays off, no registration', () async {
    messaging.permission = PushPermission.denied;
    final s = await service();
    expect(await s.setEnabled(true), PushToggleResult.denied);
    expect(registrar.registered, isEmpty);
    expect(s.isEnabled.value, isFalse);
    expect(s.permissionDenied.value, isTrue);
  });

  test('toggle ON fails when server reports has_fcm_token = false', () async {
    registrar.server = false;
    final s = await service();
    expect(await s.setEnabled(true), PushToggleResult.failed);
    expect(s.isEnabled.value, isFalse);
  });

  test('toggle OFF → server unregister + local deleteToken + pref false', () async {
    final s = await service();
    await s.setEnabled(true);
    expect(await s.setEnabled(false), PushToggleResult.disabled);
    expect(registrar.unregisters, 1);
    expect(messaging.deleted, 1);
    expect(prefs.getBool(PushService.prefKey), isFalse);
    expect(s.isEnabled.value, isFalse);
  });

  test('registration retries once on failure', () async {
    registrar.failNext = 1;
    final s = await service();
    expect(await s.registerToken(), isTrue);
    expect(registrar.registered, ['tok-AAAAAA']);
  });

  test('token refresh re-registers the new token', () async {
    final s = await service();
    await s.init();
    messaging.refresh.add('tok-BBBBBB');
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(registrar.registered.last, 'tok-BBBBBB');
    s.onClose();
  });

  test('no session → nothing is registered', () async {
    signedIn = false;
    final s = await service();
    await s.init();
    expect(await s.registerToken(), isFalse);
    expect(registrar.registered, isEmpty);
    s.onClose();
  });

  test('logout unregisters once per session', () async {
    final s = await service();
    await s.setEnabled(true);
    await s.onLogout();
    await s.onLogout();
    expect(registrar.unregisters, 1);
    expect(s.isEnabled.value, isFalse);
  });

  test('unsupported platform is a no-op', () async {
    final s = PushService(messaging: messaging, prefs: prefs, supported: false, registrar: () => registrar);
    expect(await s.setEnabled(true), PushToggleResult.unsupported);
    await s.init();
    expect(registrar.registered, isEmpty);
  });

  group('NotificationRouter.resolve', () {
    test('logged out → ignored', () {
      expect(NotificationRouter.resolve({'order_id': 5}, role: null), isNull);
    });
    test('customer order / offer', () {
      expect(NotificationRouter.resolve({'event': 'order.status_changed', 'order_id': '5'}, role: 'customer')?.route, '/order');
      expect(NotificationRouter.resolve({'event': 'price_offer.created', 'order_id': 5}, role: 'customer')?.route, '/offer');
      expect(NotificationRouter.resolve({}, role: 'customer')?.route, '/notifications');
    });
    test('driver available / task', () {
      expect(NotificationRouter.resolve({'event': 'order.available'}, role: 'driver')?.route, '/driver/available');
      expect(NotificationRouter.resolve({'event': 'order.assigned', 'order_id': 9}, role: 'driver')?.route, '/driver/task');
      expect(NotificationRouter.resolve({'event': 'misc'}, role: 'driver')?.route, '/driver/notifications');
    });
  });
}
