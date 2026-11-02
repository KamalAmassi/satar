import 'package:flutter/material.dart';
import 'package:project/core/constants/app_colors.dart';

class InkLine extends StatefulWidget {
  const InkLine({
    super.key,
    this.height = 4.0,
    this.color = AppColors.secondary,
    this.duration = const Duration(milliseconds: 900),
  });

  final double height;
  final Color color;
  final Duration duration;

  @override
  State<InkLine> createState() => _InkLineState();
}

class _InkLineState extends State<InkLine> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(double.infinity, widget.height),
          painter: _InkPainter(
            progress: _controller.value,
            color: widget.color,
            height: widget.height,
          ),
        );
      },
    );
  }
}

class _InkPainter extends CustomPainter {
  _InkPainter({
    required this.progress,
    required this.color,
    required this.height,
  });

  final double progress;
  final Color color;
  final double height;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = height
      ..strokeCap = StrokeCap.round;

    final targetWidth = size.width * progress;
    // Slight wavy organic path for pen stroke effect
    final path = Path()
      ..moveTo(0, height / 2)
      ..quadraticBezierTo(
        targetWidth * 0.5,
        height * 0.2,
        targetWidth,
        height / 2,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _InkPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
