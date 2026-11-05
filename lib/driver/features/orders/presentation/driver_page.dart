import 'dart:async';

import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard;
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/widgets/success_badge.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:project/core/config/remote_config_repository.dart';
import 'package:project/core/design/icons.dart';
import 'package:project/core/design/illustrations.dart';
import 'package:project/core/design/shell.dart';
import 'package:project/core/widgets/route_map.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/design/widgets.dart';
import 'package:project/core/errors/api_error_codes.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/network/idempotency.dart';
import 'package:project/core/uploads/upload_repository.dart';
import 'package:project/core/utils/haptics.dart';
import 'package:project/core/motion/entrance.dart' show ShakeOnChange;
import 'package:project/core/data/models.dart';
import 'package:project/driver/features/orders/presentation/deliver_order_page.dart';
import 'package:project/core/widgets/common_widgets.dart';
import 'package:project/customer/features/orders/presentation/orders_page.dart';

const _tab = TabRole.driver;

typedef LocPoint = ({double lat, double lng, double? accuracy, double? speed, double? heading, DateTime at});

class DriverLocationService extends GetxService {
  StreamSubscription<Position>? _sub;
  final buffer = <LocPoint>[];
  final offline = false.obs;
  final lastPosition = Rxn<Position>();
  DateTime? _lastSend;
  bool _sending = false;

  int get minInterval => (Get.find<RemoteConfigRepository>().current?.locationMinIntervalSeconds ?? 5).clamp(3, 120);

  Future<bool> ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;
    var p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) p = await Geolocator.requestPermission();
    return p == LocationPermission.whileInUse || p == LocationPermission.always;
  }

  Future<Position?> fresh() async {
    try {
      final p = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
      lastPosition.value = p;
      return p;
    } catch (_) {
      return null;
    }
  }

  LocPoint _pt(Position p) => (lat: p.latitude, lng: p.longitude, accuracy: p.accuracy, speed: p.speed, heading: p.heading, at: p.timestamp);

  Future<Failure?> pushNow() async {
    final p = await fresh();
    if (p == null) return const UnknownFailure(message: 'تعذّر تحديد موقعك.');
    buffer.add(_pt(p));
    return await _flush(force: true);
  }

  void start() {
    if (_sub != null) return;
    final settings = defaultTargetPlatform == TargetPlatform.android
        ? AndroidSettings(accuracy: LocationAccuracy.high, distanceFilter: 0, intervalDuration: Duration(seconds: minInterval))
        : const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 0);
    _sub = Geolocator.getPositionStream(locationSettings: settings).listen((p) {
      lastPosition.value = p;
      buffer.add(_pt(p));
      if (buffer.length > 100) buffer.removeRange(0, buffer.length - 100);
      _flush();
    }, onError: (_) {});
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
  }

  Future<Failure?> _flush({bool force = false}) async {
    if (_sending || buffer.isEmpty) return null;
    final now = DateTime.now();
    if (!force && _lastSend != null && now.difference(_lastSend!).inSeconds < minInterval) return null;
    _sending = true;
    final batch = buffer.take(100).toList();
    final r = await backend.driverLocation(batch);
    _sending = false;
    return r.fold((f) {
      offline.value = f is NetworkFailure || f is TimeoutFailure;
      if (f.code == ApiErrorCodes.tooManyRequests) _lastSend = DateTime.now().add(const Duration(seconds: 20));
      return f;
    }, (_) {
      buffer.removeRange(0, batch.length);
      offline.value = false;
      _lastSend = DateTime.now();
      return null;
    });
  }
}

class DriverController extends GetxController {
  final me = Rxn<DriverModel>();
  final current = Rxn<DriverOrderModel>();
  final cash = Rxn<CashModel>();
  final today = Rxn<EarningsModel>();
  final unread = 0.obs;
  final loading = true.obs;
  final failure = Rxn<Failure>();
  final togglingOnline = false.obs;
  Timer? _t;

