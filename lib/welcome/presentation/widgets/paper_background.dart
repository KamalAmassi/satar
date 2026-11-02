import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:project/core/constants/app_colors.dart';

class PaperBackground extends StatelessWidget {
  const PaperBackground({
    super.key,
    this.isDark = false,
    required this.child,
  });

  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? AppColors.primary : AppColors.paper,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Ruled paper lines & grain painter
          RepaintBoundary(
            child: CustomPaint(
              painter: _PaperPainter(isDark: isDark),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _PaperPainter extends CustomPainter {
  _PaperPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.04)
          : AppColors.paperLine
      ..strokeWidth = 1;

    final paintMargin = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.08)
          : AppColors.paperMargin
      ..strokeWidth = 1.5;

    // Draw horizontal ruled lines every 32px
    const lineSpacing = 32.0;
    for (double y = 40; y < size.height; y += lineSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paintLine);
    }

    // Draw vertical red margin line
    const marginX = 48.0;
    canvas.drawLine(
      Offset(marginX, 0),
      Offset(marginX, size.height),
      paintMargin,
    );

    // Subtle paper grain (fixed seed for deterministic rendering)
    final rnd = math.Random(42);
    final grainPaint = Paint()
      ..color = (isDark ? Colors.white : AppColors.ink)
          .withValues(alpha: isDark ? 0.015 : 0.02)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 400; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height;
      canvas.drawPoints(ui.PointMode.points, [Offset(x, y)], grainPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
