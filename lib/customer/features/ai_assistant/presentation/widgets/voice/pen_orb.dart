import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/customer/features/ai_assistant/presentation/controllers/voice_controller.dart';
import 'package:project/customer/features/ai_assistant/presentation/widgets/voice/voice_wave.dart';

/// مسرح المساعد: القلم "قلم" + حلقات الحبر + أمواج الحبر، بـ Ticker واحد و CustomPainter واحد.
/// [micLevel] و[speaking] تُقرأ كل إطار دون إعادة بناء الشجرة. يحترم disableAnimations.
class VoiceStage extends StatefulWidget {
  const VoiceStage({super.key, required this.state, required this.micLevel, required this.speaking, required this.semanticLabel, this.onTap});

  final VoiceState state;
  final double Function() micLevel;
  final bool Function() speaking;
  final String semanticLabel;
  final VoidCallback? onTap;

  @override
  State<VoiceStage> createState() => _VoiceStageState();
}

class _VoiceStageState extends State<VoiceStage> with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_tick);
  final _clock = ValueNotifier<double>(0);
  final _m = _Motion();
  Duration _last = Duration.zero;
  bool _reduce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (_reduce) {
      _ticker.stop();
      _m.snap(widget.state);
      _clock.value = _clock.value + 1e-6; // يعيد الرسم بحالة ثابتة.
    } else if (!_ticker.isActive) {
      _ticker.start();
    }
  }

  @override
  void didUpdateWidget(VoiceStage old) {
    super.didUpdateWidget(old);
    if (_reduce) {
      _m.snap(widget.state);
      _clock.value = _clock.value + 1e-6;
    }
  }

  void _tick(Duration d) {
    final dt = ((d - _last).inMicroseconds / 1e6).clamp(0.0, 0.05);
    _last = d;
    _m.step(dt, d.inMicroseconds / 1e6, widget.state, widget.micLevel(), widget.speaking());
    _clock.value = d.inMicroseconds / 1e6;
  }

  @override
  void dispose() {
    _ticker.dispose();
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Semantics(
      label: widget.semanticLabel,
      button: widget.onTap != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: RepaintBoundary(
          child: CustomPaint(
            size: Size.infinite,
            painter: _StagePainter(_clock, _m, c, widget.state),
          ),
        ),
      ),
    );
  }
}

/// حالة الحركة المنعّمة: أوزان الحالات تتمازج خلال ~350ms بلا قفز.
class _Motion {
  static const _blendSeconds = 0.35;
  double listen = 0, think = 0, speak = 0, err = 0;
  double amp = 0; // سعة الموجة المنعّمة.
  double mic = 0;
  double t = 0;

  void snap(VoiceState s) {
    listen = s == VoiceState.listening ? 1 : 0;
    think = s == VoiceState.thinking ? 1 : 0;
    speak = 0;
    err = s == VoiceState.error ? 1 : 0;
    amp = 0;
    mic = 0;
    t = 0;
  }

  double _to(double v, bool on, double dt) {
    final step = dt / _blendSeconds;
    return on ? math.min(1, v + step) : math.max(0, v - step);
  }

  void step(double dt, double time, VoiceState s, double micLevel, bool speaking) {
    t = time;
    listen = _to(listen, s == VoiceState.listening, dt);
    think = _to(think, s == VoiceState.thinking, dt);
    speak = _to(speak, s == VoiceState.speaking, dt);
    err = _to(err, s == VoiceState.error, dt);
    mic += (micLevel - mic) * math.min(1, dt * 12);
    // TTS لا يعطي مستوى صوت: غلاف سعة طبيعي من جيوب جيبية، صعود سريع وهبوط أبطأ.
    final env = speaking ? (0.5 + 0.28 * math.sin(time * 5.1) + 0.18 * math.sin(time * 8.7 + 1.3) + 0.1 * math.sin(time * 13.3 + 0.4)).clamp(0.0, 1.0) : 0.0;
    final target = math.max(env * speak, mic * listen * 0.8);
    amp += (target - amp) * math.min(1, dt * (target > amp ? 14 : 4));
  }
}

class _StagePainter extends CustomPainter {
  _StagePainter(Listenable clock, this.m, this.c, this.state) : super(repaint: clock);

  final _Motion m;
  final SatrColors c;
  final VoiceState state;

