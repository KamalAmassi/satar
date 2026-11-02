import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/errors/failure_message.dart';
import 'package:project/core/l10n/app_localizations.dart';
import 'package:project/core/utils/view_status.dart';
import 'package:project/core/widgets/app_state_view.dart';
import 'package:project/driver/features/auth/presentation/widgets/header_driver.dart';
import 'package:project/driver/features/current_task/presentation/controllers/current_task_controller.dart';
import 'package:project/driver/features/current_task/presentation/widgets/task_accepted_widget.dart';
import 'package:project/driver/features/current_task/presentation/widgets/task_details_widget.dart';
import 'package:project/driver/features/current_task/presentation/widgets/task_pickup_loading_widget.dart';
import 'package:project/driver/shared/driver_models.dart';
import 'package:project/driver/shared/presentation/driver_ui.dart';

/// تاب "المهمة": يختار الشاشة حسب حالة التحميل وحالة الطلب القادمة من السيرفر.
class DriverCurrentTaskView extends GetView<DriverCurrentTaskController> {
  const DriverCurrentTaskView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: DriverUi.bg,
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          switch (controller.status.value) {
            case ViewStatus.loading:
              return _withHeader(
                l10n,
                const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
              );
            case ViewStatus.error:
              final f = controller.failure.value;
              final offline = f is NetworkFailure || f is TimeoutFailure;
              return _withHeader(
                l10n,
                AppStateView(
                  icon: offline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
                  tone: AppStateTone.error,
                  title: offline ? l10n.drTaskOfflineTitle : l10n.drTaskErrorTitle,
                  message: f == null ? null : failureMessage(l10n, f),
                  primaryLabel: l10n.retry,
                  onPrimary: controller.load,
                ),
              );
            case ViewStatus.empty:
              return _withHeader(
                l10n,
                AppStateView(
                  icon: Icons.assignment_outlined,
                  title: l10n.drTaskEmptyTitle,
                  message: l10n.drTaskEmptyBody,
                  primaryLabel: l10n.drTaskGoOrders,
                  onPrimary: controller.goToOrders,
                ),
              );
            case ViewStatus.success:
              final order = controller.task.value!;
              if (controller.isTransitioning.value) {
                return const TaskPickupLoadingWidget();
              }
              if (order.status.key == StatusKeys.accepted) {
                return TaskAcceptedWidget(order: order, controller: controller);
              }
              return TaskDetailsWidget(order: order, controller: controller);
          }
        }),
      ),
      // لا يوجد bottomNavigationBar هنا: الشريط السفلي من DriverShellView.
    );
  }

  Widget _withHeader(AppLocalizations l10n, Widget body) {
    return Column(children: [headerDriver(l10n), Expanded(child: body)]);
  }
}
