// منقولة من d1d6084:lib/features/orders/orders.dart (RateScreen).
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

class RateScreen extends StatefulWidget {
  const RateScreen({super.key});
  @override
  State<RateScreen> createState() => _RateScreenState();
}

class _RateScreenState extends State<RateScreen> {
  final int orderId = RouteArgs.readOrderId() ?? 0;
  int stars = 0, vstars = 0;
  final comment = TextEditingController();
  bool busy = false;
  String? err;
  OrderModel? order;

  @override
  void initState() {
    super.initState();
    backend.order(orderId).then((r) => r.fold((_) {}, (o) => mounted ? setState(() => order = o) : null));
  }

  @override
  void dispose() {
    comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final dn = order?.driver?.name ?? '';
    return Page2(
      top: const TopBar(title: 'قيّم طلبك'),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Card2(child: Column(children: [
          Avatar(dn.isEmpty ? 'س' : firstCh(dn), large: true),
          const SizedBox(height: 12),
          Text(dn.isEmpty ? 'كيف كان التوصيل؟' : 'كيف كان التوصيل مع $dn؟', textAlign: TextAlign.center, style: T.h3(c.tx)),
          const SizedBox(height: 12),
          Stars(stars, big: true, onPick: (v) => setState(() => stars = v)),
          const SizedBox(height: 16),
          Fld(hint: 'أخبرنا برأيك (اختياري)', controller: comment, maxLines: 3),
        ])),
        const SizedBox(height: 24),
        Card2(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('قيّم المكتبة', style: T.h3(c.tx, size: 15.5)), const STag('اختياري', kind: 'gray')]),
          const SizedBox(height: 8),
          Stars(vstars, big: true, onPick: (v) => setState(() => vstars = v)),
        ])),
        if (err != null) ...[const SizedBox(height: 16), Note('err', text: err)],
      ]),
      foot: FootBar(child: SBtn('إرسال التقييم', full: true, loading: busy, disabled: stars == 0, onTap: () async {
        setState(() {
          busy = true;
          err = null;
        });
        final r = await backend.rate(orderId, stars: stars, comment: comment.text, vendorStars: vstars);
        if (!mounted) return;
        setState(() => busy = false);
        r.fold((f) => setState(() => err = f.code == ApiErrorCodes.invalidTransition || f.code == ApiErrorCodes.conflict ? 'تم تقييم هذا الطلب سابقًا.' : failureText(f)), (_) {
          showToast('شكرًا لتقييمك');
          Get.back();
          if (Get.isRegistered<OrderDetailController>()) Get.find<OrderDetailController>().load();
        });
      })),
    );
  }
}

// ----------------------------------------------------------------- receipt

