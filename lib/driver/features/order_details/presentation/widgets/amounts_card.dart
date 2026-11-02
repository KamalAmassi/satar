import 'package:flutter/material.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/widgets/app_card.dart';
import 'package:project/driver/shared/driver_models.dart';

class AmountsCard extends StatelessWidget {
  const AmountsCard({super.key, required this.order});

  final DriverOrder order;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = Theme.of(context).textTheme;

    Widget row(String label, String value, {bool strong = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: t.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Text(
            value,
            style: (strong ? t.titleSmall : t.bodyMedium)?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );

    return AppCard(
      child: Column(
        children: [
          row(l10n.deliveryFeeLabel, order.deliveryFee.display),
          row(
            l10n.drAmountToCollect,
            order.hasCashToCollect ? order.cashToCollect.display : '—',
            strong: order.hasCashToCollect,
          ),
          const Divider(height: AppSizes.lg),
          row(l10n.drYourEarning, order.earning.display, strong: true),
        ],
      ),
    );
  }
}
