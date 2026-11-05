import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// نوع النبضة على مستوى المنصة.
enum HapticKind { light, medium, heavy, selection }

typedef HapticSink = void Function(HapticKind kind);
typedef HapticCancel = void Function();
typedef HapticScheduler = HapticCancel Function(Duration delay, VoidCallback fn);

/// اهتزاز تفاعلي بواجهة دلالية. المكان الوحيد في التطبيق الذي يلمس HapticFeedback.
///
/// - [tap], [select]: أولوية منخفضة، تُهمل داخل نافذة الإخماد.
/// - [confirm], [error], [success]: نتائج بأولوية عالية، تؤجَّل لنهاية النافذة
///   ولا تُهمل، والنتيجة تكسب دائمًا ضغطة معلّقة.
/// - لا يُستخدم HapticFeedback.vibrate (قد يتطلب إذن VIBRATE).
/// - صامت تمامًا على الويب وأنظمة سطح المكتب.
abstract final class Haptics {
  static const prefKey = 'pref_haptics_enabled';

  /// أقل فاصل بين نبضتين (خطوات النمط هي الاستثناء الوحيد).
  static const minGap = Duration(milliseconds: 80);

  /// الفاصل بين نبضتي نمط النجاح.
  static const patternGap = Duration(milliseconds: 90);

  /// إعداد المستخدم «الاهتزاز» (افتراضيًا مفعّل).
  static final RxBool enabled = true.obs;

  static SharedPreferences? _prefs;

  // ----------------------------------------------------- قابلة للحقن في الاختبارات
  @visibleForTesting
  static HapticSink sink = _systemSink;
  @visibleForTesting
  static Duration Function() clock = _monotonic;
  @visibleForTesting
  static HapticScheduler schedule = _timer;
  @visibleForTesting
  static bool Function() platformSupported = _platformSupported;

  // ----------------------------------------------------------------- الحالة
  static Duration? _quietUntil;
  static HapticCancel? _pending;
  static HapticCancel? _patternStep;
  static int _resultSerial = 0;

  /// يُستدعى مرة واحدة في main بعد تهيئة SharedPreferences.
  static void init(SharedPreferences prefs) {
    _prefs = prefs;
    enabled.value = prefs.getBool(prefKey) ?? true;
  }

  /// يحفظ الإعداد محليًا. عند التفعيل نعطي نبضة اختيار ليشعر المستخدم بالنتيجة.
  static Future<void> setEnabled(bool value) async {
    enabled.value = value;
    if (!value) _cancelAll();
    await _prefs?.setBool(prefKey, value);
    if (value) select();
  }

  // ------------------------------------------------------------ الواجهة الدلالية
  static void tap() => _emit(const [HapticKind.light], result: false);
  static void select() => _emit(const [HapticKind.selection], result: false);
  static void confirm() => _emit(const [HapticKind.medium], result: true);
  static void error() => _emit(const [HapticKind.heavy], result: true);
  static void success() => _emit(const [HapticKind.light, HapticKind.medium], result: true);

  /// يغلّف ضغطة زر: ينفّذ [action] ثم يعطي نبضة [tap] فقط إذا لم يُطلق
  /// الإجراء نفسه نتيجة (confirm/error/success) أثناء تنفيذه المتزامن،
  /// حتى لا تتكرر النبضة. للنتائج غير المتزامنة استخدم haptic: false.
  static void press(VoidCallback action, {bool haptic = true}) {
    final before = _resultSerial;
    action();
    if (haptic && _resultSerial == before) tap();
  }

  @visibleForTesting
  static void resetForTest() {
    _cancelAll();
    _quietUntil = null;
    _resultSerial = 0;
    _prefs = null;
    enabled.value = true;
    sink = _systemSink;
    clock = _monotonic;
    schedule = _timer;
    platformSupported = _platformSupported;
  }

  // ------------------------------------------------------------------ داخلي
  static void _emit(List<HapticKind> steps, {required bool result}) {
    if (result) _resultSerial++;
    if (!enabled.value || !platformSupported()) return;

    if (_pending != null) {
      if (!result) return; // نتيجة في الانتظار: تكسب.
      _pending!();
      _pending = null; // نتيجة أحدث تحل محل الأقدم.
    }

    final now = clock();
    final quiet = _quietUntil;
    if (quiet == null || now >= quiet) {
      _play(steps);
      return;
    }
    if (!result) return; // ضمن نافذة الإخماد: تُهمل.
    _pending = schedule(quiet - now, () {
      _pending = null;
      if (enabled.value) _play(steps);
    });
  }

  static void _play(List<HapticKind> steps) {
    final now = clock();
    _quietUntil = now + minGap + patternGap * (steps.length - 1);
    _safe(steps.first);
    if (steps.length > 1) _playRest(steps, 1);
  }

  static void _playRest(List<HapticKind> steps, int i) {
    _patternStep = schedule(patternGap, () {
      _patternStep = null;
      if (!enabled.value) return;
      _safe(steps[i]);
      if (i + 1 < steps.length) _playRest(steps, i + 1);
    });
  }

  static void _safe(HapticKind k) {
    try {
      sink(k);
    } catch (_) {
      // لا نُسقط الواجهة بسبب الاهتزاز أبدًا.
    }
  }

  static void _cancelAll() {
    _pending?.call();
    _pending = null;
    _patternStep?.call();
    _patternStep = null;
  }

  static final Stopwatch _sw = Stopwatch()..start();
  static Duration _monotonic() => _sw.elapsed;

  static HapticCancel _timer(Duration d, VoidCallback fn) => Timer(d, fn).cancel;

  static bool _platformSupported() =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static void _systemSink(HapticKind k) {
    final Future<void> f = switch (k) {
      HapticKind.light => HapticFeedback.lightImpact(),
      HapticKind.medium => HapticFeedback.mediumImpact(),
      HapticKind.heavy => HapticFeedback.heavyImpact(),
      HapticKind.selection => HapticFeedback.selectionClick(),
    };
    f.catchError((Object _) {});
  }
}
