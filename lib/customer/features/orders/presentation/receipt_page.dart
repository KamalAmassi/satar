// منقولة من d1d6084:lib/features/orders/orders.dart (ReceiptScreen).
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:project/core/data/models.dart';
import 'package:project/core/design/icons.dart';
import 'package:project/core/design/illustrations.dart';
import 'package:project/core/design/shell.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/design/widgets.dart';
import 'package:project/core/errors/api_error_codes.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/routes/route_args.dart';
import 'package:project/core/widgets/common_widgets.dart';
import 'package:project/core/widgets/delivery_code_panel.dart';
import 'package:project/core/widgets/driver_status_chip.dart';
import 'package:project/core/widgets/route_map.dart';
import 'package:project/core/widgets/success_badge.dart';
import 'package:project/customer/features/catalog/presentation/catalog_page.dart';
import 'package:project/customer/features/orders/presentation/orders_page.dart';

class ReceiptScreen extends StatefulWidget {
  const ReceiptScreen({super.key});
  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  final int orderId = RouteArgs.readOrderId() ?? 0;
  ReceiptModel? r;
  Failure? f;
  @override
  void initState() {
    super.initState();
    backend.receipt(orderId).then((x) => x.fold((e) => mounted ? setState(() => f = e) : null, (v) => mounted ? setState(() => r = v) : null));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final en = (Get.locale?.languageCode ?? 'ar') == 'en';
    final x = r;
    if (x == null) return Page2(top: const TopBar(title: 'الإيصال'), body: f == null ? const Skel(h: 300, r: 20) : EmptyState(ill: 'offline', title: 'تعذّر تحميل الإيصال', text: failureText(f!)));
    return Page2(
      top: const TopBar(title: 'الإيصال'),
      body: Card2(padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const SatrLogo(width: 84), StatusPill(r!.statusAr, label: en ? x.statusEn : x.statusAr, tone: 'ok')]),
        const SizedBox(height: 16),
        Text('رقم الطلب', style: T.cap(c.tx2)),
        Text(x.code, textDirection: TextDirection.ltr, textAlign: TextAlign.start, style: T.h2(c.tx)),
        const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider2()),
        KV('تاريخ الطلب', timeLabel(x.createdAt)),
        if (x.completedAt != null) KV('تاريخ التسليم', timeLabel(x.completedAt)),
        if (x.driver != null) KV('السائق', x.driver),
        KV('الدفع', x.paymentMethod == 'bank_transfer' ? 'تحويل بنكي' : 'نقدًا عند التسليم'),
        const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider2()),
        for (final it in x.items) KV('${it.$1} × ${it.$2}', ''),
        for (final l in x.lines) KV(en ? l.$2 : l.$1, null, vWidget: Mny(l.$3.amount)),
        KV('الإجمالي', null, total: true, vWidget: Mny(x.total.amount, size: 18)),
      ])),
    );
  }
}

// ----------------------------------------------------------- notifications

