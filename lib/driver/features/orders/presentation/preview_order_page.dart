import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:project/core/design/shell.dart';
import 'package:project/core/widgets/route_map.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/design/widgets.dart';
import 'package:project/core/errors/api_error_codes.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/network/idempotency.dart';
import 'package:project/core/utils/haptics.dart';
import 'package:project/core/data/models.dart';
import 'package:project/driver/features/orders/presentation/driver_page.dart';
import 'package:project/core/widgets/common_widgets.dart';

class DriverPreviewScreen extends StatefulWidget {
  const DriverPreviewScreen({super.key});
  @override
  State<DriverPreviewScreen> createState() => _DriverPreviewScreenState();
}

class _DriverPreviewScreenState extends State<DriverPreviewScreen> {
  final DriverOrderModel? o = Get.arguments is Map && Get.arguments['order'] is DriverOrderModel ? Get.arguments['order'] as DriverOrderModel : null;
  int get id => o?.id ?? 0;
  bool busy = false;
  final key = IdempotencyKey.generate();

  void _toAvailable() {
    if (Get.isDialogOpen ?? false) Get.back();
    Get.offAllNamed('/driver/available');
  }

  Future<void> _accept() async {
    if (busy || id == 0) return;
    final l = context.l10n;
    final d = driverCtl();
    if (d.me.value != null && !d.me.value!.isOnline) {
      _offlineDlg();
      return;
    }
    setState(() => busy = true);
    final r = await backend.driverAccept(id, key);
    if (!mounted) return;
    setState(() => busy = false);
    r.fold((e) {
      Haptics.error();
      if (e is NetworkFailure || e is TimeoutFailure) {
        showDlg(context, kind: 'warn', icon: 'wifiOff', title: l.driverNetworkTitle, text: failureText(e), foot: [
          SBtn(l.commonRetry, full: true, onTap: () {
            Get.back();
            _accept();
          }),
          SBtn(l.commonClose, kind: BtnKind.ghost, full: true, onTap: () => Get.back()),
        ]);
      } else if (e is UnauthorizedFailure || e.code == ApiErrorCodes.unauthenticated) {
        showDlg(context, kind: 'err', icon: 'alert', title: l.driverSessionExpiredTitle, text: l.driverSessionExpiredText, foot: [SBtn(l.driverSignIn, full: true, onTap: () => Get.offAllNamed('/auth/phone'))]);
      } else if (e.code == ApiErrorCodes.notFound) {
        showDlg(context, kind: 'warn', icon: 'alert', title: l.driverOrderUnavailableTitle, text: l.driverOrderUnavailableText, foot: [SBtn(l.driverAvailableOrders, full: true, onTap: _toAvailable)]);
      } else if (e.code == ApiErrorCodes.alreadyTaken || e.code == ApiErrorCodes.conflict) {
        showDlg(context, kind: 'warn', icon: 'alert', title: 'سبقك سائق آخر', text: 'قُبل هذا الطلب قبل لحظات. سنعرض لك طلبات أخرى قريبة.', foot: [SBtn('الطلبات المتاحة', full: true, onTap: _toAvailable)]);
      } else if (e.code == ApiErrorCodes.cashLimitReached) {
        showDlg(context, kind: 'err', icon: 'wallet', title: 'وصلت للحد الأقصى للنقد', text: 'سلّم النقد للمشغّل لتتمكن من قبول طلبات جديدة.', foot: [
          SBtn('عرض تفاصيل النقد', full: true, onTap: () {
            Get.back();
            Get.toNamed('/driver/cash');
          }),
          SBtn('إغلاق', kind: BtnKind.ghost, full: true, onTap: () => Get.back()),
        ]);
      } else if (e.code == ApiErrorCodes.validationFailed || e.code == ApiErrorCodes.invalidTransition) {
        d.refreshAll().then((_) {
          if (!mounted) return;
          if (d.me.value != null && !d.me.value!.isOnline) {
            _offlineDlg();
          } else {
            final msg = (e.message ?? '').trim();
            showDlg(context, kind: 'warn', icon: 'alert', title: l.driverAcceptInvalidTitle, text: msg.isEmpty ? l.driverAcceptInvalidText : msg, foot: [SBtn(l.commonOk, full: true, onTap: () => Get.back())]);
          }
        });
      } else {
        showDlg(context, kind: 'warn', icon: 'alert', title: l.driverAcceptInvalidTitle, text: failureText(e), foot: [SBtn(l.commonOk, full: true, onTap: () => Get.back())]);
      }
    }, (_) async {
      Haptics.confirm();
      await d.refreshAll();
      Get.offNamed('/driver/task');
    });
  }

