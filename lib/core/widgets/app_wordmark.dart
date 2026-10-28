import 'package:flutter/material.dart';
import 'package:project/core/constants/app_colors.dart';

class AppWordmark extends StatelessWidget {
  const AppWordmark({
    super.key,
    this.color = AppColors.primary,
    this.size = 28,
    this.showLatin = true,
  });

  final Color color;
  final double size;
  final bool showLatin;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'سطر',
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w700,
            color: color,
            height: 1.1,
          ),
        ),
        if (showLatin)
          Text(
            'SATR',
            style: TextStyle(
              fontSize: size * 0.3,
              letterSpacing: size * 0.2,
              fontWeight: FontWeight.w600,
              color: color.withValues(alpha: 0.7),
            ),
          ),
      ],
    );
  }
}