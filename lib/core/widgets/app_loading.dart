import 'package:flutter/material.dart';
import 'package:project/core/constants/app_colors.dart';

/// مؤشر التحميل الموحّد في التطبيق (يُعدَّل شكله من هنا فقط).
class AppLoading extends StatelessWidget {
  const AppLoading({super.key, this.size = 32, this.color = AppColors.primary});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: size / 10,
        strokeCap: StrokeCap.round,
        color: color,
        backgroundColor: color.withValues(alpha: 0.12),
      ),
    );
  }
}