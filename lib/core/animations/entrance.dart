import 'dart:async';
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:project/core/animations/app_motion.dart';

/// ظهور تدريجي (fade) مع إزاحة (slide) وتكبير (scale) اختياري.
/// [offset] بالبكسل: مثلاً Offset(0, 24) يعني يطلع من تحت 24 بكسل.
/// يحترم إعداد "تقليل الحركة" في النظام.
class Entrance extends StatefulWidget {
  const Entrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppMotion.slow,
    this.offset = Offset.zero,
    this.scaleBegin = 1.0,
    this.curve = AppMotion.emphasized,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset offset;
  final double scaleBegin;
  final Curve curve;

  @override
  State<Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<Entrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
  AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _animation =
  CurvedAnimation(parent: _controller, curve: widget.curve);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      _timer = Timer(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return widget.child;

    return AnimatedBuilder(
      animation: _animation,
      child: widget.child,
      builder: (context, child) {
        final t = _animation.value;
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: widget.offset * (1 - t),
            child: Transform.scale(
              scale: lerpDouble(widget.scaleBegin, 1, t)!,
              child: child,
            ),
          ),
        );
      },
    );
  }
}