import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';
import 'package:project/core/errors/failure_message.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/utils/view_status.dart';
import 'package:project/core/widgets/app_skeleton.dart';
import 'package:project/core/widgets/app_state_view.dart';
import 'package:project/driver/features/notifications/presentation/controllers/notifications_controller.dart';
import 'package:project/driver/features/notifications/presentation/widgets/notification_tile.dart';
import 'package:project/driver/shared/presentation/driver_ui.dart';

class DriverNotificationsView extends GetView<DriverNotificationsController> {
  const DriverNotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: DriverUi.bg,
      appBar: AppBar(backgroundColor: DriverUi.bg, title: Text(l10n.drNotificationsTitle)),
      body: Obx(() {
        switch (controller.status.value) {
          case ViewStatus.loading:
            return const AppSkeletonList(count: 4, itemHeight: 72);
          case ViewStatus.empty:
            return AppStateView(
              icon: Icons.notifications_none_rounded,
              title: l10n.drNotificationsEmptyTitle,
              message: l10n.drNotificationsEmptyBody,
            );
          case ViewStatus.error:
            return AppStateView(
              icon: Icons.error_outline_rounded,
              tone: AppStateTone.error,
              title: l10n.drNotificationsErrorTitle,
              message: controller.failure.value == null
                  ? null
                  : failureMessage(l10n, controller.failure.value!),
              primaryLabel: l10n.retry,
              onPrimary: controller.load,
            );
          case ViewStatus.success:
            return RefreshIndicator(
              onRefresh: controller.load,
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSizes.pagePadding),
                itemCount: controller.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
                itemBuilder: (_, i) => NotificationTile(item: controller.items[i]),
              ),
            );
        }
      }),
    );
  }
}
