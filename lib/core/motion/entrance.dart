import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:project/core/design/motion.dart';
import 'package:project/core/motion/motion_settings.dart';

/// ظهور متتابع هادئ (تلاشٍ + انزلاق قصير) مرة واحدة. [index] يحدد التأخير.
/// تقليل الحركة ⇒ يظهر مباشرة بلا متحكم.
class Entrance extends StatefulWidget {
  const Entrance({super.key, required this.child, this.index = 0, this.offset = 12});

  final Widget child;
  final int index;
  final double offset;

  @override
  State<Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<Entrance> with SingleTickerProviderStateMixin {
  AnimationController? _c;
  Animation<double>? _t;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_c != null || MotionSettings.of(context).reduceMotion) return;
    final delay = Motion.entranceStagger * widget.index;
    final total = Motion.entrance + delay;
    final c = AnimationController(vsync: this, duration: total);
    _t = CurvedAnimation(
      parent: c,
      curve: Interval(delay.inMicroseconds / total.inMicroseconds, 1, curve: Curves.easeOutCubic),
    );
    _c = c..forward();
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = _t;
    if (t == null) return widget.child;
    return AnimatedBuilder(
      animation: t,
      child: widget.child,
      builder: (_, child) => Opacity(
        opacity: t.value,
        child: Transform.translate(offset: Offset(0, widget.offset * (1 - t.value)), child: child),
      ),
    );
  }
}

/// يهتز أفقيًا كلما تغيّر [trigger] (لا يهتز عند أول بناء). تقليل الحركة ⇒ بلا اهتزاز.
class ShakeOnChange extends StatefulWidget {
  const ShakeOnChange({super.key, required this.trigger, required this.child, this.distance = 8});

  final int trigger;
  final Widget child;
  final double distance;

  @override
  State<ShakeOnChange> createState() => _ShakeOnChangeState();
}

class _ShakeOnChangeState extends State<ShakeOnChange> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: Motion.shake);

  @override
  void didUpdateWidget(ShakeOnChange old) {
    super.didUpdateWidget(old);
    if (old.trigger != widget.trigger && !MotionSettings.of(context).reduceMotion) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        child: widget.child,
        builder: (_, child) {
          final t = _c.value;
          final dx = t == 0 || t == 1 ? 0.0 : math.sin(t * math.pi * 6) * widget.distance * (1 - t);
          return Transform.translate(offset: Offset(dx, 0), child: child);
        },
      );
}