  DriverLocationService get loc => Get.find<DriverLocationService>();

  @override
  void onInit() {
    super.onInit();
    refreshAll();
    _t = Timer.periodic(const Duration(seconds: 15), (_) => refreshQuiet());
  }

  Future<void> refreshAll() async {
    final r = await Future.wait([backend.driverMe(), backend.driverCurrent(), backend.driverCash(), backend.driverEarnings('day')]);
    r[0].fold((f) => failure.value = f, (v) {
      me.value = v as DriverModel;
      failure.value = null;
    });
    r[1].fold((_) {}, (v) => current.value = v as DriverOrderModel?);
    r[2].fold((_) {}, (v) => cash.value = v as CashModel);
    r[3].fold((_) {}, (v) => today.value = v as EarningsModel);
    loading.value = false;
    _syncLocation();
    refreshUnread();
  }

  Future<void> refreshUnread() async {
    final r = await backend.notifications(driver: true, unread: true, perPage: 50);
    r.fold((_) {}, (v) => unread.value = v.length);
  }

  Future<void> refreshQuiet() async {
    final r = await Future.wait([backend.driverMe(), backend.driverCurrent()]);
    r[0].fold((_) {}, (v) => me.value = v as DriverModel);
    r[1].fold((_) {}, (v) => current.value = v as DriverOrderModel?);
    _syncLocation();
  }

  void _syncLocation() {
    if ((me.value?.isOnline ?? false) || current.value != null) {
      loc.start();
    } else {
      loc.stop();
    }
  }

  Future<String?> setOnline(bool online) async {
    if (togglingOnline.value) return null;
    togglingOnline.value = true;
    try {
      if (online) {
        if (!await loc.ensurePermission()) return 'perm';
        final f = await loc.pushNow();
        if (f != null && f is! ServerFailure) return failureText(f);
      }
      final r = await backend.driverStatus(online);
      return r.fold<String?>((f) => failureText(f), (_) {
        refreshAll();
        return null;
      });
    } finally {
      togglingOnline.value = false;
    }
  }

  @override
  void onClose() {
    _t?.cancel();
    super.onClose();
  }
}

DriverController driverCtl() => Get.isRegistered<DriverController>() ? Get.find<DriverController>() : Get.put(DriverController(), permanent: true);

Widget _driverTop(BuildContext context, DriverController d, {required String sub}) {
  final c = context.sc;
  final me = d.me.value;
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Flexible(child: GestureDetector(onTap: () => goTab('/driver/profile'), child: Row(children: [
          Avatar(me?.initial ?? 'س'),
          const SizedBox(width: 12),
          Flexible(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(sub, style: T.cap(c.tx2)), Text(me?.name ?? '…', maxLines: 1, overflow: TextOverflow.ellipsis, style: T.h3(c.tx))])),
        ]))),
        Row(children: [Obx(() => SIconBtn('bell', badge: d.unread.value > 0 ? '${d.unread.value}' : null, onTap: () async {
              await Get.toNamed('/driver/notifications');
              d.refreshUnread();
            })), const SizedBox(width: 4), _OnlineChip(d)]),
      ]),
    ),
  );
}

class _OnlineChip extends StatelessWidget {
  const _OnlineChip(this.d);
  final DriverController d;
  @override
  Widget build(BuildContext context) => Obx(() {
        final on = d.me.value?.isOnline ?? false;
        return SChip(on ? 'متصل' : 'غير متصل', on: on, height: 44, leading: on ? const LiveDot(color: Color(0xFF5BBE8A)) : PinDot(color: context.sc.tx3), onTap: () async {
          final r = await d.setOnline(!on);
          if (r == 'perm') {
            Get.toNamed('/driver/perm-location');
          } else if (r != null) {
            showToast(r, icon: 'alertC');
          }
        });
      });
}

