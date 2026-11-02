import 'dart:async';

import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:project/core/config/remote_config_repository.dart';
import 'package:project/core/design/icons.dart';
import 'package:project/core/design/illustrations.dart';
import 'package:project/core/design/shell.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/design/widgets.dart';
import 'package:project/core/errors/api_error_codes.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/network/idempotency.dart';
import 'package:project/core/storage/session_store.dart';
import 'package:project/core/uploads/upload_repository.dart';
import 'package:project/data/models.dart';
import 'package:project/features/account/account.dart';
import 'package:project/features/common.dart';
import 'package:project/features/orders/orders.dart';

const _tab = TabRole.driver;

// ------------------------------------------------------------------ location

typedef LocPoint = ({double lat, double lng, double? accuracy, double? speed, double? heading, DateTime at});

/// إرسال موقع السائق (≥ config.driver.location_min_interval_seconds) وتخزين النقاط بلا إنترنت ثم إرسالها دفعة (حتى 100).
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

  /// يرسل نقطة فورًا (مطلوب قبل PUT /driver/status).
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
      // لا اتصال: نحتفظ بالنقاط ونعيد إرسالها لاحقًا. 429: نتوقف قليلًا.
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

// ------------------------------------------------------------------- session

class DriverController extends GetxController {
  final me = Rxn<DriverModel>();
  final current = Rxn<DriverOrderModel>();
  final cash = Rxn<CashModel>();
  final today = Rxn<EarningsModel>();
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

  /// الاتصال يحتاج موقعًا حديثًا: نرسله أولًا ثم PUT /driver/status.
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

// --------------------------------------------------------------------- login

class DriverLoginScreen extends StatefulWidget {
  const DriverLoginScreen({super.key});
  @override
  State<DriverLoginScreen> createState() => _DriverLoginScreenState();
}

class _DriverLoginScreenState extends State<DriverLoginScreen> {
  final phone = TextEditingController();
  final pass = TextEditingController();
  bool show = false, busy = false;
  String? err;

  @override
  void dispose() {
    phone.dispose();
    pass.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (phone.text.trim().isEmpty || pass.text.isEmpty) {
      setState(() => err = 'أدخل رقم الجوال وكلمة المرور.');
      return;
    }
    setState(() {
      busy = true;
      err = null;
    });
    final r = await backend.driverLogin(phone.text.replaceAll(RegExp(r'[\s\-()]'), ''), pass.text, deviceName: 'satr-driver');
    if (!mounted) return;
    setState(() => busy = false);
    await r.fold((f) async {
      setState(() => err = f is ValidationFailure || f.code == ApiErrorCodes.validationFailed || f.statusCode == 401 || f.statusCode == 422 ? 'رقم الجوال أو كلمة المرور غير صحيحة.' : failureText(f));
    }, (res) async {
      final s = Get.find<SessionStore>();
      await s.signIn(token: res.$1, userId: res.$2.id);
      await s.setRole('driver');
      Get.find<RemoteConfigRepository>().app = 'driver';
      Get.find<RemoteConfigRepository>().load(refresh: true);
      Get.offAllNamed('/driver/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Page2(
      top: const TopBar(),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Eyebrow('تطبيق السائق'),
        Text('أهلًا بك يا بطل التوصيل', style: T.d2(c.tx)),
        const SizedBox(height: 24),
        if (err != null) ...[Note('err', title: err, text: ''), const SizedBox(height: 16)],
        Fld(label: 'رقم الجوال', controller: phone, keyboard: TextInputType.phone, ltr: true, hint: '0599…'),
        const SizedBox(height: 24),
        Fld(label: 'كلمة المرور', controller: pass, obscure: !show, onSubmitted: (_) => _login(), suffix: GestureDetector(onTap: () => setState(() => show = !show), child: SIcon('eye', size: 20, color: c.tx2))),
        const SizedBox(height: 24),
        const Note('plum', text: 'نسيت كلمة المرور؟ تواصل مع مشغّل سطر ليعيد ضبطها.'),
      ]),
      foot: Foot(child: SBtn('دخول', full: true, loading: busy, onTap: _login)),
    );
  }
}

// ---------------------------------------------------------------------- home

Widget _driverTop(BuildContext context, DriverController d, {required String sub}) {
  final c = context.sc;
  final me = d.me.value;
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Flexible(child: GestureDetector(onTap: () => Get.toNamed('/driver/profile'), child: Row(children: [
          Avatar(me?.initial ?? 'س'),
          const SizedBox(width: 12),
          Flexible(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(sub, style: T.cap(c.tx2)), Text(me?.name ?? '…', maxLines: 1, overflow: TextOverflow.ellipsis, style: T.h3(c.tx))])),
        ]))),
        Row(children: [SIconBtn('bell', onTap: () => Get.toNamed('/driver/notifications')), const SizedBox(width: 4), _OnlineChip(d)]),
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
                return HeroBox(padding: const EdgeInsets.fromLTRB(16, 18, 16, 18), child: Row(children: [
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

// ----------------------------------------------------------------- available

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
        Expanded(child: SBtn('قبول المهمة', size: BtnSize.sm, full: true, onTap: () => Get.toNamed('/driver/order', arguments: {'order_id': o.id}))),
        const SizedBox(width: 8),
        SBtn('إخفاء', kind: BtnKind.sec, size: BtnSize.sm, onTap: () async {
          await backend.driverReject(o.id);
          ctl.list.removeWhere((x) => x.id == o.id);
        }),
      ]),
    ]));
  }
}

