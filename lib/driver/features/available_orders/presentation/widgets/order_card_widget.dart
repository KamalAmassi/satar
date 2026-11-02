import 'package:flutter/material.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/l10n/app_localizations.dart';
import 'package:project/driver/shared/driver_models.dart';
import 'package:project/driver/shared/presentation/driver_ui.dart';

/// بطاقة طلب متاح (D06): الرقم، المسافة، الاستلام ← التسليم، الأجرة والتحصيل.
class OrderCardWidget extends StatelessWidget {
  final DriverOrder order;
  final ValueChanged<DriverOrder> onViewDetails;

  const OrderCardWidget({
    super.key,
    required this.order,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () => onViewDetails(order),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: DriverUi.card,
          borderRadius: BorderRadius.circular(DriverUi.cardRadius),
          border: Border.all(color: DriverUi.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.availableOrderTag,
                  style: const TextStyle(color: DriverUi.muted, fontSize: 12),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: DriverUi.chip,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    l10n.distanceAway(order.distanceKm.toStringAsFixed(1)),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              order.code,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            _line(Icons.radio_button_checked_rounded, l10n.pickupFrom, order.pickup.summary),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: SizedBox(
                height: 12,
                child: VerticalDivider(color: DriverUi.border, thickness: 1),
              ),
            ),
            _line(Icons.location_on_rounded, l10n.deliverTo, order.dropoff.summary),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _box(l10n.deliveryFeeLabel, order.deliveryFee.display)),
                const SizedBox(width: 10),
                Expanded(
                  child: _box(
                    l10n.drCollectAmount,
                    order.hasCashToCollect ? order.cashToCollect.display : '—',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.itemsCountValue(order.itemsCount ?? order.items.length),
                  style: const TextStyle(color: DriverUi.muted, fontSize: 12),
                ),
                ElevatedButton(
                  onPressed: () => onViewDetails(order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n.viewDetailsBtn,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _line(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Text('$label ', style: const TextStyle(color: DriverUi.muted, fontSize: 12)),
        Expanded(
          child: Text(
            value.isEmpty ? '—' : value,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _box(String title, String price) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DriverUi.chip,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: DriverUi.muted, fontSize: 11)),
          const SizedBox(height: 2),
          Text(
            price,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
