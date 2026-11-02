import 'package:flutter/material.dart';
import 'package:project/core/constants/app_colors.dart';

class WashiTape extends StatelessWidget {
  const WashiTape({super.key, required this.color, this.rotation = 0.0});
  final Color color;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: 60,
        height: 16,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