// ------------------------------------------------------------------- preview

class DriverPreviewScreen extends StatefulWidget {
  const DriverPreviewScreen({super.key});
  @override
  State<DriverPreviewScreen> createState() => _DriverPreviewScreenState();
}

class _DriverPreviewScreenState extends State<DriverPreviewScreen> {
  final id = (Get.arguments is Map ? Get.arguments['order_id'] : null) as int? ?? 0;
  DriverOrderModel? o;
  Failure? f;
  bool busy = false;
  final key = IdempotencyKey.generate();

  @override
  void initState() {
    super.initState();
    backend.driverOrder(id).then((r) => r.fold((e) => mounted ? setState(() => f = e) : null, (v) => mounted ? setState(() => o = v) : null));
  }

  Future<void> _accept() async {
    setState(() => busy = true);
    final r = await backend.driverAccept(id, key);
    if (!mounted) return;
    setState(() => busy = false);
    r.fold((e) {
      if (e.code == ApiErrorCodes.alreadyTaken) {
        showDlg(context, kind: 'warn', icon: 'alert', title: 'سبقك سائق آخر', text: 'قُبل هذا الطلب قبل لحظات. سنعرض لك طلبات أخرى قريبة.', foot: [SBtn('الطلبات المتاحة', full: true, onTap: () {
          Get.back();
          Get.offAllNamed('/driver/available');
        })]);
      } else if (e.code == ApiErrorCodes.cashLimitReached) {
        showDlg(context, kind: 'err', icon: 'wallet', title: 'وصلت للحد الأقصى للنقد', text: 'سلّم النقد للمشغّل لتتمكن من قبول طلبات جديدة.', foot: [
          SBtn('عرض تفاصيل النقد', full: true, onTap: () {
            Get.back();
            Get.toNamed('/driver/cash');
          }),
          SBtn('إغلاق', kind: BtnKind.ghost, full: true, onTap: () => Get.back()),
        ]);
      } else {
        showDlg(context, kind: 'warn', icon: 'alert', title: 'تعذّر قبول الطلب', text: e.code == ApiErrorCodes.validationFailed || e.code == ApiErrorCodes.invalidTransition ? (e.message ?? 'لا يمكنك قبول هذا الطلب الآن (قد تكون مشغولًا بمهمة أو غير متصل).') : failureText(e), foot: [SBtn('حسنًا', full: true, onTap: () => Get.back())]);
      }
    }, (_) async {
      await driverCtl().refreshAll();
      Get.offNamed('/driver/task');
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final x = o;
    if (x == null) return Page2(top: const TopBar(title: ''), center: true, body: f == null ? const Skel(h: 260, r: 20) : EmptyState(ill: 'offline', title: 'تعذّر تحميل الطلب', text: failureText(f!), cta: SBtn('أعد المحاولة', full: true, onTap: () => Get.back())));
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
        SBtn('اقبل المهمة', full: true, loading: busy, onTap: _accept),
        const SizedBox(height: 8),
        SBtn('إخفاء الطلب', kind: BtnKind.ghost, full: true, onTap: () async {
          await backend.driverReject(id);
          Get.back();
        }),
      ])),
    );
  }
}

