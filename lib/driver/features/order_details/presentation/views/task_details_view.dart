import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/l10n/app_localizations.dart';
import 'package:project/core/widgets/app_card.dart';
import 'package:project/core/widgets/app_status_chip.dart';
import 'package:project/driver/features/order_details/presentation/controllers/task_details_controller.dart';
import 'package:project/driver/features/order_details/presentation/order_details_args.dart';
import 'package:project/driver/features/order_details/presentation/widgets/amounts_card.dart';
import 'package:project/driver/features/order_details/presentation/widgets/items_card.dart';
import 'package:project/driver/features/order_details/presentation/widgets/stop_card.dart';
import 'package:project/driver/shared/domain/order_extensions.dart';
import 'package:project/driver/shared/presentation/driver_ui.dart';

/// تفاصيل المهمة (الحالية) / تفاصيل مهمة سابقة.
class DriverTaskDetailsView extends GetView<DriverTaskDetailsController> {
  const DriverTaskDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final order = controller.order;
    final mode = controller.mode;
    final title = mode == OrderDetailsMode.history
        ? l10n.drHistoryDetailsTitle
        : l10n.drTaskDetailsTitle;

    return Scaffold(
      backgroundColor: DriverUi.bg,
      appBar: AppBar(
        backgroundColor: DriverUi.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          title,
          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(DriverUi.pagePadding),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.code,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              AppStatusChip(statusKey: order.status.key, label: order.status.label),
            ],
          ),
          const SizedBox(height: 16),
          StopCard(
            icon: Icons.storefront_outlined,
            title: l10n.drStopPickup,
            place: order.pickup,
            subtitle: order.vendor?.name,
            callLabel: mode == OrderDetailsMode.task ? l10n.drCallAction : null,
            onCall: () => controller.call(order.vendor?.phone),
          ),
          const SizedBox(height: 12),
          StopCard(
            icon: Icons.location_on_outlined,
            title: l10n.drStopDropoff,
            place: order.dropoff,
            subtitle: order.customer?.name,
            callLabel: mode == OrderDetailsMode.task ? l10n.drCallAction : null,
            onCall: () => controller.call(order.customerPhone),
          ),
          const SizedBox(height: 12),
          AmountsCard(order: order),
          if (order.items.isNotEmpty) ...[
            const SizedBox(height: 12),
            ItemsCard(items: order.items),
          ],
          if (order.failureReason != null) ...[
            const SizedBox(height: 12),
            AppCard(
              color: DriverUi.dangerBg,
              borderColor: AppColors.error.withValues(alpha: 0.3),
              child: Text(
                order.failureReason!,
                style: const TextStyle(color: AppColors.error, fontSize: 14),
              ),
            ),
          ],
          if (order.note != null || order.fields.deliveryNotes != null) ...[
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.drOrderNotes,
                    style: const TextStyle(color: DriverUi.muted, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    [order.note, order.fields.deliveryNotes].whereType<String>().join('\n'),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
