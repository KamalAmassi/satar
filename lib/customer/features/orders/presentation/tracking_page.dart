// منقولة من d1d6084:lib/features/orders/orders.dart (TrackingController/TrackingScreen/PublicTrackScreen).
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

class TrackingController extends GetxController {
  final int orderId = RouteArgs.readOrderId() ?? 0;
  final data = Rxn<TrackingModel>();
  final order = Rxn<OrderModel>();
  final failure = Rxn<Failure>();
  final loading = true.obs;
  Timer? _t;
  bool paused = false;
  bool _closed = false;

  @override
  void onInit() {
    super.onInit();
    backend.order(orderId).then((r) => r.fold((_) {}, (o) => order.value = o));
    poll();
  }

  Future<void> poll() async {
    if (paused || _closed) return;
    final r = await backend.tracking(orderId);
    if (_closed) return;
    r.fold((f) {
      failure.value = f;
      if (f.code == ApiErrorCodes.tooManyRequests) {
        paused = true;
        final s = f is ServerFailure ? (f.retryAfterSeconds ?? 30) : 30;
        Future.delayed(Duration(seconds: s), () {
          paused = false;
          poll();
        });
      }
    }, (d) {
      data.value = d;
      failure.value = null;
    });
    loading.value = false;
    _t?.cancel();
    final next = data.value?.nextPollSeconds ?? 10;
    _t = Timer(Duration(seconds: next < 5 ? 5 : next), poll);
  }

  @override
  void onClose() {
    _closed = true;
    _t?.cancel();
    super.onClose();
  }
}


class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final ctl = Get.put(TrackingController());
    return Obx(() {
      final d = ctl.data.value;
      final o = ctl.order.value;
      if (d == null) {
        return Page2(top: const TopBar(title: 'تتبّع الطلب'), center: true, body: ctl.loading.value ? const Skel(h: 200, r: 20) : EmptyState(ill: 'route', title: 'التتبع غير متاح الآن', text: ctl.failure.value == null ? 'سيظهر موقع السائق عند بدء التوصيل.' : failureText(ctl.failure.value!), cta: SBtn('أعد المحاولة', full: true, onTap: ctl.poll)));
      }
      final driverPt = d.hasLocation ? LatLng(d.driverLat!, d.driverLng!) : null;
      final live = !d.status.isTerminal;
      return Page2(
        top: TopBar(title: 'تتبّع الطلب', right: SIconBtn('share', onTap: o == null ? null : () => shareSheet(context, o.id))),
        flush: true,
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Stack(children: [
            RouteMap(height: 360, pickup: d.pickupLat == null ? null : LatLng(d.pickupLat!, d.pickupLng!), drop: d.dropLat == null ? null : LatLng(d.dropLat!, d.dropLng!), driver: driverPt, driverSeenAt: d.lastSeenAt, live: live, tail: [for (final p in d.tail) LatLng(p.$1, p.$2)]),
            PositionedDirectional(top: 12, start: 16, end: 16, child: DriverStatusChip(hasLocation: d.hasLocation, seenAt: d.lastSeenAt, etaMinutes: d.etaMinutes, live: live)),
          ]),
          Transform.translate(
            offset: const Offset(0, -20),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
              decoration: BoxDecoration(color: c.bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('الوصول المتوقع', style: T.cap(c.tx2)), Text(d.etaMinutes == null ? '—' : '~${d.etaMinutes} دقيقة', style: TextStyle(fontFamily: Fonts.ui, fontSize: 30, fontWeight: FontWeight.w700, height: 1.2, color: c.tx))]),
                  StatusPill(d.status.key, label: statusLabel(d.status)),
                ]),
                const SizedBox(height: 24),
                if (d.driverName != null)
                  Card2(child: Row(children: [
                    Avatar(d.driverName!.isEmpty ? 'س' : firstCh(d.driverName!)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${d.driverName} · ${kVehicleLabels[d.vehicleType] ?? ''}', style: T.h3(c.tx, size: 15.5)), Row(children: [SIcon('star', size: 14, color: c.amber, filled: true), const SizedBox(width: 4), Text('${d.rating.toStringAsFixed(1)} (${d.ratingCount})', style: T.sm(c.tx))])])),
                    SIconBtn('phone', tonal: true, size: 22, onTap: () => callPhone(d.driverPhone)),
                  ])),
                if ((o?.deliveryCode ?? '').isNotEmpty && !o!.status.isTerminal && !const {'delivered', 'completed', 'cancelled', 'canceled'}.contains(o.status.key)) ...[const SizedBox(height: 24), DeliveryCodePanel(o.deliveryCode!)],
                const SizedBox(height: 24),
                Text('الموقع تقريبي ويُحدَّث دوريًا، وليس بثًا لحظيًا.', textAlign: TextAlign.center, style: T.sm(c.tx2)),
              ]),
            ),
          ),
        ]),
      );
    });
  }
}

