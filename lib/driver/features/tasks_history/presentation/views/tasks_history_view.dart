import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';
import 'package:project/core/errors/failure_message.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/utils/view_status.dart';
import 'package:project/core/widgets/app_skeleton.dart';
import 'package:project/core/widgets/app_state_view.dart';
import 'package:project/driver/features/tasks_history/presentation/controllers/tasks_history_controller.dart';
import 'package:project/driver/features/tasks_history/presentation/widgets/history_tile.dart';
import 'package:project/driver/shared/presentation/widgets/driver_app_bar.dart';
import 'package:project/driver/shared/presentation/driver_ui.dart';

class DriverTasksHistoryView extends GetView<DriverTasksHistoryController> {
  const DriverTasksHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: DriverUi.bg,
      appBar: driverAppBar(l10n.drHistoryTitle),
      body: Obx(() {
        switch (controller.status.value) {
          case ViewStatus.loading:
            return const AppSkeletonList(count: 5, itemHeight: 72);
          case ViewStatus.empty:
            return AppStateView(
              icon: Icons.history_rounded,
              title: l10n.drHistoryEmptyTitle,
              message: l10n.drHistoryEmptyBody,
            );
          case ViewStatus.error:
            return AppStateView(
              icon: Icons.error_outline_rounded,
              tone: AppStateTone.error,
              title: l10n.drHistoryErrorTitle,
              message: controller.failure.value == null
                  ? null
                  : failureMessage(l10n, controller.failure.value!),
              primaryLabel: l10n.retry,
              onPrimary: controller.load,
            );
          case ViewStatus.success:
            return RefreshIndicator(
              onRefresh: () => controller.load(silent: true),
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSizes.pagePadding),
                itemCount: controller.tasks.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSizes.md),
                itemBuilder: (_, i) => HistoryTile(
                  order: controller.tasks[i],
                  onTap: () => controller.open(controller.tasks[i]),
                ),
              ),
            );
        }
      }),
    );
  }
}