Widget _cashMeter(BuildContext context, CashModel cash) {
  final c = context.sc;
  final max = cash.max.amount == 0 ? 1 : cash.max.amount;
  return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('نقد معك', style: T.sm(c.tx2)), Row(children: [Mny(cash.onHand.amount, size: 14), Text(' من ', style: T.sm(c.tx2)), Mny(cash.max.amount, size: 14, weight: FontWeight.w400)])]),
    const SizedBox(height: 8),
    ClipRRect(borderRadius: BorderRadius.circular(5), child: Container(height: 10, color: c.sf3, alignment: AlignmentDirectional.centerStart, child: FractionallySizedBox(widthFactor: (cash.onHand.amount / max).clamp(0.0, 1.0), child: Container(decoration: BoxDecoration(color: c.amber, borderRadius: BorderRadius.circular(5)))))),
  ]);
}

class DriverHomeScreen extends StatelessWidget {
  const DriverHomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final d = driverCtl();
    return Obx(() {
      final on = d.me.value?.isOnline ?? false;
      final cur = d.current.value;
      if (d.loading.value && d.me.value == null) return Page2(tab: 'home', role: _tab, body: const Column(children: [SizedBox(height: 12), Skel(h: 56), SizedBox(height: 16), Skel(h: 150, r: 28), SizedBox(height: 16), Skel(h: 80, r: 20)]));
      if (d.me.value == null) return Page2(tab: 'home', role: _tab, center: true, body: EmptyState(ill: 'offline', title: 'تعذّر التحميل', text: failureText(d.failure.value ?? const UnknownFailure()), cta: SBtn('أعد المحاولة', full: true, onTap: d.refreshAll)));
      return Page2(
        tab: 'home',
        role: _tab,
        top: _driverTop(context, d, sub: on ? 'جاهز للمهام' : 'غير متصل'),
        onRefresh: d.refreshAll,
        body: Padding(padding: const EdgeInsets.only(top: 8), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (!on && cur == null) ...[
            const SizedBox(height: 20),
            EmptyState(ill: 'route', title: 'أنت غير متصل', text: 'فعّل الاتصال لتصلك الطلبات القريبة. يحتاج التطبيق موقعك الحالي أولًا.', cta: SBtn('اتصل الآن', icon: 'power', full: true, loading: d.togglingOnline.value, onTap: () async {
              final r = await d.setOnline(true);
              if (r == 'perm') {
                Get.toNamed('/driver/perm-location');
              } else if (r != null) {
                showToast(r, icon: 'alertC');
              }
            })),
          ] else if (cur != null)
            Card2(onTap: () => Get.toNamed('/driver/task'), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('${cur.code} · مهمتك الحالية', style: T.cap(c.tx2)), StatusPill(cur.status.key, label: statusLabel(cur.status))]),
              const SizedBox(height: 16),
              Row(children: [SIcon('pin', size: 22, color: c.tx), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('من', style: T.cap(c.tx2)), Text(cur.pickup.line.isEmpty ? (cur.vendorName ?? 'المكتبة') : cur.pickup.line, style: T.h3(c.tx, size: 15.5))]))]),
              const SizedBox(height: 12),
              Row(children: [SIcon('nav', size: 22, color: c.tx), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('إلى', style: T.cap(c.tx2)), Text(cur.dropoff.line.isEmpty ? 'عنوان الزبون' : cur.dropoff.line, style: T.h3(c.tx, size: 15.5))]))]),
              const SizedBox(height: 12),
              if (cur.isCash) Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('تحصيل نقدي', style: T.sm(c.tx2)), Mny(cur.collect.amount)]),
              const SizedBox(height: 12),
              SBtn('تابع المهمة', icon: 'fwd', full: true, onTap: () => Get.toNamed('/driver/task')),
            ]))
          else
            FutureBuilder(
              future: backend.driverAvailable(),
              builder: (_, snap) {
                final n = snap.data?.fold((_) => 0, (r) => r.orders.length) ?? 0;
                return HeroBox(padding: const EdgeInsetsDirectional.fromSTEB(16, 18, 16, 18), child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(n == 0 ? 'لا طلبات الآن' : '$n ${n == 1 ? 'طلب قريب' : 'طلبات قريبة'}', style: T.d2(c.onHero, size: 24)),
                    const SizedBox(height: 8),
                    Text('ضمن ${(Get.find<RemoteConfigRepository>().current?.driverRadiusKm ?? 5).toStringAsFixed(0)} كم منك. الأقرب أولًا.', style: T.sm(c.onHero.withValues(alpha: .8))),
                    const SizedBox(height: 8),
                    SBtn('عرض الطلبات', size: BtnSize.sm, onTap: () => goTab('/driver/available')),
                  ])),
                  const Ill('route', width: 110),
                ]));
              },
            ),
          const SizedBox(height: 24),
          const SecHead('اليوم'),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('مهام منجزة', style: T.cap(c.tx2)), Text('${d.today.value?.orders ?? 0}', style: const TextStyle(fontFamily: Fonts.ui, fontSize: 26, fontWeight: FontWeight.w700))]))),
            const SizedBox(width: 12),
            Expanded(child: Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('الأرباح', style: T.cap(c.tx2)), Mny(d.today.value?.earnings.amount ?? 0, size: 26)]))),
          ]),
          const SizedBox(height: 24),
          if (d.cash.value != null) Card2(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _cashMeter(context, d.cash.value!),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(children: [Text('متبقي حتى الحد: ', style: T.sm(c.tx2)), Mny((d.cash.value!.remaining?.amount) ?? (d.cash.value!.max.amount - d.cash.value!.onHand.amount), size: 14)]), SBtn('التفاصيل', kind: BtnKind.ghost, size: BtnSize.xs, onTap: () => Get.toNamed('/driver/cash'))]),
          ])),
        ])),
      );
    });
  }
}

