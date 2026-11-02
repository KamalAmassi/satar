import 'package:flutter/material.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';

/// سطر عرض عام (يومية أرباح / تسوية نقدية).
class LedgerEntry {
  const LedgerEntry({required this.title, this.subtitle, this.amount});

  final String title;
  final String? subtitle;
  final String? amount;
}

class LedgerList extends StatelessWidget {
  const LedgerList({super.key, required this.entries});

  final List<LedgerEntry> entries;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      children: [
        for (final e in entries)
          Container(
            margin: const EdgeInsets.only(bottom: AppSizes.sm),
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.title, style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                      if (e.subtitle != null)
                        Text(
                          e.subtitle!,
                          style: t.bodySmall?.copyWith(color: AppColors.textSecondary),
                        ),
                    ],
                  ),
                ),
                if (e.amount != null)
                  Text(
                    e.amount!,
                    style: t.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
