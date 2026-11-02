import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/l10n/app_localizations.dart';
import 'package:project/core/widgets/app_button.dart';
import 'package:project/driver/features/auth/presentation/widgets/header_driver.dart';
import 'package:project/driver/features/profile/presentation/controllers/profile_controller.dart';
import 'package:project/driver/shared/presentation/driver_ui.dart';

/// تاب "حسابي": بيانات السائق + روابط السجل والأرباح والإشعارات + تسجيل الخروج.
class DriverProfileView extends GetView<DriverProfileController> {
  const DriverProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    Future<void> confirmLogout() async {
      final ok = await Get.dialog<bool>(
        AlertDialog(
          content: Text(l10n.drLogoutConfirm),
          actions: [
            TextButton(onPressed: () => Get.back(result: false), child: Text(l10n.cancel)),
            TextButton(onPressed: () => Get.back(result: true), child: Text(l10n.confirm)),
          ],
        ),
      );
      if (ok == true) await controller.logout();
    }

    return Scaffold(
      backgroundColor: DriverUi.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            headerDriver(l10n),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(DriverUi.pagePadding),
                children: [
                  Obx(() {
                    final p = controller.profile.value;
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: DriverUi.card,
                        borderRadius: BorderRadius.circular(DriverUi.cardRadius),
                        border: Border.all(color: DriverUi.border),
                      ),
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 32,
                            backgroundColor: AppColors.primary,
                            child: Icon(Icons.person_rounded, color: DriverUi.gold, size: 34),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            p?.name ?? '—',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            p?.phone ?? '',
                            textDirection: TextDirection.ltr,
                            style: const TextStyle(color: DriverUi.muted, fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  _row(Icons.history_rounded, l10n.drHistoryTitle, controller.openHistory),
                  _row(Icons.payments_outlined, l10n.drEarningsTitle, controller.openEarnings),
                  _row(Icons.notifications_none_rounded, l10n.drNotificationsTitle,
                      controller.openNotifications),
                  const SizedBox(height: 24),
                  Obx(
                    () => AppButton(
                      label: l10n.drLogout,
                      icon: Icons.logout_rounded,
                      isLoading: controller.isLoggingOut.value,
                      onPressed: confirmLogout,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: DriverUi.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: DriverUi.border),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.chevron_left_rounded, color: DriverUi.muted),
            ],
          ),
        ),
      ),
    );
  }
}
