import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// أمواج الحبر الثلاث المتدفقة من سن القلم عبر أسفل الشاشة.
/// [amp] 0..1، [t] ثوانٍ؛ كل موجة بطور وسرعة وشفافية مختلفة.
void paintInkWaves(Canvas canvas, Size size, {required double t, required double amp, required Color a, required Color b, required double opacity}) {
  if (amp < 0.01 || opacity <= 0) return;
  const layers = [
    (speed: 1.3, phase: 0.0, freq: 1.4, alpha: 0.55, lift: 0.0),
    (speed: -1.9, phase: 1.7, freq: 2.1, alpha: 0.38, lift: 10.0),
    (speed: 2.6, phase: 3.1, freq: 2.9, alpha: 0.24, lift: 20.0),
  ];
  final baseY = size.height - 12;
  for (final l in layers) {
    final path = Path()..moveTo(0, size.height);
    final h = (10 + 46 * amp) * (1 - l.lift / 90);
    for (var x = 0.0; x <= size.width; x += 6) {
      final n = x / size.width;
      final env = math.sin(n * math.pi); // أعلى ارتفاع في المنتصف تحت السن.
      final y = baseY - l.lift - h * env * (0.55 + 0.45 * math.sin(n * math.pi * 2 * l.freq + t * l.speed + l.phase));
      path.lineTo(x, y);
    }
    path
      ..lineTo(size.width, size.height)
      ..close();
    final rect = Rect.fromLTWH(0, baseY - 80, size.width, 100);
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [a.withValues(alpha: l.alpha * opacity), b.withValues(alpha: l.alpha * opacity * 0.6)],
      ).createShader(rect);
    canvas.drawPath(path, paint);
  }
}
