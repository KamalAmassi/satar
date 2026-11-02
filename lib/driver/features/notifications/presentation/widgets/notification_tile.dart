import 'package:flutter/material.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/widgets/app_card.dart';
import 'package:project/driver/shared/driver_models.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.item});

  final AppNotification item;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final d = item.createdAt;
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, left: 10),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: item.readAt != null ? Colors.transparent : AppColors.secondary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(item.body, style: t.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                ...[
                  const SizedBox(height: 4),
                  Text(
                    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}  ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}',
                    style: t.labelSmall?.copyWith(color: AppColors.textHint),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
