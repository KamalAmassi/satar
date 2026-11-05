import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:project/core/services/push/push_messaging.dart';
import 'package:project/core/services/push/push_registrar.dart';
import 'package:project/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// معالج الخلفية: top-level، بلا أي عمل على الواجهة. النظام يعرض إشعار FCM بنفسه.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {}
}

/// FCM مدعوم فقط على أندرويد و iOS (الويب/سطح المكتب: لا استدعاءات Firebase).
bool get pushPlatformSupported =>
    !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

enum PushToggleResult { enabled, disabled, denied, unsupported, failed }

/// خدمة الإشعارات الوحيدة للتطبيقين. لا تحتوي منطقًا خاصًا بدور:
/// [registrar] يعيد مسجّل الدور الحالي (أو null إن لم توجد جلسة)، و[onTap] يوجّه حسب الدور.
class PushService extends GetxService with WidgetsBindingObserver {
  PushService({
    required this.messaging,
    required this.prefs,
    required this.registrar,
    required this.supported,
    this.presenter,
    this.onTap,
    this.retryDelay = const Duration(seconds: 2),
  });

  final PushMessaging messaging;
  final SharedPreferences prefs;
  final PushRegistrar? Function() registrar;
  final bool supported;
  final ForegroundPresenter? presenter;
  final void Function(Map<String, dynamic> data)? onTap;
  final Duration retryDelay;

  /// تفضيل المستخدم (افتراضيًا مفعّل).
  static const prefKey = 'push_enabled';

  static PushService? get maybe => Get.isRegistered<PushService>() ? Get.find<PushService>() : null;

  /// الحالة الفعلية للمفتاح = التفضيل ∧ إذن النظام ∧ الرمز مسجّل على الخادم.
  final isEnabled = false.obs;
  final busy = false.obs;
  final permissionDenied = false.obs;

  bool _started = false;
  bool _registered = false;
  bool _needsRetry = false;
  bool _sessionClosed = false;
  String? _token;
  Map<String, dynamic>? _pendingTap;
  final _subs = <StreamSubscription<dynamic>>[];

  bool get prefOn => prefs.getBool(prefKey) ?? true;

  @override
  void onInit() {
    super.onInit();
    init();
  }

  /// يربط المستمعين، يلتقط رسالة الإقلاع البارد، ويسجّل الرمز إن كانت هناك جلسة.
  Future<void> init() async {
    if (!supported || _started) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    try {
      await presenter?.init(_handleTap);
      _subs.add(messaging.onTokenRefresh.listen((t) {
        _token = t;
        if (prefOn && registrar() != null) registerToken();
      }));
      _subs.add(messaging.onMessage.listen((m) {
        if (isEnabled.value) presenter?.show(m);
      }));
      _subs.add(messaging.onMessageOpenedApp.listen((m) => _handleTap(m.data)));
      final initial = await messaging.getInitialMessage();
      if (initial != null) _pendingTap = initial.data;
    } catch (_) {}
    if (registrar() != null) await onSessionStarted();
  }

  /// بعد نجاح الدخول (زبون/سائق) وعند الإقلاع مع جلسة محفوظة.
  Future<void> onSessionStarted() async {
    if (!supported || registrar() == null) return;
    _sessionClosed = false;
    if (!prefOn) {
      isEnabled.value = false;
      return;
    }
    if (await requestPermission() != PushPermission.granted) {
      isEnabled.value = false;
      return;
    }
    await registerToken();
  }

  Future<PushPermission> requestPermission() async {
    if (!supported) return PushPermission.denied;
    try {
      final p = await messaging.requestPermission();
      permissionDenied.value = p == PushPermission.denied;
      return p;
    } catch (_) {
      return PushPermission.notDetermined;
    }
  }