  @override
  void paint(Canvas canvas, Size size) {
    final t = m.t;
    final err = m.err;
    Color mute(Color x) => Color.lerp(x, c.tx3, err * 0.7)!;
    final cx = size.width / 2;
    final float = math.sin(t * 2 * math.pi / 3) * 4 * (1 - m.speak);
    final cy = size.height * 0.46 + float;
    final shake = math.sin(t * 38) * 5 * err;
    final lean = -0.14 * m.listen + 0.04 * math.sin(t * 6) * m.speak;
    final pulse = 1 + 0.035 * m.amp * m.speak;

    paintInkWaves(canvas, size, t: t, amp: m.amp * m.speak, a: mute(c.pri), b: mute(c.priHi), opacity: m.speak.clamp(0.0, 1.0));

    const bodyW = 58.0, bodyH = 132.0, nibH = 40.0;
    canvas.save();
    canvas.translate(cx + shake, cy);
    canvas.rotate(lean);
    canvas.scale(pulse);
    // نحسب موضع السن في إحداثيات الشاشة لحلقات الحبر.
    final tipLocal = const Offset(0, bodyH / 2 + nibH);
    final cosL = math.cos(lean), sinL = math.sin(lean);
    final tip = Offset(cx + shake + (tipLocal.dx * cosL - tipLocal.dy * sinL) * pulse, cy + (tipLocal.dx * sinL + tipLocal.dy * cosL) * pulse);

    final body = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: bodyW, height: bodyH), const Radius.circular(22));
    final shadow = Paint()..color = c.shadow..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawRRect(body.shift(const Offset(0, 8)), shadow);
    canvas.drawRRect(body, Paint()..color = mute(c.pri));
    // شريط الغطاء.
    final band = RRect.fromRectAndRadius(Rect.fromLTWH(-bodyW / 2, -bodyH / 2 + 18, bodyW, 14), const Radius.circular(4));
    canvas.drawRRect(band, Paint()..color = mute(c.coralTag));
    // لمعان يتحرك على الجسم (shimmer خفيف أثناء التفكير).
    final shimmerY = -bodyH / 2 + ((t * 0.7) % 1.0) * bodyH;
    canvas.save();
    canvas.clipRRect(body);
    canvas.drawRect(Rect.fromLTWH(-bodyW / 2, shimmerY - 10, bodyW, 20), Paint()..color = c.onPri.withValues(alpha: 0.18 * m.think));
    canvas.drawRect(Rect.fromLTWH(-bodyW / 2 + 8, -bodyH / 2 + 8, 7, bodyH - 16), Paint()..color = c.onPri.withValues(alpha: 0.14));
    canvas.restore();
    // السن.
    final nib = Path()
      ..moveTo(-bodyW / 2 + 8, bodyH / 2 - 2)
      ..lineTo(bodyW / 2 - 8, bodyH / 2 - 2)
      ..lineTo(0, bodyH / 2 + nibH)
      ..close();
    canvas.drawPath(nib, Paint()..color = mute(c.hero));
    final glow = 0.5 + 0.5 * math.sin(t * 2.2);
    final glint = (0.25 + 0.2 * glow) * (1 - m.listen) + 0.9 * m.listen;
    canvas.drawCircle(const Offset(0, bodyH / 2 + nibH - 4), 4 + 3 * m.listen, Paint()..color = c.amber.withValues(alpha: glint * (1 - err)));
    // الوجه: عينان وابتسامة (تتغير حسب الحالة).
    final eyeY = 18.0 + 4 * m.think;
    final blink = (math.sin(t * 1.3) > 0.985 ? 0.15 : 1.0);
    final eye = Paint()..color = c.onPri;
    canvas.drawOval(Rect.fromCenter(center: Offset(-11, eyeY), width: 8, height: 11 * blink), eye);
    canvas.drawOval(Rect.fromCenter(center: Offset(11, eyeY), width: 8, height: 11 * blink), eye);
    final mouthOpen = 3 + 9 * m.amp * m.speak;
    final mouth = Paint()
      ..color = c.onPri
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final my = eyeY + 18;
    if (m.speak > 0.3) {
      canvas.drawOval(Rect.fromCenter(center: Offset(0, my), width: 14, height: mouthOpen), Paint()..color = c.onPri);
    } else if (err > 0.5) {
      canvas.drawArc(Rect.fromCenter(center: Offset(0, my + 4), width: 18, height: 10), math.pi, math.pi, false, mouth);
    } else {
      canvas.drawArc(Rect.fromCenter(center: Offset(0, my - 2), width: 18, height: 10), 0, math.pi, false, mouth);
    }
    canvas.restore();

    // حلقات الحبر من السن تتبع مستوى الميكروفون الحقيقي.
    if (m.listen > 0.01) {
      for (var i = 0; i < 3; i++) {
        final p = ((t * 0.8) + i / 3) % 1.0;
        final r = 14 + p * (50 + 70 * m.mic);
        final a = (1 - p) * (0.2 + 0.5 * m.mic) * m.listen;
        canvas.drawCircle(
          tip,
          r,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5
            ..color = c.pri.withValues(alpha: a.clamp(0.0, 1.0)),
        );
      }
    }

    // التفكير: القلم "يكتب" خطًا متعرجًا + 3 نقاط حبر تدور.
    if (m.think > 0.01) {
      final p = (t * 0.55) % 1.0;
      final path = Path();
      const w = 130.0;
      for (var i = 0; i <= 40 * p; i++) {
        final x = -w / 2 + w * (i / 40);
        final y = math.sin(i * 0.55) * 7;
        i == 0 ? path.moveTo(tip.dx + x, tip.dy + 10 + y) : path.lineTo(tip.dx + x, tip.dy + 10 + y);
      }
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..color = c.pri.withValues(alpha: 0.8 * m.think),
      );
      for (var i = 0; i < 3; i++) {
        final ang = t * 2.4 + i * 2 * math.pi / 3;
        canvas.drawCircle(Offset(cx + math.cos(ang) * 92, cy + math.sin(ang) * 92 * 0.55), 5, Paint()..color = c.coralTag.withValues(alpha: 0.75 * m.think));
      }
    }
  }

  @override
  bool shouldRepaint(_StagePainter old) => old.state != state || old.c != c;
}
