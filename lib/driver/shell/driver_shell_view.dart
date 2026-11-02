import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/l10n/app_localizations.dart';
import 'package:project/driver/features/available_orders/presentation/views/available_orders_view.dart';
import 'package:project/driver/features/current_task/presentation/views/current_task_view.dart';
import 'package:project/driver/features/home/presentation/views/home_view.dart';
import 'package:project/driver/features/profile/presentation/views/profile_view.dart';
import 'package:project/driver/shared/presentation/driver_ui.dart';
import 'package:project/driver/shell/driver_bottom_nav.dart';
import 'package:project/driver/shell/driver_shell_controller.dart';

class DriverShellView extends GetView<DriverShellController> {
  const DriverShellView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = [
      DriverNavItem(icon: Icons.home_filled, label: l10n.drNavHome),
      DriverNavItem(icon: Icons.local_shipping_outlined, label: l10n.drNavOrders),
      DriverNavItem(icon: Icons.explore_outlined, label: l10n.drNavTask),
      DriverNavItem(icon: Icons.person_outline_rounded, label: l10n.drNavProfile),
    ];

    return Obx(
      () => Scaffold(
        backgroundColor: DriverUi.bg,
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: const [
            DriverHomeView(),
            DriverAvailableOrdersView(),
            DriverCurrentTaskView(),
            DriverProfileView(),
          ],
        ),
        bottomNavigationBar: DriverBottomNav(
          items: items,
          selectedIndex: controller.currentIndex.value,
          onSelected: controller.goToTab,
        ),
      ),
    );
  }
}
