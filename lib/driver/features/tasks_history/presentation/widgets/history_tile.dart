import 'package:flutter/material.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/widgets/app_card.dart';
import 'package:project/core/widgets/app_status_chip.dart';
import 'package:project/driver/shared/driver_models.dart';

class HistoryTile extends StatelessWidget {
  const HistoryTile({super.key, required this.order, required this.onTap});

  final DriverOrder order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final date = order.statusChangedAt;
    final dateText =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.code,
                  style: t.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  [dateText, order.earning.display]
                      .whereType<String>()
                      .where((s) => s.isNotEmpty)
                      .join('  •  '),
                  style: t.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          AppStatusChip(
            statusKey: order.status.key,
            label: order.status.label ?? order.status.key,
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_left_rounded, color: AppColors.textHint),
        ],
      ),
    );
  }
}
