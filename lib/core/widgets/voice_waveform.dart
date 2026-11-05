import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show PointMode;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:project/core/design/motion.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/motion/frame_throttle.dart';

export 'package:project/core/motion/frame_throttle.dart';

/// مخزن حلقي لمستويات الصوت مع قناة عرض منعّمة موازية.
/// الفهرس 0 = الأقدم، capacity - 1 = الأحدث. الخانات غير المملوءة تقرأ 0.
class WaveformBuffer {
  WaveformBuffer(this.capacity)
      : assert(capacity > 0),
        _target = Float32List(capacity),
        _display = Float32List(capacity);

  final int capacity;
  final Float32List _target;
  final Float32List _display;
  int _head = 0; // موضع الكتابة التالية
  int _count = 0;

  int get length => _count;

  int _index(int i) => (_head + i) % capacity;

  double target(int i) => _target[_index(i)];

  double display(int i) => _display[_index(i)];

  void push(double level) {
    _target[_head] = level.isNaN ? 0 : level.clamp(0.0, 1.0);
    _display[_head] = 0; // العمود الجديد ينمو عبر الـ attack
    _head = (_head + 1) % capacity;
    if (_count < capacity) _count++;
  }

  /// يقرّب قيم العرض من الأهداف. يعيد true ما دام هناك عمود يتحرك.
  bool step(LevelSmoother smoother, double dtSeconds) {
    var moving = false;
    for (var i = 0; i < capacity; i++) {
      final next = smoother.next(_display[i], _target[i], dtSeconds);
      _display[i] = next;
      if ((next - _target[i]).abs() > 1e-3) moving = true;
    }
    return moving;
  }

  void clear() {
    _target.fillRange(0, capacity, 0);
    _display.fillRange(0, capacity, 0);
    _head = 0;
    _count = 0;
  }
}

/// تنعيم أسّي: صعود سريع (attack) وهبوط أبطأ (release).
class LevelSmoother {
  const LevelSmoother({required this.attack, required this.release});

  final Duration attack;
  final Duration release;

  double next(double current, double target, double dtSeconds) {
    if (dtSeconds <= 0) return current;
    final tau = (target > current ? attack : release).inMicroseconds / 1e6;
    if (tau <= 0) return target;
    final k = 1 - math.exp(-dtSeconds / tau);
    return current + (target - current) * k;
  }
}

/// موجة صوتية حيّة عامة: أعمدة دائرية متناظرة، الأحدث على الطرف النهائي (يحترم RTL).
/// تشترك في [levels] فقط أثناء [active]، وعند الإيقاف تتجمد قليلًا ثم تتلاشى.
class VoiceWaveform extends StatefulWidget {
  const VoiceWaveform({
    super.key,
    required this.levels,
    required this.active,
    this.height = 48,
    this.barCount = 40,
    this.color,
  }) : assert(barCount > 0);

  /// مستويات من 0 إلى 1.
  final Stream<double> levels;
  final bool active;
  final double height;
  final int barCount;

  /// افتراضيًا: لون العلامة context.sc.pri.
  final Color? color;

  @override
  State<VoiceWaveform> createState() => _VoiceWaveformState();
}

class _VoiceWaveformState extends State<VoiceWaveform> with SingleTickerProviderStateMixin {
  static const _smoother = LevelSmoother(attack: Motion.waveAttack, release: Motion.waveRelease);

