import 'package:flutter/material.dart';
import 'package:project/core/constants/app_colors.dart';

/// Static vector illustrations drawn in code.
/// Calm, flat shapes with organic feel.

class NotebookArt extends StatelessWidget {
  const NotebookArt({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: const Size(120, 160),
        painter: _NotebookPainter(),
      ),
    );
  }
}

class PencilArt extends StatelessWidget {
  const PencilArt({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: const Size(20, 140),
        painter: _PencilPainter(),
      ),
    );
  }
}

class BookStackArt extends StatelessWidget {
  const BookStackArt({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: const Size(160, 140),
        painter: _BookStackPainter(),
      ),
    );
  }
}

class PrintSheetArt extends StatelessWidget {
  const PrintSheetArt({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: const Size(120, 160),
        painter: _PrintSheetPainter(),
      ),
    );
  }
}

class AssistantBubbleArt extends StatelessWidget {
  const AssistantBubbleArt({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: const Size(140, 100),
        painter: _AssistantBubblePainter(),
      ),
    );
  }
}

// ---------------------------------------------------------------- Painters

class _NotebookPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(12),
    );
    canvas.drawRRect(rect, Paint()..color = AppColors.secondary);

    // Binding rings
    final ringPaint = Paint()..color = AppColors.ink.withValues(alpha: 0.2);
    for (int i = 0; i < 10; i++) {
      canvas.drawCircle(Offset(12, 16.0 + i * 14.0), 3.5, ringPaint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PencilPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bodyRect = Rect.fromLTWH(0, 20, size.width, size.height - 20);
    canvas.drawRect(bodyRect, Paint()..color = AppColors.accent);

    final tipPath = Path()
      ..moveTo(0, 20)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, 20)
      ..close();
    canvas.drawPath(tipPath, Paint()..color = AppColors.sand);

    final leadPath = Path()
      ..moveTo(size.width / 4, 10)
      ..lineTo(size.width / 2, 0)
      ..lineTo(3 * size.width / 4, 10)
      ..close();
    canvas.drawPath(leadPath, Paint()..color = AppColors.ink);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BookStackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final book1 = RRect.fromRectAndRadius(
      const Rect.fromLTWH(10, 80, 140, 40),
      const Radius.circular(4),
    );
    final book2 = RRect.fromRectAndRadius(
      const Rect.fromLTWH(20, 50, 120, 30),
      const Radius.circular(4),
    );
    final book3 = RRect.fromRectAndRadius(
      const Rect.fromLTWH(40, 20, 80, 30),
      const Radius.circular(4),
    );

    canvas.drawRRect(book1, Paint()..color = AppColors.primary);
    canvas.drawRRect(book2, Paint()..color = AppColors.secondary);
    canvas.drawRRect(book3, Paint()..color = AppColors.accent);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PrintSheetPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(4),
    );
    canvas.drawRRect(rect, Paint()..color = Colors.white);
    canvas.drawRRect(rect, Paint()..color = AppColors.border..style = PaintingStyle.stroke..strokeWidth = 1);

    final linePaint = Paint()..color = AppColors.border..strokeWidth = 2;
    for (int i = 0; i < 8; i++) {
      canvas.drawLine(
        Offset(20, 30.0 + i * 16.0),
        Offset(size.width - 20, 30.0 + i * 16.0),
        linePaint,
      );
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AssistantBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(0, 0, 140, 80),
      const Radius.circular(20),
    );
    canvas.drawRRect(rect, Paint()..color = AppColors.secondary.withValues(alpha: 0.15));

    final path = Path()
      ..moveTo(20, 80)
      ..lineTo(20, 95)
      ..lineTo(35, 80)
      ..close();
    canvas.drawPath(path, Paint()..color = AppColors.secondary.withValues(alpha: 0.15));

    final dotPaint = Paint()..color = AppColors.secondary;
    canvas.drawCircle(const Offset(40, 40), 4, dotPaint);
    canvas.drawCircle(const Offset(70, 40), 4, dotPaint);
    canvas.drawCircle(const Offset(100, 40), 4, dotPaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