class DriverLocationPermScreen extends StatelessWidget {
  const DriverLocationPermScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final d = driverCtl();
    return Page2(
      center: true,
      body: Column(mainAxisSize: MainAxisSize.min, children: [
        const Ill('route', width: 200),
        const SizedBox(height: 24),
        Text('نحتاج موقعك لتتصل', textAlign: TextAlign.center, style: T.d2(context.sc.tx)),
        const SizedBox(height: 8),
        Text('يُستخدم موقعك لعرض الطلبات القريبة وتتبع التوصيل أثناء المهمة فقط.', textAlign: TextAlign.center, style: T.bd(context.sc.tx2)),
      ]),
      foot: Foot(child: Column(mainAxisSize: MainAxisSize.min, children: [
        SBtn('السماح بالموقع', icon: 'pin', full: true, onTap: () async {
          final ok = await d.loc.ensurePermission();
          if (ok) {
            final r = await d.setOnline(true);
            if (r != null && r != 'perm') showToast(r, icon: 'alertC');
            Get.back();
          } else {
            showToast('الموقع غير مفعّل. فعّله من إعدادات الجهاز.', icon: 'alertC', actionLabel: 'الإعدادات', onAction: ph.openAppSettings);
          }
        }),
        const SizedBox(height: 8),
        SBtn('ليس الآن', kind: BtnKind.ghost, full: true, onTap: () => Get.back()),
      ])),
    );
  }
}

class AvailableController extends GetxController {
  final list = <DriverOrderModel>[].obs;
  final reason = RxnString();
  final loading = true.obs;
  final failure = Rxn<Failure>();
  Timer? _t;
  @override
  void onInit() {
    super.onInit();
    load();
    _t = Timer.periodic(const Duration(seconds: 10), (_) => load(silent: true));
  }

  Future<void> load({bool silent = false}) async {
    if (!silent) loading.value = true;
    final r = await backend.driverAvailable();
    r.fold((f) {
      if (!silent) failure.value = f;
    }, (v) {
      list.assignAll(v.orders);
      reason.value = v.reason;
      failure.value = null;
    });
    loading.value = false;
  }

  @override
  void onClose() {
    _t?.cancel();
    super.onClose();
  }
}