// ---------------------------------------------------------------------- task

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

  /// يرجع (نجاح، رسالة خطأ، هل هو خارج النطاق).
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
      final na = o.nextAction;
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
          RouteMap(height: 190, radius: Rad.l, pickup: o.pickup.lat == null ? null : LatLng(o.pickup.lat!, o.pickup.lng!), drop: o.dropoff.lat == null ? null : LatLng(o.dropoff.lat!, o.dropoff.lng!), driver: pos == null ? null : LatLng(pos.latitude, pos.longitude)),
          const SizedBox(height: 24),
          Card2(child: Column(children: [
            Row(children: [SIcon('pin', size: 22, color: c.tx), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(o.status.key == 'accepted' ? 'اذهب إلى' : 'استلمت من', style: T.cap(c.tx2)), Text(o.pickup.line.isEmpty ? (o.vendorName ?? 'المكتبة') : o.pickup.line, style: T.h3(c.tx, size: 15))])), if (o.status.key == 'accepted' && o.pickup.lat != null) SBtn('خرائط', kind: BtnKind.sec, size: BtnSize.xs, icon: 'nav', onTap: () => _maps(o.pickup.lat!, o.pickup.lng!))]),
            const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider2()),
            Row(children: [SIcon('nav', size: 22, color: c.tx), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('سلّم إلى', style: T.cap(c.tx2)), Text('${o.customerName ?? 'الزبون'}${o.customerPhone == null ? '' : ' · '}', style: T.h3(c.tx, size: 15)), if (o.customerPhone != null) Num(o.customerPhone!, style: T.sm(c.tx)), Text(o.dropoff.line, style: T.sm(c.tx2))])), if (o.dropoff.lat != null) SBtn('خرائط', kind: BtnKind.sec, size: BtnSize.xs, icon: 'nav', onTap: () => _maps(o.dropoff.lat!, o.dropoff.lng!))]),
          ])),
          if (o.isCash) ...[const SizedBox(height: 24), Panel(child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('تحصيل نقدي عند التسليم', style: T.cap(c.tx2)), Mny(o.collect.amount, size: 26)]), SIcon('cash', size: 30, color: c.tx)]))],
          if (o.items.isNotEmpty) ...[const SizedBox(height: 24), Card2(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Text('المحتويات', style: T.h3(c.tx, size: 15)), const SizedBox(height: 8), for (final it in o.items) Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text(it.$1, style: T.sm(c.tx))), Num('× ${it.$2}', style: T.sm(c.tx2))]))]))],
        ])),
        foot: na == null ? null : FootBar(child: SBtn(na.label.isEmpty ? 'التالي' : na.label, full: true, loading: ctl.busy.value, kind: na.style == 'danger' ? BtnKind.danger : BtnKind.pri, icon: na.action == 'deliver' ? 'checkC' : 'fwd', onTap: () => _next(context, ctl, o, na))),
      );
    });
  }

  Future<void> _maps(double lat, double lng) async => launchUrlSafe('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');

  void _next(BuildContext context, TaskController ctl, DriverOrderModel o, NextActionModel na) {
    if (na.action == 'deliver') {
      Get.toNamed('/driver/deliver');
      return;
    }
    final c = context.sc;
    final needsPhoto = na.requires.any((r) => r.contains('photo') || r.contains('upload'));
    showSheet(context, title: na.confirm ?? na.label, body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('تأكد من البيانات قبل المتابعة.', style: T.sm(c.tx2)),
      if (na.geofenceMeters != null) ...[const SizedBox(height: 12), Note('plum', icon: 'pin', text: 'يجب أن تكون ضمن ${na.geofenceMeters} م من الموقع لتأكيد هذه الخطوة.')],
      if (needsPhoto) ...[const SizedBox(height: 12), const Note('warn', icon: 'camera', text: 'تتطلب هذه الخطوة صورة. ستُفتح الكاميرا بعد التأكيد.')],
    ]), foot: [
      SBtn('نعم، ${na.label}', full: true, onTap: () async {
        Get.back();
        List<int>? ups;
        if (needsPhoto) {
          ups = await pickAndUpload('delivery_proof');
          if (ups == null) return;
        }
        final (ok, f) = await ctl.transition(na, uploads: ups);
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
    // ignore: unused_local_variable
    final _ = c;
  }
}

Future<void> launchUrlSafe(String u) async {
  // نستخدم url_launcher عبر orders.dart (callPhone) لتجنب تكرار الاستيراد.
  await callUrl(u);
}

/// صورة بالكاميرا ثم رفعها (delivery_proof). يعيد upload_ids أو null.
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

// ------------------------------------------------------------------- deliver

class DriverDeliverScreen extends StatefulWidget {
  const DriverDeliverScreen({super.key});
  @override
  State<DriverDeliverScreen> createState() => _DriverDeliverScreenState();
}

class _DriverDeliverScreenState extends State<DriverDeliverScreen> {
  String otp = '';
  bool wrong = false, busy = false;
  String? err;
  final key = IdempotencyKey.generate();
  DriverOrderModel? o;

  @override
  void initState() {
    super.initState();
    o = Get.isRegistered<TaskController>() ? Get.find<TaskController>().order.value : null;
  }

  bool get photo => Get.find<RemoteConfigRepository>().current?.deliveryConfirmation == 'photo';

  Future<void> _submit({List<int>? ups}) async {
    final order = o;
    if (order == null) return;
    setState(() {
      busy = true;
      wrong = false;
      err = null;
    });
    final r = await backend.driverDeliver(order.id, otp: ups == null ? otp : null, uploadIds: ups, key: key);
    if (!mounted) return;
    setState(() => busy = false);
    r.fold((f) {
      setState(() {
        wrong = true;
        err = f.code == ApiErrorCodes.validationFailed || f.statusCode == 422 ? null : failureText(f);
      });
    }, (v) async {
      await driverCtl().refreshAll();
      Get.offNamed('/driver/delivered', arguments: {'earning': v.earning.amount, 'code': v.code});
    });
  }

  void _key(String k) {
    if (busy) return;
    setState(() {
      wrong = false;
      if (k == '⌫') {
        if (otp.isNotEmpty) otp = otp.substring(0, otp.length - 1);
      } else if (otp.length < 4) {
        otp += k;
      }
    });
    if (otp.length == 4 && k != '⌫') _submit();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final x = o;
    return Page2(
      top: const TopBar(title: 'تسليم الطلب'),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(photo ? 'صوّر لإثبات التسليم' : 'أدخل رمز التسليم', style: T.h1(c.tx)),
        const SizedBox(height: 8),
        Text(photo ? 'التقط صورة للطلب عند باب الزبون.' : 'اطلب الرمز المكوّن من 4 أرقام من الزبون. يظهر في تطبيقه.', style: T.sm(c.tx2)),
        const SizedBox(height: 24),
        if (photo) DropZone(icon: 'camera', title: 'التقط صورة', onTap: busy ? null : () async {
          final ups = await pickAndUpload('delivery_proof');
          if (ups != null) _submit(ups: ups);
        }) else ...[
          OtpBoxes(digits: otp, bad: wrong),
          if (wrong) ...[const SizedBox(height: 16), Note('err', title: err ?? 'الرمز غير صحيح.', text: err == null ? 'اطلب الرمز من الزبون وأعد المحاولة.' : '')],
        ],
        if (photo && wrong && err != null) ...[const SizedBox(height: 16), Note('err', text: err)],
        const SizedBox(height: 24),
        if (x != null) Panel(child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('حصّل من الزبون', style: T.cap(c.tx2)), Mny(x.collect.amount, size: 26)]), SIcon('cash', size: 30, color: c.tx)])),
        const SizedBox(height: 16),
        Center(child: SLink('تعذّر التسليم؟', onTap: () => Get.toNamed('/driver/failed'))),
      ]),
      foot: photo ? null : Keypad(onKey: _key, disabled: busy),
    );
  }
}

