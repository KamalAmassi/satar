import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:project/core/animations/fly_to_cart/cart_target.dart';
import 'package:project/core/design/icons.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/motion/motion_settings.dart';
import 'package:project/core/utils/haptics.dart';
import 'package:project/core/widgets/product_hero.dart';

/// مصدر طيران: مفتاح الصورة (أو الزر) + الصورة المحمّلة مسبقًا (اختيارية).
typedef FlySource = ({GlobalKey sourceKey, ImageProvider? image});

/// شكل العنصر الطائر: حقيبة سطر (الافتراضي، نفس أيقونة السلة) أو صورة المنتج.
enum FlyStyle { bag, image }

/// كل توقيتات ومقاييس الطيران في مكان واحد.
abstract final class FlyToCartConfig {
  static const flightDuration = Duration(milliseconds: 1100);
  static const bumpDuration = Duration(milliseconds: 450);
  static const staggerGap = Duration(milliseconds: 140);
  static const launchPause = Duration(milliseconds: 120);
  static const curve = Curves.easeInOutCubic;
  static const markerSize = 36.0;
  static const endSize = 22.0;

  /// لحظة الوصول (نسبة من الطيران) ⇒ نبضة السلة + الشارة.
  static const reachAt = 0.92;
  static const fadeStart = 0.9;
  static const trailCount = 5;
  static const trailStep = 0.045;
}

/// «طيران إلى السلة»: حقيبة سطر تطير على منحنى بيزييه تربيعي إلى السلة.
/// الوجهة: أيقونة السلة إن ظهرت، وإلا شريط السلة السفلي، وإلا نقطة ثابتة أسفل الشاشة ⇒ يعمل من أي صفحة.
/// الإحداثيات عامة (لا تعتمد على اتجاه النص)، ونقص المصدر/Overlay ⇒ نبضة فقط بلا طيران.
abstract final class FlyToCart {
  static const maxConcurrent = 3;
  static int _active = 0;

  @visibleForTesting
  static int get active => _active;

  /// نفس مزوّد صورة ProductArt (Image.network + cacheWidth) ⇒ من ذاكرة الصور بلا تنزيل جديد.
  static ImageProvider? productImage(BuildContext context, GlobalKey sourceKey, String? url, {int? decodeWidth}) {
    if (url == null || url.isEmpty) return null;
    var w = decodeWidth;
    if (w == null) {
      final box = sourceKey.currentContext?.findRenderObject();
      if (box is RenderBox && box.hasSize) w = productImageCacheWidth(box.size.width, MediaQuery.devicePixelRatioOf(context));
    }
    return ResizeImage.resizeIfNeeded(w, null, NetworkImage(url));
  }

  /// طيران واحد. [onArrived] يُستدعى دائمًا (فورًا عند التخطي).
  static void run(BuildContext context, {required GlobalKey sourceKey, ImageProvider? image, FlyStyle style = FlyStyle.bag, VoidCallback? onArrived}) {
    if (MotionSettings.of(context).reduceMotion) {
      onArrived?.call();
      return;
    }
    if (!_launch(context, sourceKey, image, style, onReach: () => _arrive(onArrived))) _arrive(onArrived);
  }

  /// «أضف الكل»: حتى 3 علامات متتابعة (staggerGap) ثم نبضة واحدة بعد وصول الأخيرة.
  static void runMany(BuildContext context, List<FlySource> sources, {FlyStyle style = FlyStyle.bag, VoidCallback? onArrived}) {
    final list = sources.take(maxConcurrent).toList();
    if (list.isEmpty) {
      _arrive(onArrived);
      return;
    }
    if (MotionSettings.of(context).reduceMotion) {
      onArrived?.call();
      return;
    }
    var remaining = list.length;
    void done() {
      if (--remaining == 0) _arrive(onArrived);
    }

    // لا وجهة ظاهرة ⇒ لا طيران إطلاقًا، نبضة واحدة فقط.
    if (!_launch(context, list.first.sourceKey, list.first.image, style, onReach: done)) {
      _arrive(onArrived);
      return;
    }
    for (var i = 1; i < list.length; i++) {
      final s = list[i];
      Future<void>.delayed(FlyToCartConfig.staggerGap * i, () {
        if (!context.mounted || !_launch(context, s.sourceKey, s.image, style, onReach: done)) done();
      });
    }
  }

  static void _arrive(VoidCallback? onArrived) {
    CartTarget.bump();
    Haptics.tap();
    onArrived?.call();
  }

  /// يُدرج الطيران؛ false إن تعذّر (المصدر/الوجهة غير ظاهرين، أو تجاوز الحد المتزامن).
  static bool _launch(BuildContext context, GlobalKey sourceKey, ImageProvider? image, FlyStyle style, {required VoidCallback onReach}) {
    if (_active >= maxConcurrent || !context.mounted) return false;
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    final src = _rectOf(sourceKey);
    if (overlay == null || src == null) return false;
    final ob = overlay.context.findRenderObject();
    if (ob is! RenderBox || !ob.hasSize) return false;
    final origin = ob.localToGlobal(Offset.zero);
    final screen = origin & ob.size;
    if (!screen.overlaps(src)) return false;
    // لا أيقونة/شريط سلة ظاهر (مثلًا خرجت بالتمرير) ⇒ نقطة ثابتة أسفل الشاشة فوق شريط التبويب.
    final dst = CartTarget.rect(within: screen) ??
        Rect.fromCenter(center: Offset(screen.center.dx, screen.bottom - MediaQuery.paddingOf(context).bottom - 96), width: 44, height: 44);

    _active++;
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _Flight(
        from: src.shift(-origin),
        to: dst.shift(-origin),
        image: image,
        style: style,
        onReach: onReach,
        onDone: () {
          if (entry.mounted) entry.remove();
        },
        onDispose: () => _active = math.max(0, _active - 1),
      ),
    );
    overlay.insert(entry);
    return true;
  }

  static Rect? _rectOf(GlobalKey key) {
    final box = key.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }
}

