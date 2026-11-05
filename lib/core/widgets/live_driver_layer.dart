import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:project/core/design/icons.dart';
import 'package:project/core/design/motion.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/map/driver_motion.dart';
import 'package:project/core/motion/frame_throttle.dart';
import 'package:project/core/motion/motion_settings.dart';

/// طبقة السائق الحية لـ flutter_map: انزلاق بين التحديثات، دوران بأقصر زاوية، ونبض حلقات.
///
/// - العلامة عنصر Flutter عادي يضعه MarkerLayer بالبكسل المنطقي ⇒ لا حاجة لتحويل إحداثيات/DPR.
/// - طبقة مستقلة: الانزلاق يعيد بناء هذه الطبقة فقط (≤30 إطار/ث ولمدة الانزلاق فقط)،
///   والنبض إعادة رسم فقط داخل RepaintBoundary صغير.
/// - يتوقف النبض عند: قِدم الموقع، انتهاء الطلب ([live] = false)، خلفية التطبيق،
///   إخفاء المسار (TickerMode)، أو تقليل الحركة (حلقة ثابتة).
class LiveDriverLayer extends StatefulWidget {
  const LiveDriverLayer({
    super.key,
    required this.position,
    this.heading,
    this.seenAt,
    this.live = true,
    this.dotSize = 36,
  });

  final LatLng position;

  /// الاتجاه بالدرجات (0 = شمال). null ⇒ يُستنتج من الحركة.
  final double? heading;

  /// وقت آخر موقع. null ⇒ الحداثة غير معروفة (لا يُعرض كقديم).
  final DateTime? seenAt;

  /// false عند انتهاء الطلب: لا نبض.
  final bool live;
  final double dotSize;

  @override
  State<LiveDriverLayer> createState() => _LiveDriverLayerState();
}

enum _RingMode { animated, still, none }

class _LiveDriverLayerState extends State<LiveDriverLayer> with TickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _glide = AnimationController(vsync: this, duration: Motion.driverGlide)
    ..addListener(_onGlide)
    ..addStatusListener(_onGlideStatus);
  late final AnimationController _pulse = AnimationController(vsync: this, duration: Motion.driverPulse)..addListener(_onPulse);
  final _glideThrottle = FrameThrottle(Motion.mapFrame);
  final _pulseThrottle = FrameThrottle(Motion.mapFrame);

  late final ValueNotifier<LatLng> _point = ValueNotifier(widget.position);
  late final ValueNotifier<double> _angle = ValueNotifier(normalizeDeg(widget.heading ?? 0));
  final _phase = ValueNotifier<double>(0);

  late LatLng _from = widget.position;
  late LatLng _to = widget.position;
  late double _fromAngle = _angle.value;
  late double _toAngle = _angle.value;

  Timer? _recheck;
  DriverFreshness _fresh = DriverFreshness.live;
  bool _foreground = true;
  bool _reduce = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fresh = _compute();
    _recheck = Timer.periodic(Motion.freshnessRecheck, (_) => _refreshFreshness());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduce = MotionSettings.of(context).reduceMotion;
    _syncPulse();
  }

  @override
  void didUpdateWidget(LiveDriverLayer old) {
    super.didUpdateWidget(old);
    if (old.position != widget.position) {
      _moveTo(widget.position, widget.heading);
    } else if (widget.heading != null && widget.heading != old.heading && !_glide.isAnimating) {
      _moveTo(widget.position, widget.heading);
    }
    if (old.seenAt != widget.seenAt || old.live != widget.live) _refreshFreshness(force: true);
  }

  DriverFreshness _compute() => DriverStaleness.of(hasLocation: true, seenAt: widget.seenAt, now: DateTime.now());

  void _refreshFreshness({bool force = false}) {
    if (!mounted) return;
    final f = _compute();
    if (f != _fresh || force) {
      setState(() => _fresh = f); // يعيد بناء هذه الطبقة فقط
      _syncPulse();
    }
  }

  bool get _shouldPulse => widget.live && _fresh == DriverFreshness.live && _foreground && !_reduce;

  void _syncPulse() {
    if (_shouldPulse) {
      if (!_pulse.isAnimating) {
        _pulseThrottle.reset();
        _pulse.repeat();
      }
    } else if (_pulse.isAnimating) {
      _pulse.stop();
    }
  }

  void _moveTo(LatLng p, double? heading) {
    final from = _point.value;
    final target = heading ?? bearingBetween(from, p) ?? _angle.value;
    if (_reduce || DriverMotion.meters(from, p) > DriverMotion.maxGlideMeters) {
      _glide.stop();
      _from = _to = p;
      _fromAngle = _toAngle = normalizeDeg(target);
      _point.value = p;
      _angle.value = _toAngle;
      return;
    }
    _from = from;
    _to = p;
    _fromAngle = _angle.value;
    _toAngle = normalizeDeg(target);
    _glideThrottle.reset();
    _glide.forward(from: 0);
  }

  void _onGlide() {
    if (!_glideThrottle.shouldEmit(_glide.lastElapsedDuration ?? Duration.zero)) return;
    _apply(Curves.easeInOut.transform(_glide.value));
  }

  void _onGlideStatus(AnimationStatus s) {
    if (s == AnimationStatus.completed) _apply(1);
  }

  void _apply(double t) {
    _point.value = lerpLatLng(_from, _to, t);
    _angle.value = lerpAngle(_fromAngle, _toAngle, t);
  }

  void _onPulse() {
    if (!_pulseThrottle.shouldEmit(_pulse.lastElapsedDuration ?? Duration.zero)) return;
    _phase.value = _pulse.value;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _syncPulse();
    if (_foreground) _refreshFreshness();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _recheck?.cancel();
    _glide.dispose();
    _pulse.dispose();
    _point.dispose();
    _angle.dispose();
    _phase.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final stale = _fresh != DriverFreshness.live;
    final mode = stale || !widget.live
        ? _RingMode.none
        : (_reduce ? _RingMode.still : _RingMode.animated);
    final dot = widget.dotSize;
    final extent = dot * DriverMotion.ringExtentFactor;

    // تُبنى مرة واحدة لكل تغيّر حالة؛ الانزلاق يعيد تموضعها فقط.
    final marker = Semantics(
      label: context.l10n.driverMarkerSemantics,
      child: SizedBox.square(
        dimension: extent,
        child: Stack(alignment: Alignment.center, children: [
          RepaintBoundary(
            child: CustomPaint(
              size: Size.square(extent),
              painter: _RingsPainter(phase: _phase, color: c.pri, mode: mode, inner: dot / 2),
            ),
          ),
          AnimatedOpacity(
            opacity: stale ? .45 : 1,
            duration: _reduce ? Duration.zero : Motion.short,
            child: Container(
              width: dot,
              height: dot,
              decoration: BoxDecoration(color: stale ? c.tx3 : c.pri, shape: BoxShape.circle, border: Border.all(color: c.sf, width: 3)),
              child: ValueListenableBuilder<double>(
                valueListenable: _angle,
                builder: (_, a, child) => Transform.rotate(angle: (a - DriverMotion.iconBearing) * math.pi / 180, child: child),
                child: Center(child: SIcon('nav', size: dot * .44, color: c.onPri)),
              ),
            ),
          ),
        ]),
      ),
    );

    return ValueListenableBuilder<LatLng>(
      valueListenable: _point,
      child: marker,
      builder: (_, p, child) => MarkerLayer(markers: [Marker(point: p, width: extent, height: extent, child: child!)]),
    );
  }
}

