import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/routes/app_routes.dart';
import 'package:project/core/widgets/app_state_view.dart';
import 'package:project/driver/shared/presentation/driver_ui.dart';

/// "تم تسجيل تعذّر التسليم"
class DriverFailureRecordedView extends StatelessWidget {
  const DriverFailureRecordedView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: DriverUi.bg,
        body: SafeArea(
          child: AppStateView(
            icon: Icons.report_gmailerrorred_rounded,
            tone: AppStateTone.error,
            title: l10n.drFailureRecordedTitle,
            message: l10n.drFailureRecordedBody,
            primaryLabel: l10n.drFailureViewTask,
            onPrimary: () => Get.offAllNamed(DriverRoutes.home, arguments: {'tab': 2}),
            secondaryLabel: l10n.drDeliverySuccessHome,
            onSecondary: () => Get.offAllNamed(DriverRoutes.home, arguments: {'tab': 0}),
          ),
        ),
      ),
    );
  }
}