class AvailableScreen extends StatelessWidget {
  const AvailableScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final d = driverCtl();
    final ctl = Get.put(AvailableController());
    return Obx(() {
      final offline = ctl.reason.value == 'offline' || !(d.me.value?.isOnline ?? true);
      return Page2(
        tab: 'av',
        role: _tab,
        top: BigHeadTop(eyebrow: 'قريبة منك', title: 'الطلبات المتاحة', right: _OnlineChip(d)),
        onRefresh: ctl.load,
        body: Padding(padding: const EdgeInsets.only(top: 6), child: ctl.loading.value
            ? Column(children: [for (var i = 0; i < 3; i++) const Padding(padding: EdgeInsets.only(bottom: 16), child: Skel(h: 200, r: 20))])
            : ctl.failure.value != null
                ? EmptyState(ill: 'offline', title: 'تعذّر التحميل', text: failureText(ctl.failure.value!), cta: SBtn('أعد المحاولة', full: true, onTap: ctl.load))
                : ctl.list.isEmpty
                    ? EmptyState(ill: 'route', title: offline ? 'أنت غير متصل' : 'لا طلبات قريبة الآن', text: offline ? 'فعّل الاتصال لتصلك الطلبات القريبة.' : 'نحدّث القائمة تلقائيًا. ابقَ متصلًا وسيصلك إشعار عند وصول طلب.', cta: offline ? SBtn('اتصل الآن', icon: 'power', full: true, onTap: () => d.setOnline(true)) : Row(mainAxisAlignment: MainAxisAlignment.center, children: [const LiveDot(), const SizedBox(width: 10), Text('نبحث عن طلبات…', style: T.sm(c.tx2))]))
                    : Column(children: [for (final o in ctl.list) ...[_AvailCard(o, ctl), const SizedBox(height: 16)]])),
      );
    });
  }
}

class _AvailCard extends StatelessWidget {
  const _AvailCard(this.o, this.ctl);
  final DriverOrderModel o;
  final AvailableController ctl;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Card2(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [STag(o.distanceToPickupKm == null ? '${o.distanceKm.toStringAsFixed(1)} كم' : '${o.distanceToPickupKm!.toStringAsFixed(1)} كم عن المكتبة', kind: 'plum'), Text('${o.code}${o.itemsCount == null ? '' : ' · ${o.itemsCount} منتجات'}', style: T.cap(c.tx2))]),
      const SizedBox(height: 16),
      Row(children: [SIcon('pin', size: 22, color: c.tx), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('استلام', style: T.cap(c.tx2)), Text(o.pickup.line.isEmpty ? (o.vendorName ?? 'المكتبة') : o.pickup.line, style: T.h3(c.tx, size: 15))]))]),
      const SizedBox(height: 12),
      Row(children: [SIcon('nav', size: 22, color: c.tx), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('تسليم · المنطقة فقط', style: T.cap(c.tx2)), Text(o.dropoff.label ?? o.dropoff.line, style: T.h3(c.tx, size: 15))]))]),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('ربحك', style: T.cap(c.tx2)), Mny(o.earning.amount, size: 20)]),
        if (o.isCash) Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('تحصيل نقدي', style: T.cap(c.tx2)), Mny(o.collect.amount, size: 20)]) else const STag('مدفوع', kind: 'gray'),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: SBtn('قبول المهمة', size: BtnSize.sm, full: true, onTap: () => Get.toNamed('/driver/order', arguments: {'order_id': o.id, 'order': o}))),
        const SizedBox(width: 8),
        SBtn('إخفاء', kind: BtnKind.sec, size: BtnSize.sm, onTap: () async {
          await backend.driverReject(o.id);
          ctl.list.removeWhere((x) => x.id == o.id);
        }),
      ]),
    ]));
  }
}

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

class TaskController extends GetxController {
  final order = Rxn<DriverOrderModel>();
  final loading = true.obs;
  final failure = Rxn<Failure>();
  final busy = false.obs;
  Timer? _t;
  String _key = IdempotencyKey.generate();

