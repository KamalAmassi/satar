import 'package:flutter/material.dart';
import 'package:project/core/constants/app_colors.dart';

class MarkerHighlight extends StatelessWidget {
  const MarkerHighlight({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _MarkerPainter(),
      child: child,
    );
  }
}

class _MarkerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.sand.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size.height * 0.6, size.width, size.height * 0.3),
        const Radius.circular(4),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
