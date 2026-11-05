import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:project/core/celebration/celebration.dart';
import 'package:project/core/design/motion.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/motion/motion_settings.dart';
import 'package:project/core/utils/haptics.dart';
import 'package:project/core/widgets/celebration_burst.dart';

/// شارة نجاح: علامة ✓ تُرسم كخط حبر ثم انفجار احتفالي — مرة واحدة لكل [eventKey].
///
/// ```dart
/// SuccessBadge(eventKey: 'order-placed:42', semanticsLabel: l.celebrationOrderPlaced)
/// SuccessBadge(eventKey: 'order-delivered:42', persist: true, calm: true, size: 28, ...)
/// ```
/// - [eventKey] = null ⇒ مرة واحدة لكل ظهور للويدجت فقط.
/// - [persist] ⇒ لا يتكرر حتى بعد إعادة تشغيل التطبيق.
/// - [calm] ⇒ علامة فقط، بلا انفجار، وبلمسة اهتزاز أخف.
/// - تقليل الحركة أو حدث سبق الاحتفال به ⇒ علامة ثابتة مكتملة بلا اهتزاز.
/// تُضبط الشدة من [CelebrationConfig.intensity].
class SuccessBadge extends StatefulWidget {
  const SuccessBadge({
    super.key,
    required this.semanticsLabel,
    this.eventKey,
    this.persist = false,
    this.calm = false,
    this.size = 96,
  });

  final String semanticsLabel;
  final String? eventKey;
  final bool persist;
  final bool calm;
  final double size;

  @override
  State<SuccessBadge> createState() => _SuccessBadgeState();
}

class _SuccessBadgeState extends State<SuccessBadge> with SingleTickerProviderStateMixin {
  AnimationController? _c;
  late Animation<double> _check;
  Animation<double>? _burst;
  bool _fresh = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_c != null) return; // القرار يُتخذ مرة واحدة فقط (يصمد أمام إعادة البناء)
    final m = MotionSettings.of(context);
    final key = widget.eventKey;
    _fresh = key == null || CelebrationGuard.instance.shouldRun(key, persist: widget.persist);
    final animate = _fresh && !m.reduceMotion;
    final burstOn = animate && !widget.calm && CelebrationConfig.particleCount(m.intensity) > 0;
    final total = burstOn ? Motion.checkDraw + Motion.celebrationBurst : Motion.checkDraw;
    final c = AnimationController(vsync: this, duration: total); // الـ Ticker الوحيد للتأثير كله
    final frac = Motion.checkDraw.inMicroseconds / total.inMicroseconds;
    _check = CurvedAnimation(parent: c, curve: Interval(0, frac, curve: Curves.easeOutCubic));
    _burst = burstOn ? c.drive(CurveTween(curve: Interval(frac, 1))) : null;
    _c = c;
    if (animate) {
      c.forward(); // يتوقف تلقائيًا عند النهاية ولا يتكرر
    } else {
      c.value = 1;
    }
    if (_fresh) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.calm ? Haptics.select() : Haptics.success(); // لا شيء على الويب/ويندوز
      });
    }
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final s = widget.size;
    final burst = _burst;
    return Semantics(
      container: true,
      liveRegion: _fresh,
      label: widget.semanticsLabel,
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: s,
          child: Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [
            if (burst != null) CelebrationBurst(progress: burst, extent: s * 3.75),
            RepaintBoundary(
              child: CustomPaint(
                size: Size.square(s),
                painter: CheckPainter(
                  progress: _check,
                  extent: s,
                  fill: widget.calm ? c.okSoft : c.plumSoft,
                  ink: widget.calm ? c.okInk : c.pri,
                  ring: widget.calm ? null : c.amber,
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

/// علامة ✓ كخط حبر. المسارات الجزئية تُحسب مرة واحدة في المُنشئ (PathMetric).
class CheckPainter extends CustomPainter {
  CheckPainter({
    required this.progress,
    required this.extent,
    required this.fill,
    required this.ink,
    this.ring,
  }) : super(repaint: progress) {
    final s = extent;
    final full = Path()
      ..moveTo(s * .30, s * .52)
      ..lineTo(s * .44, s * .66)
      ..lineTo(s * .71, s * .38);
    final metrics = full.computeMetrics().toList();
    final total = metrics.fold<double>(0, (a, m) => a + m.length);
    for (var i = 0; i <= _steps; i++) {
      _partials.add(_extract(metrics, total * i / _steps));
    }
    _fill.color = fill;
    _ink
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = s * .075;
    if (ring != null) {
      _ring
        ..color = ring!
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * .02;
    }
  }

  static const _steps = 32;

  final Animation<double> progress;
  final double extent;
  final Color fill;
  final Color ink;
  final Color? ring;

  late final Offset _center = Offset(extent / 2, extent / 2);
  final _partials = <Path>[];
  final _fill = Paint();
  final _ink = Paint();
  final _ring = Paint();

  static Path _extract(List<PathMetric> metrics, double length) {
    final out = Path();
    var left = length;
    for (final m in metrics) {
      if (left <= 0) break;
      out.addPath(m.extractPath(0, left.clamp(0, m.length)), Offset.zero);
      left -= m.length;
    }
    return out;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final p = progress.value.clamp(0.0, 1.0);
    final r = extent / 2;
    final grow = .9 + .1 * (p * 2).clamp(0.0, 1.0);
    canvas
      ..save()
      ..translate(r, r)
      ..scale(grow)
      ..translate(-r, -r);
    canvas.drawCircle(_center, r, _fill);
    if (ring != null) canvas.drawCircle(_center, r - _ring.strokeWidth / 2, _ring);
    canvas.restore();
    canvas.drawPath(_partials[(p * _steps).round()], _ink);
  }

  @override
  bool shouldRepaint(CheckPainter old) =>
      old.progress != progress || old.extent != extent || old.fill != fill || old.ink != ink || old.ring != ring;
}
