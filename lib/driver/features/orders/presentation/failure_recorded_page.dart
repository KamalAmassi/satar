import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/design/illustrations.dart';
import 'package:project/core/design/shell.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/design/widgets.dart';

class DriverFailureRecordedScreen extends StatelessWidget {
  const DriverFailureRecordedScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Page2(
      center: true,
      body: Column(mainAxisSize: MainAxisSize.min, children: [
        const Ill('wait', width: 190),
        const SizedBox(height: 24),
        Text('سُجّل تعذّر التسليم', style: T.d2(c.tx)),
        const SizedBox(height: 8),
        Text('شكرًا. ستتابع الإدارة الطلب.', textAlign: TextAlign.center, style: T.bd(c.tx2)),
      ]),
      foot: Foot(child: SBtn('الرئيسية', full: true, onTap: () => Get.offAllNamed('/driver/home'))),
    );
  }
}