const _failReasons = [
  ('customer_unreachable', 'الزبون لا يرد على الهاتف'),
  ('incorrect_address', 'العنوان غير صحيح'),
  ('reschedule_requested', 'الزبون طلب إعادة الجدولة'),
  ('access_unavailable', 'تعذّر الوصول إلى المكان'),
  ('other', 'سبب آخر'),
];

class DriverFailedScreen extends StatefulWidget {
  const DriverFailedScreen({super.key});
  @override
  State<DriverFailedScreen> createState() => _DriverFailedScreenState();
}

class _DriverFailedScreenState extends State<DriverFailedScreen> {
  String reason = 'customer_unreachable';
  final note = TextEditingController();
  List<int>? photo;
  bool busy = false;
  String? err;
  final key = IdempotencyKey.generate();

  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final o = Get.isRegistered<TaskController>() ? Get.find<TaskController>().order.value : null;
    if (o == null) return;
    setState(() {
      busy = true;
      err = null;
    });
    final r = await backend.driverTransition(o.id, 'delivery_failed', key: key, fields: {'delivery_failure_reason': reason}, note: note.text, uploadIds: photo);
    if (!mounted) return;
    setState(() => busy = false);
    r.fold((f) => setState(() => err = failureText(f)), (_) async {
      await driverCtl().refreshAll();
      Get.offNamed('/driver/failure-recorded');
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Page2(
      top: const TopBar(title: 'تعذّر التسليم'),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('ما سبب تعذّر التسليم؟', style: T.h1(c.tx)),
        const SizedBox(height: 16),
        for (final r in _failReasons) ...[OptCard(on: reason == r.$1, title: r.$2, onTap: () => setState(() => reason = r.$1)), const SizedBox(height: 8)],
        const SizedBox(height: 8),
        Fld(label: 'ملاحظة', hint: 'تفاصيل إضافية…', controller: note, optional: true, maxLines: 3),
        const SizedBox(height: 16),
        DropZone(compact: true, icon: photo == null ? 'camera' : 'checkC', title: photo == null ? 'أضف صورة (اختياري)' : 'أُرفقت الصورة', onTap: () async {
          final p = await pickAndUpload('delivery_proof');
          if (p != null) setState(() => photo = p);
        }),
        if (err != null) ...[const SizedBox(height: 16), Note('err', text: err)],
      ]),
      foot: FootBar(child: SBtn('سجّل تعذّر التسليم', kind: BtnKind.danger, full: true, loading: busy, onTap: _send)),
    );
  }
}

