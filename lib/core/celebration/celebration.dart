import 'dart:math' as math;

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// إعداد الاحتفال في مكان واحد. [intensity] (0..1) يُضرب في شدة الحركة من النظام.
abstract final class CelebrationConfig {
  static double intensity = 1;

  /// أقصى عدد للجزيئات عند الشدة الكاملة (السقف المطلق 60).
  static const maxParticles = 48;
  static const hardCap = 60;
  static const seed = 0x5A7;

  /// عدد الجزيئات لشدة فعلية (0 ⇒ لا انفجار).
  static int particleCount(double motionIntensity) {
    final eff = (intensity * motionIntensity).clamp(0.0, 1.0);
    return (maxParticles * eff).round().clamp(0, hardCap);
  }
}

/// تخزين مفاتيح الأحداث المحتفى بها عبر الجلسات.
abstract interface class CelebrationStore {
  bool contains(String key);
  void add(String key, int capacity);
}

class PrefsCelebrationStore implements CelebrationStore {
  PrefsCelebrationStore(this._prefs);

  static const prefKey = 'celebrated_events';
  final SharedPreferences _prefs;

  List<String> get _all => _prefs.getStringList(prefKey) ?? const [];

  @override
  bool contains(String key) => _all.contains(key);

  @override
  void add(String key, int capacity) {
    final list = [..._all]..remove(key);
    list.add(key);
    final trimmed = list.length > capacity ? list.sublist(list.length - capacity) : list;
    _prefs.setStringList(prefKey, trimmed); // بلا انتظار؛ فشل الكتابة لا يكسر الواجهة
  }
}

/// حارس "مرة واحدة لكل حدث": يصمد أمام إعادة البناء والعودة للمسار، ويستمر عبر الجلسات عند [persist].
class CelebrationGuard {
  CelebrationGuard({CelebrationStore? store, this.capacity = 50}) : _store = store;

  static CelebrationGuard? _instance;

  /// النسخة العامة: تستخدم SharedPreferences المسجّلة في Get إن وُجدت.
  static CelebrationGuard get instance => _instance ??= CelebrationGuard(
        store: Get.isRegistered<SharedPreferences>() ? PrefsCelebrationStore(Get.find<SharedPreferences>()) : null,
      );

  static set instance(CelebrationGuard g) => _instance = g;

  final CelebrationStore? _store;
  final int capacity;
  final Set<String> _session = {};

  /// true في أول مرة فقط لهذا المفتاح.
  bool shouldRun(String key, {bool persist = false}) {
    if (_session.contains(key)) return false;
    _session.add(key);
    final store = _store;
    if (persist && store != null) {
      if (store.contains(key)) return false;
      store.add(key, capacity);
    }
    return true;
  }
}

enum ParticleKind { square, dash, star }

/// جزيء محسوب مسبقًا (لا عشوائية أثناء الرسم).
class Particle {
  const Particle({
    required this.kind,
    required this.vx,
    required this.vy,
    required this.drift,
    required this.wobble,
    required this.rotation,
    required this.spin,
    required this.size,
    required this.delay,
    required this.life,
    required this.colorIndex,
  });

  final ParticleKind kind;
  final double vx, vy; // بكسل منطقي/ث
  final double drift, wobble; // انجراف جانبي جيبي
  final double rotation, spin;
  final double size;
  final double delay, life; // ثوانٍ
  final int colorIndex;
}

/// فيزياء الانفجار (ثوابت محاكاة لا رموز واجهة).
abstract final class BurstPhysics {
  static const gravity = 900.0;
  static const spread = 1.25; // راديان على جانبي الأعلى
  static const minSpeed = 220.0, maxSpeed = 480.0;
  static const maxDelay = .15;
  static const minLifeFraction = .55;
}

/// توليد حتمي للجزيئات بالبذرة نفسها. [seconds] مدة الانفجار: لا يعيش جزيء بعدها.
List<Particle> generateParticles({
  required int count,
  required int colors,
  required double seconds,
  int seed = CelebrationConfig.seed,
}) {
  final n = count.clamp(0, CelebrationConfig.hardCap);
  if (n == 0 || colors <= 0 || seconds <= 0) return const [];
  final r = math.Random(seed);
  double range(double a, double b) => a + (b - a) * r.nextDouble();
  final maxLife = seconds - BurstPhysics.maxDelay;
  return List.unmodifiable([
    for (var i = 0; i < n; i++)
      () {
        final k = r.nextDouble();
        final kind = k < .45 ? ParticleKind.square : (k < .8 ? ParticleKind.dash : ParticleKind.star);
        final angle = -math.pi / 2 + range(-BurstPhysics.spread, BurstPhysics.spread);
        final speed = range(BurstPhysics.minSpeed, BurstPhysics.maxSpeed);
        return Particle(
          kind: kind,
          vx: math.cos(angle) * speed,
          vy: math.sin(angle) * speed,
          drift: range(-18, 18),
          wobble: range(3, 7),
          rotation: range(0, math.pi * 2),
          spin: range(-6, 6),
          size: kind == ParticleKind.dash ? range(8, 14) : range(4, 8),
          delay: range(0, BurstPhysics.maxDelay),
          life: range(maxLife * BurstPhysics.minLifeFraction, maxLife),
          colorIndex: r.nextInt(colors),
        );
      }(),
  ]);
}