// ------------------------------------------------------------ public track

class PublicTrackScreen extends StatefulWidget {
  const PublicTrackScreen({super.key});
  @override
  State<PublicTrackScreen> createState() => _PublicTrackScreenState();
}

class _PublicTrackScreenState extends State<PublicTrackScreen> {
  PublicTrackingModel? d;
  Failure? f;
  Timer? t;
  late final String token = (Get.arguments is Map ? Get.arguments['token'] : null) as String? ?? '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await backend.publicTracking(token);
    if (!mounted) return;
    r.fold((e) => setState(() => f = e), (v) => setState(() {
          d = v;
          f = null;
        }));
    t?.cancel();
    if (mounted) t = Timer(Duration(seconds: d?.pollSeconds ?? 15), _load);
  }

  @override
  void dispose() {
    t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    if (d == null) return Page2(top: const TopBar(title: 'تتبّع الطلب'), center: true, body: f == null ? const Skel(h: 200, r: 20) : EmptyState(ill: 'route', title: 'الرابط غير صالح', text: 'انتهت صلاحية الرابط أو أُوقفت مشاركته.', cta: SBtn('أعد المحاولة', full: true, onTap: _load)));
    final x = d!;
    return Page2(
      flush: true,
      top: const TopBar(title: ''),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          color: c.hero,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
          child: DefaultTextStyle(style: TextStyle(fontFamily: Fonts.ui, color: c.onHero), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SatrLogo(width: 96),
            const SizedBox(height: 6),
            Text('طلب ${x.code}', style: T.eyebrow(c.onHero.withValues(alpha: .75))),
            Text(statusLabel(x.status), style: T.d2(c.onHero)),
            if (x.etaMinutes != null) Text('الوصول المتوقع خلال ~${x.etaMinutes} دقيقة', style: T.sm(c.onHero.withValues(alpha: .85))),
          ])),
        ),
        RouteMap(height: 300, drop: x.dropLat == null ? null : LatLng(x.dropLat!, x.dropLng!), driver: x.driverLat == null ? null : LatLng(x.driverLat!, x.driverLng!)),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (x.driverFirstName != null) Card2(child: Row(children: [Avatar(x.driverFirstName!.isEmpty ? 'س' : firstCh(x.driverFirstName!)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('يوصّل طلبك: ${x.driverFirstName}', style: T.h3(c.tx, size: 15.5)), Text('الموقع تقريبي', style: T.sm(c.tx2))]))])),
            const SizedBox(height: 16),
            Card2(child: SatrTimeline([for (var i = 0; i < x.timeline.length; i++) TimelineItem(x.timeline[i].$1, x.timeline[i].$2 == null ? null : '${two(x.timeline[i].$2!.hour)}:${two(x.timeline[i].$2!.minute)}', done: i < x.timeline.length - 1 || x.status.isTerminal, cur: i == x.timeline.length - 1 && !x.status.isTerminal, check: i < x.timeline.length - 1 || x.status.isTerminal)])),
            const SizedBox(height: 16),
            Text('يتحدّث تلقائيًا · الرابط ينتهي بعد 48 ساعة من إنشائه', textAlign: TextAlign.center, style: T.cap(c.tx2)),
          ]),
        ),
      ]),
    );
  }
}

// --------------------------------------------------------------------- rate

