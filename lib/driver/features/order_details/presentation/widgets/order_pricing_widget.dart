import 'package:flutter/material.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/l10n/app_localizations.dart';
import 'package:project/driver/shared/driver_models.dart';
import 'package:project/driver/shared/presentation/driver_ui.dart';

class OrderPricingWidget extends StatelessWidget {
  final DriverOrder order;
  const OrderPricingWidget({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: _item(l10n.deliveryFeeLabel, order.deliveryFee.display, l10n.drYourFeeHint),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _item(
            l10n.drCollectAmount,
            order.hasCashToCollect ? order.cashToCollect.display : '—',
            l10n.drCollectFromCustomerHint,
          ),
        ),
      ],
    );
  }

  Widget _item(String title, String price, String sub) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DriverUi.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DriverUi.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: DriverUi.muted, fontSize: 12)),
          const SizedBox(height: 2),
          Text(
            price,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(sub, style: const TextStyle(color: DriverUi.muted, fontSize: 11)),
        ],
      ),
    );
  }
}
