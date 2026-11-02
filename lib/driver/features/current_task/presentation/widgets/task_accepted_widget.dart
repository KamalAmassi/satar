import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/errors/failure_message.dart';
import 'package:project/core/l10n/app_localizations.dart';
import 'package:project/core/widgets/app_button.dart';
import 'package:project/core/widgets/app_status_chip.dart';
import 'package:project/driver/features/auth/presentation/widgets/header_driver.dart';
import 'package:project/driver/features/current_task/presentation/controllers/current_task_controller.dart';
import 'package:project/driver/features/current_task/presentation/widgets/task_progress_steps.dart';
import 'package:project/driver/features/order_details/presentation/widgets/amounts_card.dart';
import 'package:project/driver/features/order_details/presentation/widgets/stop_card.dart';
import 'package:project/driver/shared/driver_models.dart';
import 'package:project/driver/shared/presentation/driver_ui.dart';

/// D19–D21: المهمة بعد القبول (الحالة accepted): العناوين الكاملة + مبلغ التحصيل
/// وزر "استلمت الطلب" (نصه من السيرفر next_action.label).
class TaskAcceptedWidget extends StatelessWidget {
  const TaskAcceptedWidget({
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.drTaskTitle,
                            style: const TextStyle(color: DriverUi.muted, fontSize: 12),
                          ),
                          Text(
                            order.code,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
                const SizedBox(height: 20),
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
                if (order.hasCashToCollect) ...[
                  _cashCard(l10n),
                  const SizedBox(height: 12),
                ],
                AmountsCard(order: order),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: controller.openMap,
                  icon: const Icon(Icons.map_outlined),
                  label: Text(l10n.drOpenMap),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        // الزر السفلي الثابت
        Container(
          padding: const EdgeInsets.all(DriverUi.pagePadding),
          decoration: const BoxDecoration(
            color: DriverUi.bg,
            border: Border(top: BorderSide(color: DriverUi.border)),
          ),
          child: Obx(() {
            final failure = controller.transitionFailure.value;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (controller.isStale.value)
                  _notice(l10n.drTaskStaleTitle, l10n.drTaskStaleBody, onTap: controller.load,
                      actionLabel: l10n.drTaskRefresh),
                if (failure != null && !controller.isStale.value)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      failureMessage(l10n, failure),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.error, fontSize: 13),
                    ),
                  ),
                AppButton(
                  label: (next != null && next.label.isNotEmpty)
                      ? next.label
                      : l10n.drNextPickedUpButton,
                  isLoading: controller.isTransitioning.value,
                  onPressed: next == null ? null : controller.advance,
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  /// بطاقة المبلغ المطلوب تحصيله (أصفر فاتح كما بالتصميم).
  Widget _cashCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DriverUi.warnBg,
        borderRadius: BorderRadius.circular(DriverUi.cardRadius),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(color: DriverUi.gold, shape: BoxShape.circle),
            child: const Icon(Icons.shopping_basket_outlined, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.drAmountToCollect,
                  style: const TextStyle(color: DriverUi.muted, fontSize: 12),
                ),
                Text(
                  order.cashToCollect.display,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _notice(String title, String body, {VoidCallback? onTap, String? actionLabel}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DriverUi.warnBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 2),
          Text(body, style: const TextStyle(fontSize: 12, height: 1.4)),
          if (onTap != null && actionLabel != null)
            TextButton(onPressed: onTap, child: Text(actionLabel)),
        ],
      ),
    );
  }
}
