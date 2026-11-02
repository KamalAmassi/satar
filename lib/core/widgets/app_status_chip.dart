import 'package:flutter/material.dart';
import 'package:project/core/constants/app_colors.dart';

/// شارة حالة الطلب بلون من AppColors.statusColor.
class AppStatusChip extends StatelessWidget {
  const AppStatusChip({super.key, required this.statusKey, required this.label});

  final String statusKey;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.statusColor(statusKey);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
