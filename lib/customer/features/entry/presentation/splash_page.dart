import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/config/remote_config_repository.dart';
import 'package:project/core/data/backend.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/l10n/app_localizations.dart';
import 'package:project/core/motion/motion_settings.dart';
import 'package:project/core/storage/session_store.dart';

/// يقرر أول شاشة بعد الإقلاع (مكان واحد لشجرة القرار) بعد إنهاء فحوص البدء الفعلية.
///
/// 1) لم يُرَ التعريف ⇒ onboarding. 2) لا جلسة ⇒ دخول الدور المحفوظ أو اختيار الدور.
/// 3) جلسة ⇒ التحقق بـ /me: 200 ⇒ الرئيسية؛ 401 ⇒ تتولاه [SessionExpiry] (يعيد null)؛
/// أي خطأ شبكة/مهلة ⇒ الرئيسية بالجلسة المخزنة (يعمل دون اتصال).
class SplashController {
  SplashController({SessionStore? session, Backend? backend})
      : _session = session ?? Get.find<SessionStore>(),
        _backend = backend;

  final SessionStore _session;
  final Backend? _backend;
  static const _validateTimeout = Duration(seconds: 4);

  Future<String?> resolveStart() async {
    await Get.find<RemoteConfigRepository>().load();
    if (_session.isSignedIn) {
      final home = _session.isDriver ? '/driver/home' : '/home';
      final backend = _backend ?? Get.find<Backend>();
      try {
        final res = await (_session.isDriver ? backend.driverMe() : backend.me()).timeout(_validateTimeout);
        final String? next = res.fold((f) => f.statusCode == 401 ? null : home, (_) => home);
        return next;
      } catch (_) {
        return home;
      }
    }
    if (!_session.onboardingSeen) return '/onboarding';
    return _session.loginRoute;
  }
}

/// شاشة البداية: شعار على ورق دافئ ويُسحب تحته خطّ بقلم (~1.1ث).
/// تنتقل عند اكتمال فحوص البدء **و** نهاية الحركة؛ ولا مؤقتات اصطناعية.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  static const _anim = Duration(milliseconds: 1100);

  late final AnimationController _draw = AnimationController(vsync: this, duration: _anim);
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
  String? _route;
  bool _reduce = false;
  bool _started = false;
  bool _left = false;

  @override
  void initState() {
    super.initState();
    SplashController().resolveStart().then((r) {
      if (r == null) {
        _left = true; // 401: SessionExpiry تنقل إلى الدخول.
        return;
      }
      _route = r;
      _maybeLeave();
    });
    _draw.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        if (_route == null) _pulse.repeat(reverse: true);
        _maybeLeave();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _reduce = MotionSettings.of(context).reduceMotion;
    if (_reduce) {
      _draw.value = 1;
      _maybeLeave();
    } else {
      _draw.forward();
    }
  }

  void _maybeLeave() {
    if (_left || !mounted || _route == null || !_started) return;
    if (!_reduce && !_draw.isCompleted) return;
    _left = true;
    Get.offAllNamed(_route!);
  }

  @override
  void dispose() {
    _draw.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    // الشعار داكن: في الوضع الداكن يوضع على لوحة ورقية لتباين قوي.
    final paper = SatrColors.light;
    final ink = c.dark ? paper.pri : c.pri;
    const box = 240.0;
    Widget mark = SizedBox(
      width: box,
      height: box,
      child: AnimatedBuilder(
        animation: Listenable.merge([_draw, _pulse]),
        builder: (_, __) {
          final t = _draw.value;
          final fade = Interval(0, .25, curve: Curves.easeOut).transform(t);
          final settle = Interval(.8, 1, curve: Curves.easeOutBack).transform(t);
          final scale = (.96 + .04 * fade) + .03 * (1 - settle) * (t >= .8 ? 1 : 0) + .02 * _pulse.value;
          return Transform.scale(
            scale: scale,
            child: Stack(children: [
              Positioned.fill(
                child: Opacity(opacity: fade, child: Image.asset('assets/images/Satr_logo.png', fit: BoxFit.contain)),
              ),
              Positioned.fill(
                child: CustomPaint(painter: _PenUnderline(progress: Interval(.2, .85, curve: Curves.easeInOut).transform(t), ink: ink, tip: c.amber)),
              ),
            ]),
          );
        },
      ),
    );
    if (c.dark) {
      mark = Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: paper.bg, borderRadius: BorderRadius.circular(Rad.xl)),
        child: mark,
      );
    }
    return Scaffold(
      backgroundColor: c.bg,
      body: Center(
        child: Semantics(label: AppLocalizations.of(context)?.appName ?? '', image: true, child: ExcludeSemantics(child: mark)),
      ),
    );
  }
}

/// خطّ بقلم متموّج قليلًا يُرسم تدريجيًا تحت الشعار مع رأس القلم.
class _PenUnderline extends CustomPainter {
  _PenUnderline({required this.progress, required this.ink, required this.tip});
  final double progress;
  final Color ink, tip;

  @override
  void paint(Canvas canvas, Size s) {
    if (progress <= 0) return;
    final y = s.height * .78;
    // RTL: يبدأ من اليمين إلى اليسار كما تُكتب العربية.
    final x0 = s.width * .78, x1 = s.width * .22;
    final path = Path()
      ..moveTo(x0, y)
      ..quadraticBezierTo(s.width * .6, y - 5, s.width * .5, y + 1)
      ..quadraticBezierTo(s.width * .36, y + 6, x1, y - 1);
    final PathMetric m = path.computeMetrics().first;
    final drawn = m.extractPath(0, m.length * progress);
    canvas.drawPath(
      drawn,
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 3,
    );
    if (progress < 1) {
      final tan = m.getTangentForOffset(m.length * progress);
      if (tan != null) canvas.drawCircle(tan.position, 3.5, Paint()..color = tip);
    }
  }

  @override
  bool shouldRepaint(_PenUnderline o) => o.progress != progress || o.ink != ink || o.tip != tip;
}