  /// يرسل الرمز للخادم مع إعادة محاولة واحدة؛ إن فشل يُعاد عند الرجوع للتطبيق.
  Future<bool> registerToken({bool retry = true}) async {
    final r = registrar();
    if (!supported || r == null) return false;
    try {
      _token ??= await messaging.getToken();
    } catch (_) {}
    final t = _token;
    if (t == null || t.isEmpty) {
      _needsRetry = true;
      return false;
    }
    var ok = await _safe(() => r.register(t));
    if (!ok && retry) {
      await Future<void>.delayed(retryDelay);
      ok = await _safe(() => r.register(t));
    }
    _registered = ok;
    _needsRetry = !ok;
    isEnabled.value = ok && prefOn && !permissionDenied.value;
    _log('register ${ok ? 'ok' : 'failed'} …${_tail(t)}');
    return ok;
  }

  /// يزيل الرمز من الخادم (إن قبل) ثم يحذفه محليًا فيتوقف الاستلام والتحديث.
  Future<bool> unregisterToken() async {
    final r = registrar();
    var ok = false;
    if (r != null) ok = await _safe(r.unregister);
    // TODO(backend): لا يوجد endpoint موثّق لإلغاء التسجيل؛ عند الرفض نكتفي بحذف الرمز محليًا.
    if (!ok) _log('server unregister not accepted — local fallback');
    try {
      await messaging.deleteToken();
    } catch (_) {}
    _token = null;
    _registered = false;
    _needsRetry = false;
    isEnabled.value = false;
    return ok;
  }

  /// مفتاح الإعدادات في التطبيقين.
  Future<PushToggleResult> setEnabled(bool on) async {
    if (!supported) return PushToggleResult.unsupported;
    if (busy.value) return PushToggleResult.failed;
    busy.value = true;
    try {
      if (!on) {
        await prefs.setBool(prefKey, false);
        await unregisterToken();
        return PushToggleResult.disabled;
      }
      if (await requestPermission() != PushPermission.granted) {
        isEnabled.value = false;
        return PushToggleResult.denied;
      }
      await prefs.setBool(prefKey, true);
      if (!await registerToken()) return PushToggleResult.failed;
      // تأكيد حالة الخادم مرة واحدة عبر has_fcm_token.
      final server = await registrar()?.serverHasToken();
      if (server == false) {
        _registered = false;
        _needsRetry = true;
        isEnabled.value = false;
        return PushToggleResult.failed;
      }
      return PushToggleResult.enabled;
    } finally {
      busy.value = false;
    }
  }

  /// قبل مسح الجلسة: إلغاء التسجيل بمهلة قصيرة، والفشل لا يمنع الخروج أبدًا. مرة واحدة لكل جلسة.
  Future<void> onLogout() async {
    if (!supported || _sessionClosed) return;
    _sessionClosed = true;
    try {
      await unregisterToken().timeout(const Duration(seconds: 4));
    } catch (_) {}
  }

  /// يُستدعى بعد أن تفتح شاشة البداية الرئيسية: يطبّق ضغطة الإقلاع البارد.
  void handleInitialMessage() {
    final d = _pendingTap;
    _pendingTap = null;
    if (d != null) Future<void>.delayed(const Duration(milliseconds: 300), () => onTap?.call(d));
  }

  /// مزامنة عند الرجوع للتطبيق: إذن النظام + إعادة محاولة التسجيل المعلّق.
  Future<void> resync() async {
    if (!supported || registrar() == null) return;
    PushPermission p;
    try {
      p = await messaging.permissionStatus();
    } catch (_) {
      return;
    }
    permissionDenied.value = p == PushPermission.denied;
    if (p != PushPermission.granted) {
      isEnabled.value = false;
      return;
    }
    if (prefOn && (!_registered || _needsRetry)) {
      await registerToken(retry: false);
    } else {
      isEnabled.value = prefOn && _registered;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) resync();
  }

  void _handleTap(Map<String, dynamic> data) => onTap?.call(data);

  static Future<bool> _safe(Future<bool> Function() f) async {
    try {
      return await f();
    } catch (_) {
      return false;
    }
  }

  static String _tail(String t) => t.length <= 6 ? t : t.substring(t.length - 6);

  static void _log(String m) {
    if (kDebugMode) debugPrint('[push] $m');
  }

  @override
  void onClose() {
    for (final s in _subs) {
      s.cancel();
    }
    if (_started) WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}
