import 'package:flutter/material.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';
import 'package:project/core/widgets/app_card.dart';
import 'package:project/driver/shared/driver_models.dart';

/// بطاقة نقطة (استلام أو تسليم) مع زر اتصال اختياري.
class StopCard extends StatelessWidget {
  const StopCard({
    super.key,
    required this.icon,
    required this.title,
    required this.place,
    this.subtitle,
    this.callLabel,
    this.onCall,
  });

  final IconData icon;
  final String title;
  final Place place;

  /// اسم المكتبة / الزبون.
  final String? subtitle;
  final String? callLabel;
  final VoidCallback? onCall;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.sand.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: AppSizes.iconSm + 2, color: AppColors.primary),
              ),
              const SizedBox(width: AppSizes.md),
              Text(
                title,
                style: t.labelLarge?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          if (subtitle != null)
            Text(subtitle!, style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          Text(
            place.label ?? '—',
            style: (subtitle == null ? t.titleSmall : t.bodyMedium)
                ?.copyWith(fontWeight: subtitle == null ? FontWeight.w700 : FontWeight.w500),
          ),
          if (place.details != null) ...[
            const SizedBox(height: 2),
            Text(
              place.details!,
              style: t.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
          if (onCall != null && callLabel != null) ...[
            const SizedBox(height: AppSizes.md),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: onCall,
                icon: const Icon(Icons.call_outlined, size: AppSizes.iconSm),
                label: Text(callLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