class DriverFailureRecordedScreen extends StatelessWidget {
  const DriverFailureRecordedScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Page2(center: true, body: Column(mainAxisSize: MainAxisSize.min, children: [const Ill('wait', width: 190), const SizedBox(height: 24), Text('سُجّل تعذّر التسليم', style: T.d2(c.tx)), const SizedBox(height: 8), Text('شكرًا. ستتابع الإدارة الطلب.', textAlign: TextAlign.center, style: T.bd(c.tx2))]), foot: Foot(child: SBtn('الرئيسية', full: true, onTap: () => Get.offAllNamed('/driver/home'))));
  }
}

class DriverDeliveredScreen extends StatelessWidget {
  const DriverDeliveredScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final d = driverCtl();
    final earning = (Get.arguments is Map ? Get.arguments['earning'] : null) as int? ?? 0;
    return Page2(
      center: true,
      body: Obx(() => Column(mainAxisSize: MainAxisSize.min, children: [
            const Ill('done', width: 190),
            const SizedBox(height: 24),
            Text('تم التسليم', style: T.d2(c.tx)),
            const SizedBox(height: 8),
            Text('أحسنت. أُضيف ربحك إلى سجلك.', style: T.bd(c.tx2)),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('ربح المهمة', style: T.cap(c.tx2)), Mny(earning, size: 24)]))),
              const SizedBox(width: 12),
              Expanded(child: Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('نقد معك الآن', style: T.cap(c.tx2)), Mny(d.cash.value?.onHand.amount ?? 0, size: 24)]))),
            ]),
          ])),
      foot: Foot(child: Column(mainAxisSize: MainAxisSize.min, children: [SBtn('الطلبات المتاحة', full: true, onTap: () => Get.offAllNamed('/driver/available')), const SizedBox(height: 8), SBtn('الرئيسية', kind: BtnKind.ghost, full: true, onTap: () => Get.offAllNamed('/driver/home'))])),
    );
  }
}

// ------------------------------------------------------- history / earnings

class DriverHistoryScreen extends StatefulWidget {
  const DriverHistoryScreen({super.key});
  @override
  State<DriverHistoryScreen> createState() => _DriverHistoryScreenState();
}

