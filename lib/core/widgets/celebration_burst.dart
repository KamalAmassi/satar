import 'dart:math' as math;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:project/core/celebration/celebration.dart';
import 'package:project/core/design/motion.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/motion/motion_settings.dart';

/// انفجار احتفالي هادئ: مربعات ورق، شرطات حبر، ونجوم صغيرة بألوان الهوية.
/// يُشغَّل مرة واحدة. إن مُرّر [progress] (0..1) يستخدمه بلا Ticker خاص،
/// وإلا ينشئ AnimationController واحدًا ويتخلص منه تلقائيًا عند الانتهاء.
/// لا يُرسم شيء عند تقليل الحركة.
class CelebrationBurst extends StatefulWidget {
  const CelebrationBurst({super.key, this.progress, this.extent = 360, this.onDone});

  final Animation<double>? progress;

  /// مساحة الرسم المربعة حول نقطة الانطلاق (المركز). لا تؤثر في التخطيط.
  final double extent;
  final VoidCallback? onDone;

  @override
  State<CelebrationBurst> createState() => _CelebrationBurstState();
}

class _CelebrationBurstState extends State<CelebrationBurst> with SingleTickerProviderStateMixin {
  AnimationController? _own;
  List<Particle> _particles = const [];
  bool _done = false;
  bool _started = false;

  Animation<double> get _progress => widget.progress ?? _own!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final m = MotionSettings.of(context);
    final count = m.reduceMotion ? 0 : CelebrationConfig.particleCount(m.intensity);
    if (count == 0) {
      _done = true;
      return;
    }
    _particles = generateParticles(
      count: count,
      colors: _palette(context.sc).length,
      seconds: Motion.celebrationBurst.inMicroseconds / 1e6,
    );
    if (widget.progress == null) {
      _own = AnimationController(vsync: this, duration: Motion.celebrationBurst)..forward();
    }
    _progress.addStatusListener(_onStatus);
  }

  void _onStatus(AnimationStatus s) {
    if (s != AnimationStatus.completed || _done) return;
    _progress.removeStatusListener(_onStatus);
    _own?.dispose(); // تحرير الـ Ticker فور الانتهاء
    _own = null;
    if (mounted) setState(() => _done = true);
    widget.onDone?.call();
  }

  @override
  void dispose() {
    if (!_done) {
      (widget.progress ?? _own)?.removeStatusListener(_onStatus);
    }
    _own?.dispose();
    super.dispose();
  }

  static List<Color> _palette(SatrColors c) => [c.pri, c.amber, c.coral, c.plumInk];

  @override
  Widget build(BuildContext context) {
    if (_done) return const SizedBox.shrink();
    return IgnorePointer(
      child: ExcludeSemantics(
        child: OverflowBox(
          maxWidth: widget.extent,
          maxHeight: widget.extent,
          child: RepaintBoundary(
            child: CustomPaint(
              size: Size.square(widget.extent),
              painter: BurstPainter(
                particles: _particles,
                progress: _progress,
                colors: _palette(context.sc),
                seconds: Motion.celebrationBurst.inMicroseconds / 1e6,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// كل الكائنات (Paint، المستطيلات، المسارات) تُنشأ في المُنشئ؛ paint لا يخصّص شيئًا.
class BurstPainter extends CustomPainter {
  BurstPainter({
    required this.particles,
    required this.progress,
    required this.colors,
    required this.seconds,
  }) : super(repaint: progress) {
    for (var ci = 0; ci < colors.length; ci++) {
      for (var a = 0; a < _levels; a++) {
        final col = colors[ci].withValues(alpha: colors[ci].a * (a + 1) / _levels);
        _fill.add(Paint()..color = col);
        _stroke.add(Paint()
          ..color = col
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = _dashWidth);
      }
    }
    for (final p in particles) {
      final h = p.size / 2;
      _rects.add(Rect.fromLTRB(-h, -h * .7, h, h * .7)); // ورقة مستطيلة قليلًا
      _dashA.add(Offset(-h, 0));
      _dashB.add(Offset(h, 0));
      _stars.add(p.kind == ParticleKind.star ? _star(h) : null);
    }
  }

  static const _levels = 6;
  static const _dashWidth = 1.4;

  final List<Particle> particles;
  final Animation<double> progress;
  final List<Color> colors;
  final double seconds;

  final _fill = <Paint>[];
  final _stroke = <Paint>[];
  final _rects = <Rect>[];
  final _dashA = <Offset>[];
  final _dashB = <Offset>[];
  final _stars = <Path?>[];

  static Path _star(double r) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final rad = i.isEven ? r : r * .45;
      final a = -math.pi / 2 + i * math.pi / 5;
      final x = math.cos(a) * rad, y = math.sin(a) * rad;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    return path..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value * seconds;
    final cx = size.width / 2, cy = size.height / 2;
    for (var i = 0; i < particles.length; i++) {
      final p = particles[i];
      final lt = t - p.delay;
      if (lt <= 0 || lt >= p.life) continue;
      final fade = 1 - lt / p.life;
      final level = (fade * fade * _levels).ceil().clamp(1, _levels) - 1;
      final idx = p.colorIndex * _levels + level;
      final x = cx + p.vx * lt + p.drift * math.sin(lt * p.wobble);
      final y = cy + p.vy * lt + .5 * BurstPhysics.gravity * lt * lt;
      canvas
        ..save()
        ..translate(x, y)
        ..rotate(p.rotation + p.spin * lt);
      switch (p.kind) {
        case ParticleKind.square:
          canvas.drawRect(_rects[i], _fill[idx]);
        case ParticleKind.dash:
          canvas.drawLine(_dashA[i], _dashB[i], _stroke[idx]);
        case ParticleKind.star:
          canvas.drawPath(_stars[i]!, _fill[idx]);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(BurstPainter old) =>
      old.particles != particles || old.progress != progress || !listEquals(old.colors, colors) || old.seconds != seconds;
}
