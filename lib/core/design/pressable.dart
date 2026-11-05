import 'package:flutter/gestures.dart' show kTouchSlop;
import 'package:flutter/widgets.dart';
import 'package:project/core/design/motion.dart';
import 'package:project/core/motion/motion_settings.dart';
import 'package:project/core/utils/haptics.dart';

/// ضغطة ناعمة: تصغير إلى ~0.97 ثم ارتداد نابضي سريع.
///
/// - تستمع لأحداث المؤشر الخام فقط (لا تسرق النقرة ولا تغيّر الدلالات)،
///   لذا يبقى InkWell وSemantics كما هما.
/// - تتحرر إذا تحرك الإصبع أكثر من kTouchSlop (أثناء التمرير لا تبقى مضغوطة).
/// - متحكم واحد لكل عنصر ويُتخلّص منه، مع RepaintBoundary حول المحتوى.
/// - بلا حركة إطلاقًا عند تفعيل «تقليل الحركة».
class PressableScale extends StatefulWidget {
  const PressableScale({super.key, required this.child, this.enabled = true});

  final Widget child;
  final bool enabled;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Motion.pressIn,
    reverseDuration: Motion.pressOut,
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _c,
    curve: Motion.pressInCurve,
    reverseCurve: Motion.pressOutCurve,
  );
  Animation<double>? _scale;
  double _intensity = -1;
  bool _down = false;
  Offset? _origin;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final i = MotionSettings.of(context).intensity;
    if (i != _intensity) {
      _intensity = i;
      _scale = Tween<double>(begin: 1, end: 1 - (1 - Motion.pressScale) * i).animate(_curve);
    }
  }

  @override
  void didUpdateWidget(PressableScale old) {
    super.didUpdateWidget(old);
    if (!widget.enabled && _down) _release();
  }

  void _press(PointerDownEvent e) {
    _down = true;
    _origin = e.position;
    _c.forward().orCancel.then((_) {
      if (!_down && mounted) _c.reverse();
    }, onError: (Object _) {});
  }

  void _move(PointerMoveEvent e) {
    final o = _origin;
    if (_down && o != null && (e.position - o).distance > kTouchSlop) _release();
  }

  void _release([PointerEvent? _]) {
    if (!_down) return;
    _down = false;
    _origin = null;
    // إن كان التصغير لا يزال جاريًا يعكسه then() أعلاه بعد اكتماله.
    if (_c.status != AnimationStatus.forward) _c.reverse();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || _intensity <= 0) return widget.child;
    return Listener(
      behavior: HitTestBehavior.deferToChild,
      onPointerDown: _press,
      onPointerMove: _move,
      onPointerUp: _release,
      onPointerCancel: _release,
      child: ScaleTransition(
        scale: _scale!,
        child: RepaintBoundary(child: widget.child),
      ),
    );
  }
}

/// يطلق نبضة مرة واحدة عند أول ظهور للشاشة (مثل نجاح الطلب أو التسليم).
class HapticOnMount extends StatefulWidget {
  const HapticOnMount({super.key, required this.child, this.success = true});
  final Widget child;

  /// true = نمط النجاح، false = تأكيد.
  final bool success;

  @override
  State<HapticOnMount> createState() => _HapticOnMountState();
}

class _HapticOnMountState extends State<HapticOnMount> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.success ? Haptics.success() : Haptics.confirm();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