class _DriverHistoryScreenState extends State<DriverHistoryScreen> {
  List<DriverOrderModel>? list;
  Failure? f;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await backend.driverHistory();
    if (!mounted) return;
    r.fold((e) => setState(() => f = e), (v) => setState(() => list = v));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Page2(
      tab: 'hist',
      role: _tab,
      top: const BigHeadTop(eyebrow: 'أعمالك السابقة', title: 'السجل'),
      onRefresh: _load,
      body: Padding(padding: const EdgeInsets.only(top: 6), child: list == null
          ? (f == null ? Column(children: [for (var i = 0; i < 3; i++) const Padding(padding: EdgeInsets.only(bottom: 8), child: Skel(h: 100, r: 20))]) : EmptyState(ill: 'offline', title: 'تعذّر التحميل', text: failureText(f!), cta: SBtn('أعد المحاولة', full: true, onTap: _load)))
          : list!.isEmpty
              ? const EmptyState(ill: 'books', title: 'لا مهام سابقة', text: 'ستظهر هنا المهام التي أنجزتها.')
              : Column(children: [
                  for (final o in list!) ...[
                    Card2(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(o.code, style: T.cap(c.tx2)), StatusPill(o.status.key, label: statusLabel(o.status))]),
                      const SizedBox(height: 8),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('${o.dropoff.label ?? o.dropoff.line} · ${o.distanceKm.toStringAsFixed(1)} كم', style: T.h3(c.tx, size: 15)), Mny(o.earning.amount)]),
                      const SizedBox(height: 8),
                      Text(timeLabel(o.createdAt), style: T.sm(c.tx2)),
                    ])),
                    const SizedBox(height: 8),
                  ],
                ])),
    );
  }
}

class DriverEarningsScreen extends StatefulWidget {
  const DriverEarningsScreen({super.key});
  @override
  State<DriverEarningsScreen> createState() => _DriverEarningsScreenState();
}

class _DriverEarningsScreenState extends State<DriverEarningsScreen> {
  String period = 'week';
  EarningsModel? e;
  Failure? f;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await backend.driverEarnings(period);
    if (!mounted) return;
    r.fold((x) => setState(() => f = x), (v) => setState(() {
          e = v;
          f = null;
        }));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final x = e;
    final maxV = x == null || x.series.isEmpty ? 1 : x.series.map((s) => s.$3.amount).fold<int>(1, (a, b) => b > a ? b : a);
    const days = ['ن', 'ث', 'ر', 'خ', 'ج', 'س', 'ح'];
    return Page2(
      tab: 'earn',
      role: _tab,
      top: const BigHeadTop(eyebrow: 'أرباحك', title: 'الأرباح'),
      onRefresh: _load,
      body: Padding(padding: const EdgeInsets.only(top: 6), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Seg(items: const [('day', 'اليوم'), ('week', 'الأسبوع'), ('month', 'الشهر')], value: period, onChanged: (p) {
          setState(() {
            period = p;
            e = null;
          });
          _load();
        }),
        const SizedBox(height: 24),
        if (x == null)
          f == null ? const Skel(h: 160, r: 28) : EmptyState(ill: 'offline', title: 'تعذّر التحميل', text: failureText(f!), cta: SBtn('أعد المحاولة', full: true, onTap: _load))
        else ...[
          HeroBox(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(switch (period) { 'day' => 'أرباح اليوم', 'month' => 'أرباح الشهر', _ => 'أرباح الأسبوع' }, style: T.cap(c.onHero.withValues(alpha: .75))),
            Mny(x.earnings.amount, size: 42, color: c.onHero),
            Row(children: [Text('${x.orders} مهمة · تحصيل نقدي ', style: T.sm(c.onHero.withValues(alpha: .8))), Mny(x.cashCollected.amount, size: 14, color: c.onHero)]),
          ])),
          if (x.series.isNotEmpty) ...[
            const SizedBox(height: 24),
            Card2(child: SizedBox(height: 120, child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              for (var i = 0; i < x.series.length && i < 31; i++)
                Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Flexible(child: FractionallySizedBox(heightFactor: (x.series[i].$3.amount / maxV).clamp(.04, 1.0), child: Container(decoration: BoxDecoration(color: x.series[i].$3.amount == maxV ? c.pri : c.sf3, borderRadius: const BorderRadius.vertical(top: Radius.circular(8), bottom: Radius.circular(4)))))),
                  const SizedBox(height: 6),
                  Text(x.series[i].$1 == null ? '' : (x.series.length <= 7 ? days[x.series[i].$1!.weekday - 1] : '${x.series[i].$1!.day}'), style: T.cap(c.tx2).copyWith(fontSize: 11.5)),
                ]))),
            ]))),
          ],
        ],
        const SizedBox(height: 24),
        SBtn('النقد والتسويات', kind: BtnKind.sec, icon: 'wallet', full: true, onTap: () => Get.toNamed('/driver/cash')),
      ])),
    );
  }
}