class _Flight extends StatefulWidget {
  const _Flight({
    required this.from,
    required this.to,
    required this.image,
    required this.style,
    required this.onReach,
    required this.onDone,
    required this.onDispose,
  });
  final Rect from;
  final Rect to;
  final ImageProvider? image;
  final FlyStyle style;
  final VoidCallback onReach;
  final VoidCallback onDone;
  final VoidCallback onDispose;

  @override
  State<_Flight> createState() => _FlightState();
}

class _FlightState extends State<_Flight> with SingleTickerProviderStateMixin {
  static const _pauseMs = 120;
  static const _flightMs = 1100;
  static const _totalMs = _pauseMs + _flightMs;

  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: _totalMs));
  late final Offset _p0 = widget.from.center;
  late final Offset _p2 = widget.to.center;
  // نقطة التحكم أعلى بوضوح ⇒ قوس ظاهر.
  late final Offset _p1 = Offset((_p0.dx + _p2.dx) / 2, math.min(_p0.dy, _p2.dy) - math.max(90.0, (_p2 - _p0).distance * 0.4));
  late final bool _bag = widget.style == FlyStyle.bag;
  late final double _startSize = _bag ? FlyToCartConfig.markerSize : math.min(widget.from.width, widget.from.height).clamp(FlyToCartConfig.endSize, 160.0);
  late final double _endSize = _bag ? FlyToCartConfig.endSize : 24.0;
  bool _reached = false;

  @override
  void initState() {
    super.initState();
    assert(FlyToCartConfig.launchPause.inMilliseconds == _pauseMs && FlyToCartConfig.flightDuration.inMilliseconds == _flightMs);
    _c.addListener(() {
      if (!_reached && _linear >= FlyToCartConfig.reachAt) {
        _reached = true;
        widget.onReach();
      }
    });
    _c.forward().whenComplete(() {
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    widget.onDispose();
    super.dispose();
  }

  double get _elapsedMs => _c.value * _totalMs;

  /// تقدّم الطيران الخطي 0..1 (بعد التوقف الإطلاقي).
  double get _linear => ((_elapsedMs - _pauseMs) / _flightMs).clamp(0.0, 1.0);

  Offset _pos(double t) {
    final u = 1 - t;
    return _p0 * (u * u) + _p1 * (2 * u * t) + _p2 * (t * t);
  }

  Widget _marker(BuildContext context) {
    final c = context.sc;
    final deco = BoxDecoration(
      shape: BoxShape.circle,
      color: _bag ? c.pri : c.sf2,
      border: _bag ? null : Border.all(color: c.sf, width: 2),
      boxShadow: [BoxShadow(color: c.shadow, blurRadius: 12, offset: const Offset(0, 4))],
    );
    if (_bag) {
      return DecoratedBox(
        decoration: deco,
        child: Center(child: SIcon('bag', size: 20, color: c.onPri)),
      );
    }
    final fallback = Center(child: SIcon('box', size: 20, color: c.plumInk));
    return Container(
      decoration: deco,
      clipBehavior: Clip.antiAlias,
      child: widget.image == null ? fallback : Image(image: widget.image!, fit: BoxFit.cover, gaplessPlayback: true, errorBuilder: (_, __, ___) => fallback),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final marker = FittedBox(child: SizedBox(width: _startSize, height: _startSize, child: _marker(context)));
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _c,
          child: marker,
          builder: (_, child) {
            final lin = _linear;
            final t = FlyToCartConfig.curve.transform(lin);
            final p = _pos(t);
            final inPause = _elapsedMs < _pauseMs;
            final pop = inPause ? Curves.easeOut.transform((_elapsedMs / _pauseMs).clamp(0.0, 1.0)) : 1.0;
            final size = (_startSize + (_endSize - _startSize) * t) * (0.6 + 0.4 * pop);
            const fade = FlyToCartConfig.fadeStart;
            final opacity = lin < fade ? 1.0 : (1 - (lin - fade) / (1 - fade)).clamp(0.0, 1.0);
            // الحقيبة تتمايل برفق أثناء الطيران (لا تدور كالسهم)، والصورة تميل قليلًا.
            final angle = _bag ? math.sin(t * math.pi * 2) * 0.22 : 0.15 * t;
            final trail = <Widget>[];
            if (_bag && !inPause) {
              for (var i = FlyToCartConfig.trailCount; i >= 1; i--) {
                final tt = t - i * FlyToCartConfig.trailStep;
                if (tt <= 0) continue;
                final k = (i - 1) / (FlyToCartConfig.trailCount - 1); // 0 = الأقرب، 1 = الأبعد
                final ts = size * (0.5 - 0.3 * k);
                final tp = _pos(tt);
                trail.add(Positioned(
                  left: tp.dx - ts / 2,
                  top: tp.dy - ts / 2,
                  width: ts,
                  height: ts,
                  child: DecoratedBox(decoration: BoxDecoration(shape: BoxShape.circle, color: c.pri.withValues(alpha: (0.45 - 0.4 * k) * opacity))),
                ));
              }
            }
            return Stack(children: [
              ...trail,
              Positioned(
                left: p.dx - size / 2,
                top: p.dy - size / 2,
                width: size,
                height: size,
                child: Opacity(opacity: opacity, child: Transform.rotate(angle: angle, child: child)),
              ),
            ]);
          },
        ),
      ),
    );
  }
}
