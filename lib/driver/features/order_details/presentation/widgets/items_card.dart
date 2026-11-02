import 'package:flutter/material.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/widgets/app_card.dart';
import 'package:project/driver/shared/driver_models.dart';

/// محتويات الطلب (items) — اسم × كمية + ملاحظة.
class ItemsCard extends StatelessWidget {
  const ItemsCard({super.key, required this.items});

  final List<DriverOrderItem> items;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.drOrderItems,
            style: t.labelMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          for (final i in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(i.name, style: t.bodyMedium),
                        if (i.note != null)
                          Text(i.note!,
                              style: t.bodySmall?.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Text('× ${i.qty}',
                      style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