  void _offlineDlg() {
    final l = context.l10n;
    showDlg(context, kind: 'warn', icon: 'power', title: l.driverAcceptOfflineTitle, text: l.driverAcceptOfflineText, foot: [
      SBtn(l.driverGoOnline, full: true, onTap: () async {
        Get.back();
        final err = await driverCtl().setOnline(true);
        if (!mounted) return;
        if (err != null) {
          showToast(err, icon: 'alertC');
        } else {
          _accept();
        }
      }),
      SBtn(l.commonClose, kind: BtnKind.ghost, full: true, onTap: () => Get.back()),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final l = context.l10n;
    final x = o;
    if (x == null) {
      return Page2(top: const TopBar(title: ''), center: true, body: EmptyState(ill: 'route', title: l.driverOrderUnavailableTitle, text: l.driverOrderUnavailableText, cta: SBtn(l.driverAvailableOrders, full: true, onTap: _toAvailable)));
    }
    return Page2(
      top: TopBar(title: x.code),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        RouteMap(height: 180, radius: Rad.l, pickup: x.pickup.lat == null ? null : LatLng(x.pickup.lat!, x.pickup.lng!), drop: x.dropoff.lat == null ? null : LatLng(x.dropoff.lat!, x.dropoff.lng!)),
        const SizedBox(height: 24),
        Row(children: [
          Expanded(child: Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('ربحك', style: T.cap(c.tx2)), Mny(x.earning.amount, size: 26)]))),
          const SizedBox(width: 12),
          Expanded(child: Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('تحصيل نقدي', style: T.cap(c.tx2)), Mny(x.collect.amount, size: 26)]))),
        ]),
        const SizedBox(height: 24),
        Card2(child: Column(children: [
          if (x.distanceToPickupKm != null) KV('المسافة إلى المكتبة', null, vWidget: Num('${x.distanceToPickupKm!.toStringAsFixed(1)} كم', style: TextStyle(fontFamily: Fonts.ui, fontWeight: FontWeight.w700, color: c.tx))),
          KV('مسافة التوصيل', null, vWidget: Num('${x.distanceKm.toStringAsFixed(1)} كم', style: TextStyle(fontFamily: Fonts.ui, fontWeight: FontWeight.w700, color: c.tx))),
          if (x.itemsCount != null) KV('المنتجات', '${x.itemsCount} منتجات'),
          KV('الدفع', x.isCash ? 'نقدًا عند التسليم' : 'مدفوع مسبقًا'),
        ])),
        const SizedBox(height: 24),
        const Note('plum', text: 'اسم الزبون وتفاصيل العنوان تظهر بعد قبول المهمة.'),
      ]),
      foot: FootBar(child: Column(mainAxisSize: MainAxisSize.min, children: [
        SBtn('اقبل المهمة', full: true, loading: busy, hapticOnPress: false, onTap: _accept),
        const SizedBox(height: 8),
        SBtn('إخفاء الطلب', kind: BtnKind.ghost, full: true, onTap: () async {
          await backend.driverReject(id);
          Get.back();
        }),
      ])),
    );
  }
}
