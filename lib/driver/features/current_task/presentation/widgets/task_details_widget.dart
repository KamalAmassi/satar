import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/errors/failure_message.dart';
import 'package:project/core/l10n/app_localizations.dart';
import 'package:project/core/widgets/app_status_chip.dart';
import 'package:project/driver/features/auth/presentation/widgets/header_driver.dart';
import 'package:project/driver/features/current_task/presentation/controllers/current_task_controller.dart';
import 'package:project/driver/features/current_task/presentation/widgets/next_step_card.dart';
import 'package:project/driver/features/current_task/presentation/widgets/task_progress_steps.dart';
import 'package:project/driver/features/order_details/presentation/widgets/stop_card.dart';
import 'package:project/driver/shared/driver_models.dart';
import 'package:project/driver/shared/presentation/driver_ui.dart';

/// D22–D30: المهمة بعد الاستلام (on_the_way / arrived / delivery_failed ...):
/// خطوات + بطاقة الخطوة التالية الداكنة + العناوين + الخريطة + تعذّر التسليم.
class TaskDetailsWidget extends StatelessWidget {
  const TaskDetailsWidget({
    super.key,
    required this.order,
    required this.controller,
  });

  final DriverOrder order;
  final DriverCurrentTaskController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final next = order.nextAction;
    final failed = order.isFailed;
    final card = _texts(next?.to);

    return Column(
      children: [
        headerDriver(l10n),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => controller.load(silent: true),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
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
                    IconButton(
                      icon: const Icon(Icons.info_outline_rounded, color: AppColors.primary),
                      onPressed: controller.openDetails,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (!failed)
                  TaskProgressSteps(
                    statusKey: order.status.key,
                    labels: [
                      l10n.drStepAccepted,
                      l10n.drStepPickedUp,
                      l10n.drStepOnTheWay,
                      l10n.drStepArrived,
                      l10n.drStepDelivered,
                    ],
                  ),
                Obx(() {
                  if (!controller.isStale.value) return const SizedBox.shrink();
                  return Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: DriverUi.warnBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.drTaskStaleTitle,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(l10n.drTaskStaleBody,
                            style: const TextStyle(fontSize: 12, height: 1.4)),
                        TextButton(onPressed: controller.load, child: Text(l10n.drTaskRefresh)),
                      ],
                    ),
                  );
                }),
                if (failed) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: DriverUi.dangerBg,
                      borderRadius: BorderRadius.circular(DriverUi.cardRadius),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.drFailureBannerTitle,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (order.failureReason != null) ...[
                          const SizedBox(height: 4),
                          Text(order.failureReason!, style: const TextStyle(fontSize: 14)),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                if (next != null)
                  Obx(
                    () => NextStepCard(
                      icon: card.icon,
                      title: failed ? l10n.drRetryDelivery : card.title(l10n),
                      body: card.body(l10n),
                      // نص الزر من السيرفر (next_action.label) وإلا نص احتياطي.
                      buttonLabel: next.label.isNotEmpty ? next.label : card.button(l10n),
                      isLoading: controller.isTransitioning.value,
                      onPressed: controller.advance,
                    ),
                  ),
                Obx(() {
                  final f = controller.transitionFailure.value;
                  if (f == null || controller.isStale.value) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      failureMessage(l10n, f),
                      style: const TextStyle(color: AppColors.error, fontSize: 13),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                StopCard(
                  icon: Icons.storefront_outlined,
                  title: l10n.drStopPickup,
                  place: order.pickup,
                  subtitle: order.vendor?.name,
                ),
                const SizedBox(height: 12),
                StopCard(
                  icon: Icons.location_on_outlined,
                  title: l10n.drStopDropoff,
                  place: order.dropoff,
                  subtitle: order.customer?.name,
                  callLabel: order.customerPhone == null ? null : l10n.drCallAction,
                  onCall: controller.callCustomer,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: controller.openMap,
                  icon: const Icon(Icons.map_outlined),
                  label: Text(l10n.drOpenMap),
                ),
                // تعذّر التسليم يظهر فقط لو السيرفر يسمح به (order.actions).
                if (order.failureAction != null) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: controller.reportFailure,
                    style: TextButton.styleFrom(foregroundColor: AppColors.error),
                    child: Text(
                      order.failureAction!.label.isEmpty
                          ? l10n.drReportFailure
                          : order.failureAction!.label,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _CardTexts _texts(String? to) {
    switch (to) {
      case 'on_the_way':
        return _CardTexts(Icons.directions_bike_outlined, (l) => l.drNextOnTheWayTitle,
            (l) => l.drNextOnTheWayBody, (l) => l.drNextOnTheWayButton);
      case 'arrived':
        return _CardTexts(Icons.flag_outlined, (l) => l.drNextArrivedTitle,
            (l) => l.drNextArrivedBody, (l) => l.drNextArrivedButton);
      case 'delivered':
        return _CardTexts(Icons.task_alt_rounded, (l) => l.drNextDeliveredTitle,
            (l) => l.drNextDeliveredBody, (l) => l.drNextDeliveredButton);
      case 'picked_up':
        return _CardTexts(Icons.inventory_2_outlined, (l) => l.drNextPickedUpTitle,
            (l) => l.drNextPickedUpBody, (l) => l.drNextPickedUpButton);
      default:
        return _CardTexts(Icons.arrow_forward_rounded, (l) => l.drTaskTitle,
            (l) => '', (l) => l.drNextGenericButton);
    }
  }
}

class _CardTexts {
  const _CardTexts(this.icon, this.title, this.body, this.button);

  final IconData icon;
  final String Function(AppLocalizations) title;
  final String Function(AppLocalizations) body;
  final String Function(AppLocalizations) button;
}
