import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:project/core/animations/fly_to_cart/fly_to_cart.dart' show FlyToCartConfig;
import 'package:project/core/motion/motion_settings.dart';

/// سجلّ عالمي لأيقونة السلة الظاهرة (وجهة الطيران) + نبضة الوصول.
abstract final class CartTarget {
  static final List<GlobalKey> _keys = [];

  /// يزداد عند كل وصول؛ كل [CartTargetAnchor] يستمع وينبض.
  static final RxInt bumpTick = 0.obs;

  static void _register(GlobalKey k) => _keys.add(k);
  static void _unregister(GlobalKey k) => _keys.remove(k);

  static void bump() => bumpTick.value++;

  /// مستطيل الأيقونة (إحداثيات عامة) في المسار الحالي فقط؛ null إن لم تكن ظاهرة.
  static Rect? rect() {
    for (final k in _keys.reversed) {
      final ctx = k.currentContext;
      if (ctx == null) continue;
      if (!(ModalRoute.of(ctx)?.isCurrent ?? true)) continue;
      final box = ctx.findRenderObject();
      if (box is! RenderBox || !box.attached || !box.hasSize) continue;
      return box.localToGlobal(Offset.zero) & box.size;
    }
    return null;
  }

  @visibleForTesting
  static void resetForTest() {
    _keys.clear();
    bumpTick.value = 0;
  }
}

/// يغلّف أيقونة السلة الموجودة: يسجّل مفتاحها وينبض (elasticOut) عند الوصول. بلا تغيير في التخطيط.
class CartTargetAnchor extends StatefulWidget {
  const CartTargetAnchor({super.key, required this.child});
  final Widget child;

  @override
  State<CartTargetAnchor> createState() => _CartTargetAnchorState();
}

class _CartTargetAnchorState extends State<CartTargetAnchor> with SingleTickerProviderStateMixin {
  final _key = GlobalKey(debugLabel: 'cart-target');
  late final AnimationController _c = AnimationController(vsync: this, duration: FlyToCartConfig.bumpDuration);
  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25).chain(CurveTween(curve: Curves.easeOut)), weight: 30),
    TweenSequenceItem(tween: Tween(begin: 1.25, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)), weight: 70),
  ]).animate(_c);
  Worker? _worker;

  @override
  void initState() {
    super.initState();
    CartTarget._register(_key);
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
