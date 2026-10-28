import 'package:flutter/material.dart';
import 'package:project/core/animations/entrance.dart';
import 'package:project/core/constants/app_colors.dart';

class SplashBackground extends StatelessWidget {
  const SplashBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Entrance(
        duration: const Duration(milliseconds: 1400),
        scaleBegin: 0.92,
        child: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, -0.2),
                    radius: 1.0,
                    colors: [Color(0xFF42193A), AppColors.primary],
                  ),
                ),
              ),
            ),
            Positioned(top: -90, right: -70, child: _ring(280)),
            Positioned(bottom: -110, left: -90, child: _ring(340)),
          ],
        ),
      ),
    );
  }

  Widget _ring(double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: AppColors.sand.withValues(alpha: 0.07),
        width: 1.5,
      ),
    ),
  );
}