import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/design/shell.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/design/widgets.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/widgets/success_badge.dart';
import 'package:project/driver/features/orders/presentation/driver_page.dart';

/// نجاح التسليم. منقولة من d1d6084:lib/features/driver/driver.dart (DriverDeliveredScreen).
class DriverDeliveredScreen extends StatelessWidget {
  const DriverDeliveredScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final l = context.l10n;
    final d = driverCtl();
    final args = ModalRoute.settingsOf(context)?.arguments ?? Get.arguments;
    final earning = (args is Map ? args['earning'] : null) as int? ?? 0;
    final code = args is Map ? args['code']?.toString() : null;
    return Page2(
      center: true,
      body: Obx(() => Column(mainAxisSize: MainAxisSize.min, children: [
            SuccessBadge(eventKey: (code ?? '').isEmpty ? null : 'delivered:$code', semanticsLabel: l.celebrationDelivered),
            const SizedBox(height: 24),
            Text(l.driverDeliveredTitle, style: T.d2(c.tx)),
            const SizedBox(height: 8),
            Text(l.driverDeliveredBody, style: T.bd(c.tx2)),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l.driverTaskEarning, style: T.cap(c.tx2)), Mny(earning, size: 24)]))),
              const SizedBox(width: 12),
              Expanded(child: Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l.driverCashOnHandNow, style: T.cap(c.tx2)), Mny(d.cash.value?.onHand.amount ?? 0, size: 24)]))),
            ]),
          ])),
      foot: Foot(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SBtn(l.driverAvailableOrders, full: true, onTap: () => Get.offAllNamed('/driver/available')),
          const SizedBox(height: 8),
          SBtn(l.driverHomeAction, kind: BtnKind.ghost, full: true, onTap: () => Get.offAllNamed('/driver/home')),
        ]),
      ),
    );
  }
}