  late WaveformBuffer _buffer = WaveformBuffer(widget.barCount);
  final _throttle = FrameThrottle(Motion.waveFrame);
  final _time = ValueNotifier<double>(0); // إشارة إعادة الرسم الوحيدة
  late final Ticker _ticker = createTicker(_onTick);
  StreamSubscription<double>? _sub;
  Timer? _freeze;
  Duration _lastFrame = Duration.zero;
  late bool _visible = widget.active;
  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    _sync();
  }

  @override
  void didUpdateWidget(VoiceWaveform old) {
    super.didUpdateWidget(old);
    if (old.barCount != widget.barCount) _buffer = WaveformBuffer(widget.barCount);
    if (old.levels != widget.levels) _unsubscribe();
    if (old.active != widget.active || old.levels != widget.levels || old.barCount != widget.barCount) _sync();
  }

  void _sync() {
    if (widget.active && !_reduceMotion) {
      _freeze?.cancel();
      _visible = true;
      if (_sub == null) {
        _buffer.clear();
        _subscribe();
      }
      if (!_ticker.isActive) {
        _throttle.reset();
        _lastFrame = Duration.zero;
        _ticker.start();
      }
    } else if (widget.active) {
      // تقليل الحركة: أعمدة ثابتة بلا اشتراك ولا ticker.
      _freeze?.cancel();
      _unsubscribe();
      _ticker.stop();
      _visible = true;
    } else {
      _unsubscribe();
      _ticker.stop(); // تجميد آخر إطار
      if (_visible && (_freeze == null || !_freeze!.isActive)) {
        _freeze = Timer(_reduceMotion ? Duration.zero : Motion.waveFreeze, () {
          if (mounted) setState(() => _visible = false);
        });
      }
    }
  }

  void _subscribe() {
    // الويب/ويندوز: إن لم تصل مستويات أو حدث خطأ نبقى على خط الخمول بصمت.
    _sub = widget.levels.listen(_buffer.push, onError: (Object _) {}, cancelOnError: false);
  }

  void _unsubscribe() {
    _sub?.cancel();
    _sub = null;
  }

  void _onTick(Duration elapsed) {
    if (!_throttle.shouldEmit(elapsed)) return;
    final dt = ((elapsed - _lastFrame).inMicroseconds / 1e6).clamp(0.0, 0.1);
    _lastFrame = elapsed;
    _buffer.step(_smoother, dt);
    _time.value = elapsed.inMicroseconds / 1e6;
  }

  @override
  void dispose() {
    _freeze?.cancel();
    _unsubscribe();
    _ticker.dispose();
    _time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? context.sc.pri;
    return ExcludeSemantics(
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: _reduceMotion ? Duration.zero : Motion.waveFade,
        curve: Curves.easeOut,
        child: RepaintBoundary(
          child: SizedBox(
            height: widget.height,
            width: double.infinity,
            child: CustomPaint(
              painter: _WavePainter(
                buffer: _buffer,
                time: _time,
                color: color,
                rtl: Directionality.of(context) == TextDirection.rtl,
                isStatic: _reduceMotion,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter({
    required this.buffer,
    required this.time,
    required this.color,
    required this.rtl,
    required this.isStatic,
  }) : super(repaint: time) {
    final n = buffer.capacity;
    _bandStart[1] = (n * .6).round().clamp(0, n);
    _bandStart[2] = (n * .85).round().clamp(_bandStart[1], n);
    _bandStart[3] = n;
    for (var b = 0; b < _bands; b++) {
      _points[b] = Float32List(4 * (_bandStart[b + 1] - _bandStart[b]));
      _paints[b] = Paint()
        ..color = color.withValues(alpha: color.a * _alphas[b])
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
    }
  }

  static const _bands = 3;
  static const _alphas = [.45, .7, 1.0]; // الأحدث أقوى
  static const _slotFill = .55;
  static const _idleRatio = .08;
  static const _idleSpeed = 2.4;

  final WaveformBuffer buffer;
  final ValueNotifier<double> time;
  final Color color;
  final bool rtl;
  final bool isStatic;

  // كل التخصيصات هنا (عند الإنشاء) — لا شيء داخل paint.
  final _bandStart = List<int>.filled(_bands + 1, 0);
  final _points = List<Float32List>.filled(_bands, Float32List(0));
  final _paints = List<Paint>.filled(_bands, Paint());

  @override
  void paint(Canvas canvas, Size size) {
    final n = buffer.capacity;
    if (size.isEmpty) return;
    final slot = size.width / n;
    final mid = size.height / 2;
    final stroke = math.min(slot * _slotFill, mid);
    final maxHalf = math.max(0.0, mid - stroke / 2); // الأطراف الدائرية تضيف stroke/2
    final idleHalf = maxHalf * _idleRatio;
    final t = time.value;

    for (var b = 0; b < _bands; b++) {
      final pts = _points[b];
      final start = _bandStart[b];
      for (var i = start; i < _bandStart[b + 1]; i++) {
        final double half;
        if (isStatic) {
          half = maxHalf * (.25 + .2 * math.sin(i * .7));
        } else {
          final idle = idleHalf * (.6 + .4 * math.sin(t * _idleSpeed + i * .45));
          half = math.max(idle, buffer.display(i) * maxHalf);
        }
        final x = rtl ? size.width - (i + .5) * slot : (i + .5) * slot;
        final o = (i - start) * 4;
        pts[o] = x;
        pts[o + 1] = mid - half;
        pts[o + 2] = x;
        pts[o + 3] = mid + half;
      }
      if (pts.isEmpty) continue;
      _paints[b].strokeWidth = stroke;
      canvas.drawRawPoints(PointMode.lines, pts, _paints[b]);
    }
  }

  @override
  bool shouldRepaint(_WavePainter old) =>
      old.buffer != buffer || old.color != color || old.rtl != rtl || old.isStatic != isStatic || old.time != time;
}