  @override
  void onInit() {
    super.onInit();
    load();
    _t = Timer.periodic(const Duration(seconds: 10), (_) => load(silent: true));
  }

  Future<void> load({bool silent = false}) async {
    final r = await backend.driverCurrent();
    r.fold((f) {
      if (!silent) failure.value = f;
    }, (v) {
      order.value = v;
      failure.value = null;
    });
    loading.value = false;
  }

  Future<(bool, Failure?)> transition(NextActionModel a, {List<int>? uploads, String? note, Map<String, dynamic>? fields}) async {
    final o = order.value;
    if (o == null || busy.value) return (false, null);
    busy.value = true;
    final r = await backend.driverTransition(o.id, a.to, key: _key, uploadIds: uploads, note: note, fields: fields);
    busy.value = false;
    return r.fold((f) => (false, f), (v) {
      _key = IdempotencyKey.generate();
      order.value = v;
      driverCtl().refreshQuiet();
      return (true, null);
    });
  }

  void stopPolling() => _t?.cancel();

  @override
  void onClose() {
    _t?.cancel();
    super.onClose();
  }
}

class DriverTaskScreen extends StatelessWidget {
  const DriverTaskScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final ctl = Get.put(TaskController());
    final loc = Get.find<DriverLocationService>();
    return Obx(() {
      final o = ctl.order.value;
      if (ctl.loading.value && o == null) return Page2(top: const TopBar(title: ''), body: const Column(children: [Skel(h: 30), SizedBox(height: 16), Skel(h: 190, r: 20), SizedBox(height: 16), Skel(h: 150, r: 20)]));
      if (o == null) {
        return Page2(top: const TopBar(title: 'المهمة'), center: true, body: EmptyState(ill: 'route', title: 'لا مهمة حالية', text: ctl.failure.value == null ? 'اقبل طلبًا من قائمة الطلبات المتاحة.' : failureText(ctl.failure.value!), cta: SBtn('الطلبات المتاحة', full: true, onTap: () => Get.offAllNamed('/driver/available'))));
      }
      final (primary, secondary) = _actionsOf(o);
      final stages = const ['accepted', 'picked_up', 'on_the_way', 'arrived'];
      final idx = stages.indexOf(o.status.key).clamp(0, 3);
      final after = ['picked_up', 'on_the_way', 'arrived'].contains(o.status.key);
      final label = switch (o.status.key) { 'accepted' => 'اذهب إلى المكتبة', 'picked_up' => 'استلمت الطلب', 'on_the_way' => 'في الطريق إلى الزبون', 'arrived' => 'وصلت إلى موقع التسليم', _ => statusLabel(o.status) };
      final pos = loc.lastPosition.value;
      return Page2(
        top: TopBar(title: o.code, right: SIconBtn('phone', onTap: after ? () => callPhone(o.customerPhone) : null)),
        onRefresh: ctl.load,
        body: Padding(padding: const EdgeInsets.only(top: 4), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (loc.offline.value) ...[Note('warn', icon: 'wifiOff', title: 'لا يوجد اتصال.', text: 'نحفظ موقعك على الجهاز (${loc.buffer.length} نقطة) ونرسله فور عودة الشبكة.'), const SizedBox(height: 24)],
          Row(children: [for (var i = 0; i < 4; i++) ...[if (i > 0) const SizedBox(width: 6), Expanded(child: Container(height: 5, decoration: BoxDecoration(color: i < idx ? c.pri : (i == idx ? c.amber : c.sf3), borderRadius: BorderRadius.circular(3))))]]),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: T.h3(c.tx, size: 15.5)), StatusPill(o.status.key, label: statusLabel(o.status))]),
          const SizedBox(height: 24),
          RouteMap(height: 190, radius: Rad.l, pickup: o.pickup.lat == null ? null : LatLng(o.pickup.lat!, o.pickup.lng!), drop: o.dropoff.lat == null ? null : LatLng(o.dropoff.lat!, o.dropoff.lng!), driver: pos == null ? null : LatLng(pos.latitude, pos.longitude), driverHeading: pos != null && pos.heading >= 0 && pos.speed > 0.5 ? pos.heading : null, driverSeenAt: pos?.timestamp),
          const SizedBox(height: 24),
          Card2(child: Column(children: [
            Row(children: [SIcon('pin', size: 22, color: c.tx), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(o.status.key == 'accepted' ? 'اذهب إلى' : 'استلمت من', style: T.cap(c.tx2)), Text(o.pickup.line.isEmpty ? (o.vendorName ?? 'المكتبة') : o.pickup.line, style: T.h3(c.tx, size: 15))])), if (o.status.key == 'accepted' && o.pickup.lat != null) SBtn('خرائط', kind: BtnKind.sec, size: BtnSize.xs, icon: 'nav', onTap: () => _maps(o.pickup.lat!, o.pickup.lng!))]),
            const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider2()),
            Row(children: [SIcon('nav', size: 22, color: c.tx), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('سلّم إلى', style: T.cap(c.tx2)), Text('${o.customerName ?? 'الزبون'}${o.customerPhone == null ? '' : ' · '}', style: T.h3(c.tx, size: 15)), if (o.customerPhone != null) Num(o.customerPhone!, style: T.sm(c.tx)), Text(o.dropoff.line, style: T.sm(c.tx2))])), if (o.dropoff.lat != null) SBtn('خرائط', kind: BtnKind.sec, size: BtnSize.xs, icon: 'nav', onTap: () => _maps(o.dropoff.lat!, o.dropoff.lng!))]),
          ])),
          if (o.isCash) ...[const SizedBox(height: 24), Panel(child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('تحصيل نقدي عند التسليم', style: T.cap(c.tx2)), Mny(o.collect.amount, size: 26)]), SIcon('cash', size: 30, color: c.tx)]))],
          if (o.items.isNotEmpty) ...[const SizedBox(height: 24), Card2(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Text('المحتويات', style: T.h3(c.tx, size: 15)), const SizedBox(height: 8), for (final it in o.items) Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text(it.$1, style: T.sm(c.tx))), Num('× ${it.$2}', style: T.sm(c.tx2))]))]))],
        ])),
        foot: primary == null
            ? null
            : FootBar(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                SBtn(_label(context, primary), full: true, loading: ctl.busy.value, kind: primary.style == 'danger' && primary.action != 'deliver' ? BtnKind.danger : BtnKind.pri, icon: primary.action == 'deliver' ? 'checkC' : 'fwd', onTap: () => _next(context, ctl, o, primary)),
                for (final a in secondary) Padding(padding: const EdgeInsets.only(top: 12), child: Center(child: SLink(_label(context, a), color: a.style == 'danger' || _isFailure(a) ? c.err : null, onTap: ctl.busy.value ? null : () => _next(context, ctl, o, a)))),
              ])),
      );
    });
  }

  Future<void> _maps(double lat, double lng) async => launchUrlSafe('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');

  static (NextActionModel?, List<NextActionModel>) _actionsOf(DriverOrderModel o) {
    final all = <NextActionModel>[];
    for (final a in [if (o.nextAction != null) o.nextAction!, ...o.actions]) {
      if (!all.any((b) => b.action == a.action && b.to == a.to)) all.add(a);
    }
    var deliver = all.where((a) => a.action == 'deliver').firstOrNull;
    if (deliver == null && o.status.key == 'arrived') {
      deliver = const NextActionModel(action: 'deliver', to: 'delivered', label: '');
      all.insert(0, deliver);
    }
    final primary = deliver ?? all.where((a) => a.style != 'danger' && !_isFailure(a)).firstOrNull ?? all.firstOrNull;
    return (primary, [for (final a in all) if (!identical(a, primary)) a]);
  }

  static bool _isFailure(NextActionModel a) => a.to == 'delivery_failed';

  static String _label(BuildContext context, NextActionModel a) {
    if (a.label.isNotEmpty) return a.label;
    if (a.action == 'deliver') return context.l10n.driverDeliverCta;
    if (_isFailure(a)) return context.l10n.driverFailDeliveryCta;
    return 'التالي';
  }

  void _next(BuildContext context, TaskController ctl, DriverOrderModel o, NextActionModel na) {
    if (ctl.busy.value) return;
    if (na.action == 'deliver') {
      Get.toNamed('/driver/deliver');
      return;
    }
    final c = context.sc;
    if (_isFailure(na)) {
      showSheet(context, title: na.confirm ?? _label(context, na), body: Text('تأكد من البيانات قبل المتابعة.', style: T.sm(c.tx2)), foot: [
        SBtn('نعم، ${_label(context, na)}', kind: BtnKind.danger, full: true, hapticOnPress: false, onTap: () {
          Get.back();
          Get.toNamed('/driver/failed');
        }),
        SBtn('لا، رجوع', kind: BtnKind.ghost, full: true, onTap: () => Get.back()),
      ]);
      return;
    }
    final needsPhoto = na.requires.any((r) => r.contains('photo') || r.contains('upload'));
    showSheet(context, title: na.confirm ?? na.label, body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('تأكد من البيانات قبل المتابعة.', style: T.sm(c.tx2)),
      if (na.geofenceMeters != null) ...[const SizedBox(height: 12), Note('plum', icon: 'pin', text: 'يجب أن تكون ضمن ${na.geofenceMeters} م من الموقع لتأكيد هذه الخطوة.')],
      if (needsPhoto) ...[const SizedBox(height: 12), const Note('warn', icon: 'camera', text: 'تتطلب هذه الخطوة صورة. ستُفتح الكاميرا بعد التأكيد.')],
    ]), foot: [
      SBtn('نعم، ${na.label}', full: true, hapticOnPress: false, onTap: () async {
        Get.back();
        List<int>? ups;
        if (needsPhoto) {
          ups = await pickAndUpload('delivery_proof');
          if (ups == null) return;
        }
        final (ok, f) = await ctl.transition(na, uploads: ups);
        if (ok) {
          Haptics.confirm();
        } else if (f != null) {
          Haptics.error();
        }
        if (!ok && f != null && context.mounted) _geofence(context, f, na);
      }),
      SBtn('لا، رجوع', kind: BtnKind.ghost, full: true, onTap: () => Get.back()),
    ]);
  }

  void _geofence(BuildContext context, Failure f, NextActionModel na) {
    final c = context.sc;
    final dist = f.details?['distance_m'] ?? f.details?['distance'];
    showSheet(context, title: 'أنت بعيد عن الموقع', body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Note('err', icon: 'alertC', text: f.message ?? (dist == null ? 'اقترب من الموقع لتأكيد هذه الخطوة.' : 'أنت على بعد $dist م. اقترب إلى ${na.geofenceMeters ?? 100} م أو أقل.')),
    ]), foot: [
      SBtn('حدّث موقعي', icon: 'refresh', full: true, onTap: () async {
        Get.back();
        await Get.find<DriverLocationService>().pushNow();
        showToast('حُدّث موقعك');
      }),
      SBtn('إغلاق', kind: BtnKind.ghost, full: true, onTap: () => Get.back()),
    ]);
  }
}

Future<void> launchUrlSafe(String u) async {
  await callUrl(u);
}

Future<List<int>?> pickAndUpload(String purpose) async {
  final x = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 85, maxWidth: 2000);
  if (x == null) return null;
  final b = await x.readAsBytes();
  final r = await Get.find<UploadRepository>().upload(bytes: b, fileName: x.name, mime: x.name.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg', purpose: purpose);
  return r.fold((f) {
    showToast(failureText(f), icon: 'alertC');
    return null;
  }, (u) => [u.uploadId]);
}
