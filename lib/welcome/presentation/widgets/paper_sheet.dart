import 'package:flutter/material.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';

class PaperSheet extends StatelessWidget {
  const PaperSheet({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSizes.lg),
    this.rotationAngle = 0.0,
    this.backgroundColor = AppColors.surface,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double rotationAngle;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotationAngle,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
          border: Border.all(
            color: AppColors.secondary.withValues(alpha: 0.2),
            width: 1.2,
          ),
        ),
        child: child,
      ),
    );
  }
}