class DriverCashScreen extends StatefulWidget {
  const DriverCashScreen({super.key});
  @override
  State<DriverCashScreen> createState() => _DriverCashScreenState();
}

class _DriverCashScreenState extends State<DriverCashScreen> {
  CashModel? cash;
  Failure? f;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await backend.driverCash();
    if (!mounted) return;
    r.fold((x) => setState(() => f = x), (v) => setState(() => cash = v));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final x = cash;
    return Page2(
      top: const TopBar(title: 'النقد'),
      onRefresh: _load,
      body: x == null
          ? (f == null ? const Skel(h: 160, r: 20) : EmptyState(ill: 'offline', title: 'تعذّر التحميل', text: failureText(f!), cta: SBtn('أعد المحاولة', full: true, onTap: _load)))
          : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Card2(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                _cashMeter(context, x),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('المتبقي حتى الحد', style: T.sm(c.tx2)), Mny(x.remaining?.amount ?? (x.max.amount - x.onHand.amount))]),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('طلبات غير مسوّاة', style: T.sm(c.tx2)), Text('${x.unsettled}', style: const TextStyle(fontFamily: Fonts.ui, fontWeight: FontWeight.w700))]),
              ])),
              const SizedBox(height: 24),
              const Note('plum', text: 'تُسلَّم الأموال للمشغّل ويسجّل التسوية. عند الوصول للحد الأقصى لا تصلك طلبات جديدة.'),
              const SizedBox(height: 24),
              const SecHead('آخر التسويات'),
              const SizedBox(height: 8),
              if (x.settlements.isEmpty) Text('لا تسويات بعد.', style: T.sm(c.tx2)) else Card2(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: Column(children: [for (final s in x.settlements) Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(timeLabel(s.$1), style: T.sm(c.tx2)), Mny(s.$2.amount)]))])),
            ]),
    );
  }
}

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});
  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final d = driverCtl();
    return Obx(() {
      final me = d.me.value;
      final lang = (Get.locale?.languageCode ?? 'ar') == 'en' ? 'English' : 'العربية';
      return Page2(
        tab: 'home',
        role: _tab,
        top: const TopBar(title: 'ملفي'),
        body: me == null
            ? const Skel(h: 120, r: 20)
            : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Card2(child: Row(children: [
                  Avatar(me.initial, large: true),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(me.name, style: T.h2(c.tx)), Row(children: [SIcon('star', size: 16, color: c.amber, filled: true), const SizedBox(width: 6), Text('${me.rating.toStringAsFixed(1)} · ${me.ratingCount} تقييمًا', style: T.sm(c.tx))])])),
                ])),
                const SizedBox(height: 24),
                Text('المركبة', style: TextStyle(fontFamily: Fonts.ui, fontSize: 14, fontWeight: FontWeight.w600, color: c.tx)),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final v in kVehicleLabels.entries)
                    SChip(v.value, on: me.vehicleType == v.key, onTap: () async {
                      final r = await backend.updateDriver(vehicleType: v.key);
                      r.fold((f) => showToast(failureText(f), icon: 'alertC'), (m) => d.me.value = m);
                    }),
                ]),
                const SizedBox(height: 24),
                Card2(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: Column(children: [
                  LiTile('globe', 'اللغة', sub: lang, onTap: () => langSheet(context)),
                  LiTile('bell', 'الإشعارات', sub: 'إدارة من إعدادات الجهاز', first: false, onTap: ph.openAppSettings),
                ])),
                const SizedBox(height: 24),
                Card2(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: LiTile('logout', 'تسجيل الخروج', sub: 'يصبح غير متصل', onTap: () => showDlg(context, icon: 'logout', title: 'تسجيل الخروج؟', text: 'سيصبح حسابك غير متصل ولن تصلك طلبات.', foot: [
                      SBtn('تسجيل الخروج', full: true, onTap: () async {
                        Get.back();
                        d.loc.stop();
                        await backend.driverStatus(false);
                        await doSignOut();
                        Get.delete<DriverController>(force: true);
                      }),
                      SBtn('إلغاء', kind: BtnKind.ghost, full: true, onTap: () => Get.back()),
                    ]))),
              ]),
      );
    });
  }
}
