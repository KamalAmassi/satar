import 'package:flutter/material.dart';
import 'dart:math' as math;

class DashedCirclePainter extends CustomPainter {
  DashedCirclePainter({required this.color, this.strokeWidth = 2.0});
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);
    const count = 16;
    const sweepAngle = (2 * math.pi) / count;

    for (int i = 0; i < count; i++) {
      if (i % 2 == 0) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          i * sweepAngle,
          sweepAngle * 0.7,
          false,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
