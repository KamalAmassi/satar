import 'package:flutter/material.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/l10n/app_localizations.dart';
import 'package:project/driver/shared/driver_models.dart';
import 'package:project/driver/shared/presentation/driver_ui.dart';

/// مسار الطلب: أ (استلام) ← ب (تسليم) — مناطق فقط قبل القبول.
class OrderRouteWidget extends StatelessWidget {
  final DriverOrder order;
  const OrderRouteWidget({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DriverUi.chip,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row(l10n.drStepA, l10n.pickupZone, order.pickup.label ?? '—'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(width: 1.5, height: 28, color: AppColors.textHint),
          ),
          _row(l10n.drStepB, l10n.deliveryZone, order.dropoff.label ?? '—'),
        ],
      ),
    );
  }

  Widget _row(String step, String title, String address) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step,
              style: const TextStyle(color: DriverUi.gold, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: DriverUi.muted, fontSize: 12)),
              Text(
                address,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
