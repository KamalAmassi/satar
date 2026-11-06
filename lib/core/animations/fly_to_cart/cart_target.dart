import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:project/core/animations/fly_to_cart/fly_to_cart.dart' show FlyToCartConfig;
import 'package:project/core/motion/motion_settings.dart';

/// سجلّ عالمي لأيقونة السلة الظاهرة (وجهة الطيران) + نبضة الوصول.
abstract final class CartTarget {
  static final List<GlobalKey> _keys = [];
  static final Set<GlobalKey> _fallbacks = {};

  /// يزداد عند كل وصول؛ كل [CartTargetAnchor] يستمع وينبض.
  static final RxInt bumpTick = 0.obs;

  static void _register(GlobalKey k, {bool fallback = false}) {
    _keys.add(k);
    if (fallback) _fallbacks.add(k);
  }

  static void _unregister(GlobalKey k) {
    _keys.remove(k);
    _fallbacks.remove(k);
  }

  static void bump() => bumpTick.value++;

  /// مستطيل وجهة الطيران (إحداثيات عامة) في المسار الحالي فقط.
  /// الأولوية: أيقونة السلة الظاهرة، ثم وجهة بديلة ظاهرة (شريط السلة السفلي).
  /// [within] = حدود الشاشة؛ ما كان خارجها (مثل أيقونة خرجت بالتمرير) يُتجاهل.
  /// null إن لم توجد وجهة ظاهرة (يستعمل الطيران حينها نقطة ثابتة أسفل الشاشة).
  static Rect? rect({Rect? within}) {
    for (final fallbackPass in const [false, true]) {
      for (final k in _keys.reversed) {
        if (_fallbacks.contains(k) != fallbackPass) continue;
        final ctx = k.currentContext;
        if (ctx == null) continue;
        if (!(ModalRoute.of(ctx)?.isCurrent ?? true)) continue;
        final box = ctx.findRenderObject();
        if (box is! RenderBox || !box.attached || !box.hasSize) continue;
        final r = box.localToGlobal(Offset.zero) & box.size;
        if (within != null && !within.overlaps(r)) continue;
        return r;
      }
    }
    return null;
  }

  @visibleForTesting
  static void resetForTest() {
    _keys.clear();
    _fallbacks.clear();
    bumpTick.value = 0;
  }
}

/// يغلّف أيقونة السلة الموجودة: يسجّل مفتاحها وينبض (elasticOut) عند الوصول. بلا تغيير في التخطيط.
class CartTargetAnchor extends StatefulWidget {
  const CartTargetAnchor({super.key, required this.child, this.fallback = false, this.bumpScale = 1.25});
  final Widget child;

  /// وجهة بديلة: تُستعمل فقط حين لا تكون أيقونة السلة الأساسية ظاهرة.
  final bool fallback;

  /// أقصى تكبير في نبضة الوصول.
  final double bumpScale;

  @override
  State<CartTargetAnchor> createState() => _CartTargetAnchorState();
}

class _CartTargetAnchorState extends State<CartTargetAnchor> with SingleTickerProviderStateMixin {
  final _key = GlobalKey(debugLabel: 'cart-target');
  late final AnimationController _c = AnimationController(vsync: this, duration: FlyToCartConfig.bumpDuration);
  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: widget.bumpScale).chain(CurveTween(curve: Curves.easeOut)), weight: 30),
    TweenSequenceItem(tween: Tween(begin: widget.bumpScale, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)), weight: 70),
  ]).animate(_c);
  Worker? _worker;

  @override
  void initState() {
    super.initState();
    CartTarget._register(_key, fallback: widget.fallback);
    _worker = ever<int>(CartTarget.bumpTick, (_) {
      if (!mounted || MotionSettings.of(context).reduceMotion) return;
      _c.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _worker?.dispose();
    CartTarget._unregister(_key);
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => KeyedSubtree(
        key: _key,
        child: ScaleTransition(scale: _scale, child: widget.child),
      );
}
