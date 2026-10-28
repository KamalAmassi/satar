import 'package:flutter/material.dart';

/// حركة طفو خفيفة ومستمرة (فوق/تحت) للعناصر التزيينية.
class FloatingEffect extends StatefulWidget {
  const FloatingEffect({
    super.key,
    required this.child,
    this.distance = 8,
    this.duration = const Duration(seconds: 3),
  });

  final Widget child;
  final double distance;
  final Duration duration;

  @override
  State<FloatingEffect> createState() => _FloatingEffectState();
}

class _FloatingEffectState extends State<FloatingEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
  AnimationController(vsync: this, duration: widget.duration)
    ..repeat(reverse: true);
  late final Animation<double> _animation =
  CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return widget.child;

    return AnimatedBuilder(
      animation: _animation,
      child: widget.child,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, (_animation.value * 2 - 1) * widget.distance),
        child: child,
      ),
    );
  }
}