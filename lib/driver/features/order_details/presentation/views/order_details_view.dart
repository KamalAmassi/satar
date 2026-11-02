import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/l10n/app_localizations.dart';
import 'package:project/core/widgets/app_button.dart';
import 'package:project/driver/features/order_details/presentation/controllers/order_details_controller.dart';
import 'package:project/driver/features/order_details/presentation/widgets/acceptance_status_widget.dart';
import 'package:project/driver/features/order_details/presentation/widgets/order_pricing_widget.dart';
import 'package:project/driver/features/order_details/presentation/widgets/order_route_widget.dart';
import 'package:project/driver/shared/presentation/driver_ui.dart';

/// D11–D18: تفاصيل الطلب قبل القبول + كل حالات القبول داخل نفس الشاشة.
class DriverOrderDetailsView extends GetView<DriverOrderDetailsController> {
  const DriverOrderDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: DriverUi.bg,
      appBar: AppBar(
        title: Text(
          l10n.orderDetailsTitle,
          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: DriverUi.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Obx(() {
          switch (controller.acceptanceState.value) {
            case OrderAcceptanceState.accepting:
              return AcceptanceStatusWidget(
                icon: Icons.hourglass_top_rounded,
                title: l10n.acceptingOrderTitle,
                subtitle: l10n.acceptingOrderDesc,
                isLoading: true,
              );
            case OrderAcceptanceState.success:
              return AcceptanceStatusWidget(
                icon: Icons.check_circle_outline_rounded,
                title: l10n.orderAcceptedTitle,
                subtitle: l10n.orderAcceptedDesc,
                isSuccess: true,
                actionButton: AppButton(
                  label: l10n.viewActiveTaskBtn,
                  onPressed: controller.viewActiveTask,
                ),
              );
            case OrderAcceptanceState.alreadyTaken:
              return AcceptanceStatusWidget(
                icon: Icons.block_flipped,
                title: l10n.alreadyTakenTitle,
                subtitle: l10n.alreadyTakenDesc,
                actionButton: AppButton(
                  label: l10n.backToOrdersBtn,
                  onPressed: controller.backToOrders,
                ),
              );
            case OrderAcceptanceState.offline:
              return AcceptanceStatusWidget(
                icon: Icons.wifi_off_rounded,
                title: l10n.drAcceptOfflineTitle,
                subtitle: l10n.drAcceptOfflineBody,
                actionButton: AppButton(
                  label: l10n.connectNow,
                  onPressed: controller.connectNow,
                ),
                secondaryButton: AppButton(
                  label: l10n.backToOrdersBtn,
                  variant: AppButtonVariant.outlined,
                  onPressed: controller.backToOrders,
                ),
              );
            case OrderAcceptanceState.busy:
              return AcceptanceStatusWidget(
                icon: Icons.notification_important_outlined,
                title: l10n.busyStatusTitle,
                subtitle: l10n.busyStatusDesc,
                actionButton: AppButton(
                  label: l10n.viewActiveTaskBtn,
                  onPressed: controller.viewActiveTask,
                ),
                secondaryButton: AppButton(
                  label: l10n.backToOrdersBtn,
                  variant: AppButtonVariant.outlined,
                  onPressed: controller.backToOrders,
                ),
              );
            case OrderAcceptanceState.cashLimit:
              return AcceptanceStatusWidget(
                icon: Icons.account_balance_wallet_outlined,
                title: l10n.cashLimitTitle,
                subtitle: l10n.cashLimitDesc,
                actionButton: AppButton(
                  label: l10n.drViewCash,
                  onPressed: controller.openCash,
                ),
                secondaryButton: AppButton(
                  label: l10n.backToOrdersBtn,
                  variant: AppButtonVariant.outlined,
                  onPressed: controller.backToOrders,
                ),
              );
            case OrderAcceptanceState.error:
              return AcceptanceStatusWidget(
                icon: Icons.error_outline_rounded,
                title: l10n.unexpectedErrorTitle,
                subtitle: controller.errorMessage.value ?? l10n.unexpectedErrorDesc,
                actionButton: AppButton(
                  label: l10n.retry,
                  onPressed: controller.acceptCurrentOrder,
                ),
                secondaryButton: AppButton(
                  label: l10n.backToOrdersBtn,
                  variant: AppButtonVariant.outlined,
                  onPressed: controller.resetToDetails,
                ),
              );
            case OrderAcceptanceState.details:
              break;
          }

          final order = controller.currentOrder.value;
          if (order == null) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(DriverUi.pagePadding),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.availableOrderTag,
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: DriverUi.infoBg,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            l10n.distanceAway(order.distanceKm.toStringAsFixed(1)),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    OrderRouteWidget(order: order),
                    const SizedBox(height: 20),
                    OrderPricingWidget(order: order),
                    const SizedBox(height: 20),
                    _summary(order.itemsCount ?? order.items.length, l10n),
                  ],
                ),
              ),
              _bottomButtons(l10n),
            ],
          );
        }),
      ),
    );
  }

  Widget _summary(int itemsCount, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.orderSummary,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _tile(l10n.itemsCountLabel, l10n.itemsCountValue(itemsCount)),
        const SizedBox(height: 12),
        Text(
          l10n.detailsHiddenNotice,
          style: const TextStyle(color: DriverUi.muted, fontSize: 12, height: 1.6),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: DriverUi.infoBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.detailsHiddenAlert,
                  style: const TextStyle(color: DriverUi.muted, fontSize: 12, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tile(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: DriverUi.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(value, style: const TextStyle(color: DriverUi.muted, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _bottomButtons(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(DriverUi.pagePadding),
      decoration: const BoxDecoration(
        color: DriverUi.bg,
        border: Border(top: BorderSide(color: DriverUi.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              label: l10n.hideOrderBtn,
              variant: AppButtonVariant.outlined,
              onPressed: Get.back,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: AppButton(
              label: l10n.acceptOrderBtn,
              onPressed: controller.acceptCurrentOrder,
            ),
          ),
        ],
      ),
    );
  }
}
