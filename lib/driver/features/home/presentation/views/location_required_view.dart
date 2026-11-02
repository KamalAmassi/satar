import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/services/location_service.dart';
import 'package:project/core/widgets/app_state_view.dart';
import 'package:project/driver/features/home/presentation/controllers/driver_session_controller.dart';
import 'package:project/driver/shared/presentation/driver_ui.dart';

/// "نحتاج موقعك" — تظهر لما الإذن مرفوض أو الـ GPS مغلق.
class DriverLocationRequiredView extends StatelessWidget {
  const DriverLocationRequiredView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final issue = Get.arguments is LocationIssue
        ? Get.arguments as LocationIssue
        : LocationIssue.denied;
    final home = Get.find<DriverSessionController>();
    final service = Get.find<LocationService>();

    final serviceOff = issue == LocationIssue.serviceDisabled;
    final forever = issue == LocationIssue.deniedForever;

    return Scaffold(
      backgroundColor: DriverUi.bg,
      appBar: AppBar(backgroundColor: DriverUi.bg),
      body: AppStateView(
        icon: serviceOff ? Icons.location_disabled_outlined : Icons.location_on_outlined,
        tone: AppStateTone.warning,
        title: serviceOff ? l10n.drLocationServiceOffTitle : l10n.drLocationRequiredTitle,
        message: serviceOff ? l10n.drLocationServiceOffBody : l10n.drLocationRequiredBody,
        primaryLabel:
        (serviceOff || forever) ? l10n.drLocationOpenSettings : l10n.drLocationGrant,
        onPrimary: () async {
          if (serviceOff || forever) {
            await service.openSettings();
          } else {
            await home.retryAfterLocationGranted();
          }
        },
        secondaryLabel: l10n.drCommonBack,
        onSecondary: Get.back,
      ),
    );
  }
}