/// ثلاث حلقات تتوسع وتتلاشى. الطلاءات محسوبة مسبقًا بدرجات شفافية؛ paint لا يخصّص شيئًا.
class _RingsPainter extends CustomPainter {
  _RingsPainter({required this.phase, required this.color, required this.mode, required this.inner}) : super(repaint: phase) {
    for (var i = 1; i <= _levels; i++) {
      final k = i / _levels;
      _fills.add(Paint()..color = color.withValues(alpha: color.a * _fillAlpha * k));
      _strokes.add(Paint()
        ..color = color.withValues(alpha: color.a * _strokeAlpha * k)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth);
    }
  }

  static const _rings = 3;
  static const _levels = 12;
  static const _fillAlpha = .16;
  static const _strokeAlpha = .45;
  static const _strokeWidth = 1.5;
  static const _stillPhase = .45;

  final ValueNotifier<double> phase;
  final Color color;
  final _RingMode mode;
  final double inner;

  final _fills = <Paint>[];
  final _strokes = <Paint>[];
  Size? _size;
  Offset _center = Offset.zero;

  @override
  void paint(Canvas canvas, Size size) {
    if (mode == _RingMode.none) return;
    if (size != _size) {
      _size = size;
      _center = size.center(Offset.zero); // يُحسب عند تغيّر الحجم فقط
    }
    final center = _center;
    final maxR = size.shortestSide / 2 - _strokeWidth;
    if (mode == _RingMode.still) {
      _ring(canvas, center, maxR, _stillPhase);
      return;
    }
    for (var k = 0; k < _rings; k++) {
      _ring(canvas, center, maxR, (phase.value + k / _rings) % 1);
    }
  }

  void _ring(Canvas canvas, Offset center, double maxR, double p) {
    final r = inner + (maxR - inner) * p;
    final level = ((1 - p) * _levels).ceil().clamp(1, _levels) - 1;
    canvas.drawCircle(center, r, _fills[level]);
    canvas.drawCircle(center, r, _strokes[level]);
  }

  @override
  bool shouldRepaint(_RingsPainter old) =>
      old.phase != phase || old.color != color || old.mode != mode || old.inner != inner;
}
