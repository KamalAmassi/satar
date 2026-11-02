import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/errors/failure_message.dart';
import 'package:project/core/l10n/app_localizations.dart';
import 'package:project/driver/features/auth/presentation/widgets/header_driver.dart';
import 'package:project/driver/features/available_orders/presentation/controllers/available_orders_controller.dart';
import 'package:project/driver/features/available_orders/presentation/widgets/driver_offline.dart';
import 'package:project/driver/features/available_orders/presentation/widgets/error_driver.dart';
import 'package:project/driver/features/available_orders/presentation/widgets/order_card_widget.dart';
import 'package:project/driver/shared/presentation/driver_ui.dart';

/// تاب "المتاح": الحالات D04 (غير متصل) / D07 (تحميل) / D10 (خطأ) / D08 (فاضي) / D06 (القائمة).
class DriverAvailableOrdersView extends GetView<DriverAvailableOrdersController> {
  const DriverAvailableOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: DriverUi.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            headerDriver(l10n),
            Expanded(
              child: Obx(() {
                if (!controller.isConnected.value) {
                  return DriverOffline(
                    isConnecting: controller.isConnecting.value,
                    onConnectPressed: controller.toggleConnection,
                  );
                }
                if (controller.isFetchLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  );
                }
                if (controller.hasFetchError.value) {
                  final f = controller.fetchFailure.value;
                  return DriverFetchError(
                    message: f == null ? null : failureMessage(l10n, f),
                    onRetry: controller.fetchAvailableOrders,
                  );
                }
                if (controller.availableOrders.isEmpty) {
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () => controller.fetchAvailableOrders(silent: true),
                    child: LayoutBuilder(
                      builder: (_, c) => SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: c.maxHeight,
                          child: _centralMessage(
                            Icons.inventory_2_outlined,
                            l10n.noOrdersNow,
                            l10n.noOrdersNowDesc,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return _connectedLayout(l10n);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _connectedLayout(AppLocalizations l10n) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => controller.fetchAvailableOrders(silent: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.all(DriverUi.pagePadding),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 9,
                            height: 9,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.connectedStatus,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.connectedDesc,
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: controller.toggleConnection,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.disconnectBtn,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.nearbyOrdersTitle,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            l10n.nearbyOrdersDesc,
            style: const TextStyle(color: DriverUi.muted, fontSize: 12),
          ),
          const SizedBox(height: 16),
          for (final order in controller.availableOrders)
            OrderCardWidget(
              order: order,
              onViewDetails: controller.goToOrderDetails,
            ),
        ],
      ),
    );
  }

  Widget _centralMessage(IconData icon, String title, String desc) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              desc,
              style: const TextStyle(color: DriverUi.muted, fontSize: 13, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
