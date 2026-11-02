import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/errors/failure_message.dart';
import 'package:project/core/l10n/app_localizations.dart';
import 'package:project/core/routes/app_routes.dart';
import 'package:project/core/widgets/app_button.dart';
import 'package:project/driver/features/auth/presentation/widgets/header_driver.dart';
import 'package:project/driver/features/available_orders/presentation/widgets/driver_offline.dart';
import 'package:project/driver/features/home/presentation/controllers/driver_session_controller.dart';
import 'package:project/driver/shared/presentation/driver_ui.dart';
import 'package:project/driver/shell/driver_shell_controller.dart';

/// تاب "الرئيسية": حالة الاتصال + ملخص اليوم + اختصار المهمة النشطة.
class DriverHomeView extends GetView<DriverSessionController> {
  const DriverHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final shell = Get.find<DriverShellController>();

    return Scaffold(
      backgroundColor: DriverUi.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            headerDriver(l10n),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: controller.refreshAll,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  padding: const EdgeInsets.all(DriverUi.pagePadding),
                  children: [
                    Obx(() {
                      final online = controller.isOnline.value;
                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 9,
                                  height: 9,
                                  decoration: BoxDecoration(
                                    color: online ? AppColors.success : const Color(0xFFA49B9F),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  online ? l10n.connectedStatus : l10n.notConnectedStatus,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              online ? l10n.connectedDesc : l10n.connectDesc,
                              style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                            ),
                            const SizedBox(height: 16),
                            AppButton(
                              label: online ? l10n.disconnectBtn : l10n.connectNow,
                              variant: online ? AppButtonVariant.outlined : AppButtonVariant.light,
                              isLoading: controller.isToggling.value,
                              onPressed: controller.toggleOnline,
                            ),
                          ],
                        ),
                      );
                    }),
                    Obx(() {
                      final f = controller.toggleFailure.value;
                      if (f == null) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          failureMessage(l10n, f),
                          style: const TextStyle(color: AppColors.error, fontSize: 13),
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                    const DriverTodaySummary(),
                    const SizedBox(height: 20),
                    Obx(() {
                      if (!controller.hasActiveTask.value) {
                        return _shortcut(
                          icon: Icons.local_shipping_outlined,
                          title: l10n.availableOrdersTitle,
                          subtitle: l10n.drHomeOrdersHint,
                          onTap: () => shell.goToTab(1),
                        );
                      }
                      return _shortcut(
                        icon: Icons.explore_outlined,
                        title: l10n.drCurrentTaskTitle,
                        subtitle: l10n.drHomeTaskHint,
                        onTap: () => shell.goToTab(2),
                        highlight: true,
                      );
                    }),
                    const SizedBox(height: 12),
                    _shortcut(
                      icon: Icons.payments_outlined,
                      title: l10n.drEarningsTitle,
                      subtitle: l10n.drHomeEarningsHint,
                      onTap: () => Get.toNamed(DriverRoutes.earningsCash),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shortcut({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool highlight = false,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(DriverUi.cardRadius),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: highlight ? DriverUi.warnBg : DriverUi.card,
          borderRadius: BorderRadius.circular(DriverUi.cardRadius),
          border: Border.all(color: highlight ? AppColors.secondary : DriverUi.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(color: DriverUi.chip, shape: BoxShape.circle),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: DriverUi.muted, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_left_rounded, color: DriverUi.muted),
          ],
        ),
      ),
    );
  }
}
