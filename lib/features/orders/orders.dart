import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:project/core/config/remote_config_repository.dart';
import 'package:project/core/design/icons.dart';
import 'package:project/core/design/illustrations.dart';
import 'package:project/core/design/shell.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/design/widgets.dart';
import 'package:project/core/errors/api_error_codes.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/routes/route_args.dart';
import 'package:project/data/models.dart';
import 'package:project/features/catalog/catalog.dart';
import 'package:project/features/common.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> callPhone(String? phone) async {
  if (phone == null || phone.isEmpty) return;
  await launchUrl(Uri.parse('tel:$phone'));
}

Future<void> callUrl(String u) async => launchUrl(Uri.parse(u), mode: LaunchMode.externalApplication);

Future<void> supportCall() async => callPhone(Get.find<RemoteConfigRepository>().current?.supportPhone);

// -------------------------------------------------------------- orders list

class OrdersController extends GetxController {
  final tab = 'active'.obs;
  final list = <OrderSummaryModel>[].obs;
  final loading = true.obs;
  final failure = Rxn<Failure>();
  Timer? _poll;

  @override
  void onInit() {
    super.onInit();
    load();
    _poll = Timer.periodic(const Duration(seconds: 15), (_) {
      if (tab.value == 'active') load(silent: true);
    });
  }

  Future<void> load({bool silent = false}) async {
    if (!silent) loading.value = true;
    failure.value = null;
    final r = await backend.orders(scope: tab.value);
    r.fold((f) {
      if (!silent) failure.value = f;
    }, (v) {
      final l = [...v];
      if (tab.value == 'active') l.sort((a, b) => (b.status.key == 'priced' ? 1 : 0).compareTo(a.status.key == 'priced' ? 1 : 0));
      list.assignAll(l);
    });
    loading.value = false;
  }

  void setTab(String t) {
    tab.value = t;
    list.clear();
    load();
  }

  @override
  void onClose() {
    _poll?.cancel();
    super.onClose();
  }
}

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final ctl = Get.put(OrdersController());
    return Obx(() {
      if (ctl.loading.value && ctl.list.isEmpty) {
        return Page2(tab: 'orders', top: const BigHeadTop(eyebrow: 'تابع كل شيء', title: 'طلباتي'), body: Padding(padding: const EdgeInsets.only(top: 12), child: Column(children: [for (var i = 0; i < 3; i++) const Padding(padding: EdgeInsets.only(bottom: 16), child: Card2(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Skel(w: 120, h: 12), SizedBox(height: 8), Skel(h: 18), SizedBox(height: 8), Skel(w: 160, h: 14)])))])));
      }
      return Page2(
        tab: 'orders',
        top: const BigHeadTop(eyebrow: 'تابع كل شيء', title: 'طلباتي', right: CartBadgeButton()),
        onRefresh: ctl.load,
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const SizedBox(height: 6),
          Seg(items: const [('active', 'نشطة'), ('completed', 'مكتملة'), ('cancelled', 'ملغاة')], value: ctl.tab.value, onChanged: ctl.setTab),
          const SizedBox(height: 16),
          if (ctl.failure.value != null)
            EmptyState(ill: 'offline', title: 'تعذّر التحميل', text: failureText(ctl.failure.value!), cta: SBtn('أعد المحاولة', full: true, onTap: ctl.load))
          else if (ctl.list.isEmpty)
            EmptyState(ill: 'bag', title: ctl.tab.value == 'active' ? 'لا طلبات نشطة' : 'لا يوجد شيء هنا', text: 'ابدأ بطلب جديد وسيظهر هنا مع حالته خطوة بخطوة.', cta: SBtn('تصفّح المنتجات', full: true, onTap: () => Get.toNamed('/products', arguments: {'title': 'المنتجات'})))
          else
            for (final o in ctl.list) ...[_OrderCard(o), const SizedBox(height: 16)],
        ]),
      );
    });
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard(this.o);
  final OrderSummaryModel o;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final hot = o.status.key == 'priced';
    return Card2(
      onTap: () => Get.toNamed(hot ? '/offer' : '/order', arguments: {'order_id': o.id}),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (hot) ...[const Note('warn', icon: 'alert', compact: true, child: Text.rich(TextSpan(children: [TextSpan(text: 'يحتاج موافقتك', style: TextStyle(fontWeight: FontWeight.w700)), TextSpan(text: ' · عرض السعر جاهز')]))), const SizedBox(height: 8)],
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(o.code, style: T.cap(c.tx2)), StatusPill(o.status.key, label: statusLabel(o.status))]),
        const SizedBox(height: 8),
        Text(o.itemsCount == null ? 'طلب' : '${o.itemsCount} ${o.itemsCount == 1 ? 'عنصر' : 'عناصر'}', style: T.h3(c.tx, size: 16)),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(timeLabel(o.createdAt), style: T.sm(c.tx2)), Mny(o.total.amount)]),
      ]),
    );
  }
}

// -------------------------------------------------------------- order detail

class OrderDetailController extends GetxController {
  final int orderId = RouteArgs.readOrderId() ?? 0;
  final order = Rxn<OrderModel>();
  final loading = true.obs;
  final failure = Rxn<Failure>();
  int _since = 0;
  Timer? _timer;
  bool _busy = false;
  bool _primed = false;
  int _interval = 10;
  AppLifecycleListener? _life;

  @override
  void onInit() {
    super.onInit();
    final p = Get.find<RemoteConfigRepository>().current?.polling;
    final v = p?['order_seconds'] ?? p?['orders'] ?? p?['order'];
    if (v is int) _interval = v.clamp(5, 60);
    load();
    _schedule();
    _life = AppLifecycleListener(onResume: refreshLight);
  }

  void _schedule() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: _interval), (_) => refreshLight());
  }

  Future<void> load() async {
    if (order.value == null) loading.value = true;
    failure.value = null;
    final r = await backend.order(orderId);
    r.fold((f) => failure.value = f, (o) => order.value = o);
    loading.value = false;
  }

  /// تحديث خفيف: /events بدل إعادة تحميل الطلب كاملًا إلا إن وُجدت أحداث جديدة.
  Future<void> refreshLight() async {
    if (_busy || orderId == 0 || (order.value?.status.isTerminal ?? false)) return;
    _busy = true;
    final r = await backend.events(orderId, _since);
    await r.fold((f) async {
      if (f.code == ApiErrorCodes.tooManyRequests) {
        _timer?.cancel();
        final s = f is ServerFailure ? (f.retryAfterSeconds ?? 30) : 30;
        Future.delayed(Duration(seconds: s), _schedule);
      }
    }, (res) async {
      final reload = _primed && res.$1 > 0;
      _primed = true;
      _since = res.$2;
      if (reload) {
        final o = await backend.order(orderId);
        o.fold((_) {}, (v) => order.value = v);
      }
    });
    _busy = false;
  }

  @override
  void onClose() {
    _timer?.cancel();
    _life?.dispose();
    super.onClose();
  }
}

const _nextLbl = {
  'awaiting_pricing': 'عرض السعر',
  'priced': 'موافقتك',
  'pending': 'قبول المكتبة',
  'awaiting_payment': 'الدفع',
  'payment_review': 'اعتماد الدفع',
  'preparing': 'التجهيز',
  'ready_for_delivery': 'سائق التوصيل',
  'accepted': 'استلام الطلب',
  'picked_up': 'الطريق إليك',
  'on_the_way': 'الوصول',
  'arrived': 'التسليم',
};

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final ctl = Get.put(OrderDetailController());
    return Obx(() {
      final o = ctl.order.value;
      if (ctl.loading.value && o == null) return Page2(top: const TopBar(title: ''), body: const Column(children: [Skel(h: 28), SizedBox(height: 16), Skel(h: 150, r: 20), SizedBox(height: 16), Skel(h: 200, r: 20)]));
      if (o == null) return Page2(top: const TopBar(title: ''), center: true, body: EmptyState(ill: 'offline', title: 'تعذّر تحميل الطلب', text: failureText(ctl.failure.value ?? const UnknownFailure()), cta: SBtn('أعد المحاولة', full: true, onTap: ctl.load)));
      final k = o.statusKey;
      final terminal = o.status.isTerminal || ['delivered', 'cancelled', 'delivery_failed'].contains(k);
      final tl = <TimelineItem>[];
      for (var i = 0; i < o.timeline.length; i++) {
        final e = o.timeline[i];
        final last = i == o.timeline.length - 1;
        final isEnd = ['delivered', 'cancelled', 'delivery_failed'].contains(e.status.key);
        tl.add(TimelineItem(kStatusTone[e.status.key]?.$2 ?? statusLabel(e.status), e.at == null ? null : timeLabel(e.at), done: !last || isEnd || terminal, cur: last && !isEnd && !terminal, check: !(last && !isEnd && !terminal)));
      }
      if (!terminal && _nextLbl[k] != null) tl.add(TimelineItem('التالي: ${_nextLbl[k]}', null, next: true));
      final foot = k == 'priced'
          ? FootBar(child: SBtn('راجع العرض', full: true, onTap: () => Get.toNamed('/offer', arguments: {'order_id': o.id})))
          : (k == 'awaiting_payment' && o.isTransfer)
              ? FootBar(child: SBtn('ارفع إشعار التحويل', full: true, onTap: () => Get.toNamed('/pay', arguments: {'order_id': o.id})))
              : null;
      return Page2(
        top: TopBar(title: o.code, right: SIconBtn('more', onTap: () => _more(context, o))),
        onRefresh: ctl.load,
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [StatusPill(k, label: statusLabel(o.status)), Text(timeLabel(o.createdAt), style: T.sm(c.tx2))]),
          const SizedBox(height: 24),
          _context(context, o),
          if (o.can('cancel') || (['picked_up', 'on_the_way', 'arrived', 'accepted'].contains(k) && o.can('track'))) ...[
            const SizedBox(height: 24),
            Row(children: [
              if (o.can('cancel')) SBtn('إلغاء الطلب', kind: BtnKind.ghost, size: BtnSize.sm, icon: 'x', onTap: () => cancelSheet(context, o)),
              if (['picked_up', 'on_the_way', 'arrived'].contains(k)) SBtn('شارك رابط التتبع', kind: BtnKind.sec, size: BtnSize.sm, icon: 'share', onTap: () => shareSheet(context, o)),
            ]),
          ],
          const SizedBox(height: 24),
          const SecHead('الحالة'),
          const SizedBox(height: 8),
          Card2(child: SatrTimeline(tl)),
          const SizedBox(height: 24),
          const SecHead('محتويات الطلب'),
          const SizedBox(height: 8),
          Card2(child: Column(children: [
            for (var i = 0; i < o.items.length; i++) ...[
              if (i > 0) const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider2()),
              _itemRow(context, o.items[i]),
            ],
            if ((o.shoppingRequest ?? '').isNotEmpty) ...[
              if (o.items.isNotEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider2()),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SIcon('edit', size: 22, color: c.plumInk), const SizedBox(width: 12), Expanded(child: Text(o.shoppingRequest!, style: T.sm(c.tx)))]),
            ],
            if (o.items.isEmpty && (o.shoppingRequest ?? '').isEmpty) Text('لا عناصر.', style: T.sm(c.tx2)),
          ])),
          const SizedBox(height: 24),
          const SecHead('السعر'),
          const SizedBox(height: 8),
          Panel(child: Column(children: [
            if (o.priceLines.isNotEmpty)
              for (final l in o.priceLines) KV(l.label, null, vWidget: l.amount.amount < 0 ? Text('- ${fmtMinor(-l.amount.amount)}', textDirection: TextDirection.ltr, style: TextStyle(fontFamily: Fonts.ui, fontWeight: FontWeight.w600, color: c.okInk)) : Mny(l.amount.amount))
            else ...[KV('المنتجات', null, vWidget: Mny(o.itemsTotal.amount)), KV('التوصيل', null, vWidget: Mny(o.deliveryFee.amount))],
            KV('الإجمالي', null, total: true, vWidget: Mny(o.total.amount, size: 18)),
          ])),
          const SizedBox(height: 24),
          const SecHead('التوصيل والدفع'),
          const SizedBox(height: 8),
          Card2(child: Column(children: [
            Row(children: [
              Container(width: 44, height: 44, decoration: BoxDecoration(color: c.hero, borderRadius: BorderRadius.circular(14)), child: Center(child: SIcon('pin', size: 22, color: c.onHero))),
              const SizedBox(width: 14),
              Expanded(child: Text(o.dropoff.line.isEmpty ? 'عنوان التوصيل' : o.dropoff.line, style: T.sm(c.tx2))),
            ]),
            const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider2()),
            Row(children: [
              SIcon(o.isCash ? 'cash' : 'bank', size: 22, color: c.tx),
              const SizedBox(width: 12),
              Expanded(child: Text(o.isCash ? 'الدفع نقدًا عند التسليم' : 'تحويل بنكي', style: T.h3(c.tx, size: 15))),
              if (k == 'payment_review') const StatusPill('', label: 'قيد المراجعة', tone: 'wait') else if (o.paymentStatus == 'paid') const StatusPill('', label: 'مدفوع', tone: 'ok'),
            ]),
          ])),
        ]),
        foot: foot,
      );
    });
  }

  Widget _itemRow(BuildContext context, OrderItemModel it) {
    final c = context.sc;
    if (it.print != null) {
      final p = it.print!;
      return Row(children: [
        Container(width: 64, height: 64, decoration: BoxDecoration(color: c.hero, borderRadius: BorderRadius.circular(14)), child: Center(child: SIcon('printer', size: 28, color: c.onHero))),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('طباعة · ${p.fileName ?? it.name}', textDirection: TextDirection.ltr, textAlign: TextAlign.start, maxLines: 1, overflow: TextOverflow.ellipsis, style: T.h3(c.tx, size: 15)),
          Text('${p.paperSize} · ${p.color == 'bw' ? 'أبيض وأسود' : 'ملوّن'} · ${p.sides == 'double' ? 'وجهان' : 'وجه واحد'} · ${p.copies} نسخ${p.binding.isEmpty || p.binding == 'none' ? '' : ' · ${p.binding}'}', style: T.sm(c.tx2)),
        ])),
      ]);
    }
    return Row(children: [
      ProdThumb(name: it.name, seed: it.id),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(it.name, style: T.h3(c.tx, size: 15).copyWith(height: 1.45)),
        if ((it.note ?? '').isNotEmpty) Text(it.note!, style: T.sm(c.tx2)),
        Padding(padding: const EdgeInsets.only(top: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Num('× ${it.qty}', style: T.sm(c.tx2)), if (it.lineTotal != null) Mny(it.lineTotal!.amount)])),
      ])),
    ]);
  }

  Widget _context(BuildContext context, OrderModel o) {
    final c = context.sc;
    switch (o.statusKey) {
      case 'awaiting_pricing':
        return HeroBox(padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10), child: Column(children: [const Ill('wait', width: 160), Text('المكتبة تسعّر طلبك', style: T.h2(c.onHero)), const SizedBox(height: 4), Text('ستصلك إشعارات فور جاهزية العرض. تُحدَّث الصفحة تلقائيًا.', textAlign: TextAlign.center, style: T.sm(c.onHero.withValues(alpha: .8)))]));
      case 'priced':
        return Card2(color: c.coralSoft, child: DefaultTextStyle(style: TextStyle(fontFamily: Fonts.ui, color: c.coralInk), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('عرض السعر جاهز', style: T.h3(c.coralInk)), Row(children: [SIcon('clock', size: 18, color: c.coralInk)])]),
          const SizedBox(height: 8),
          Mny(o.total.amount, size: 30, color: c.coralInk),
          const SizedBox(height: 8),
          SBtn('راجع العرض', full: true, onTap: () => Get.toNamed('/offer', arguments: {'order_id': o.id})),
        ])));
      case 'pending':
        return Note('plum', text: o.isCash ? 'وافقت على السعر. المكتبة تجهّز الطلب وتدفع نقدًا عند التسليم.' : 'وافقت على السعر. بانتظار قبول المكتبة، ثم يُفتح الدفع.');
      case 'awaiting_payment':
        return Card2(color: c.coralSoft, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [Text('حوّل ', style: T.h3(c.coralInk)), Mny(o.total.amount, color: c.coralInk), Text(' وارفع الإشعار', style: T.h3(c.coralInk))]),
          const SizedBox(height: 4),
          Text('الدفع يتم عبر تطبيق البنك أو المحفظة.', style: T.sm(c.coralInk)),
          if ((o.reviewNote ?? '').isNotEmpty) ...[const SizedBox(height: 8), Text('ملاحظة المكتبة: ${o.reviewNote}', style: T.sm(c.coralInk, w: FontWeight.w600))],
          const SizedBox(height: 8),
          SBtn('بيانات التحويل', full: true, onTap: () => Get.toNamed('/pay', arguments: {'order_id': o.id})),
        ]));
      case 'payment_review':
        return const Note('warn', icon: 'clock', title: 'نراجع إشعار الدفع.', text: 'سنُعلمك فور اعتماده أو إن احتجنا لتصحيح.');
      case 'preparing':
        return const Note('ok', title: 'تم اعتماد الدفع.', text: 'المكتبة تجهّز طلبك الآن.');
      case 'ready_for_delivery':
        return const Note('plum', icon: 'truck', text: 'الطلب جاهز وبانتظار سائق قريب منك.');
      case 'accepted':
      case 'picked_up':
      case 'on_the_way':
      case 'arrived':
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Card2(padding: EdgeInsets.zero, clip: true, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (['picked_up', 'on_the_way', 'arrived'].contains(o.statusKey))
              Padding(padding: const EdgeInsets.all(16), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(o.statusKey == 'arrived' ? 'وصل السائق' : 'السائق في الطريق إليك', style: T.h3(c.tx)), SBtn('تتبّع', size: BtnSize.sm, icon: 'nav', onTap: () => Get.toNamed('/tracking', arguments: {'order_id': o.id}))])),
            if (o.driver != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(children: [
                  Avatar(o.driver!.name.isEmpty ? 'س' : firstCh(o.driver!.name)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${o.driver!.name} · ${kVehicleLabels[o.driver!.vehicleType] ?? ''}', style: T.h3(c.tx, size: 15)), Row(children: [SIcon('star', size: 14, color: c.amber, filled: true), const SizedBox(width: 4), Text(o.driver!.rating.toStringAsFixed(1), style: T.sm(c.tx))])])),
                  SIconBtn('phone', tonal: true, size: 22, onTap: () => callPhone(o.driver!.phone)),
                ]),
              ),
            if (o.driver == null) Padding(padding: const EdgeInsets.all(16), child: Text('السائق في الطريق إلى المكتبة.', style: T.sm(c.tx2))),
          ])),
          if ((o.deliveryCode ?? '').isNotEmpty) ...[
            const SizedBox(height: 16),
            Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('رمز التسليم · أعطه للسائق عند الاستلام', style: T.cap(c.tx2)), const SizedBox(height: 6), CodeBox(o.deliveryCode!, bg: c.sf, size: 26)])),
          ],
        ]);
      case 'delivered':
        return Card2(color: c.okSoft, child: DefaultTextStyle(style: TextStyle(fontFamily: Fonts.ui, color: c.okInk), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [SIcon('checkC', size: 24, color: c.okInk), const SizedBox(width: 10), Text('تم تسليم طلبك', style: T.h3(c.okInk))]),
          const SizedBox(height: 8),
          if (o.ratingStars == 0 && o.can('rate')) Text('كيف كانت تجربتك مع السائق؟', style: T.sm(c.okInk)) else Text('شكرًا لتقييمك.', style: T.sm(c.okInk)),
          const SizedBox(height: 8),
          Row(children: [
            if (o.ratingStars == 0 && o.can('rate')) SBtn('قيّم الطلب', size: BtnSize.sm, onTap: () => Get.toNamed('/rate', arguments: {'order_id': o.id})),
            if (o.ratingStars == 0 && o.can('rate')) const SizedBox(width: 8),
            SBtn('الإيصال', size: BtnSize.sm, kind: BtnKind.sec, onTap: () => Get.toNamed('/receipt', arguments: {'order_id': o.id})),
          ]),
        ])));
      case 'cancelled':
        return Note('err', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text.rich(TextSpan(children: [const TextSpan(text: 'أُلغي الطلب.', style: TextStyle(fontWeight: FontWeight.w700)), if ((o.cancelReason ?? '').isNotEmpty) TextSpan(text: ' السبب: ${o.cancelReason}')])),
          Text('ألغاه: ${_who(o.cancelledBy)}', style: T.cap(c.errInk)),
        ]));
      case 'delivery_failed':
        return Note('err', action: 'اتصل بالدعم', onActionTap: supportCall, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text.rich(TextSpan(children: [const TextSpan(text: 'تعذّر تسليم الطلب.', style: TextStyle(fontWeight: FontWeight.w700)), TextSpan(text: ' السبب: ${_failure(o.failureReason)}')])),
          Text('يمكنك التواصل مع الدعم لترتيب محاولة جديدة.', style: T.cap(c.errInk)),
        ]));
    }
    return const SizedBox.shrink();
  }

  String _who(String? v) => switch (v) { 'user' || 'customer' => 'أنت', 'vendor' || 'library' => 'المكتبة', 'driver' => 'السائق', 'system' => 'النظام', _ => v ?? '—' };
  String _failure(String? v) => switch (v) {
        'customer_unreachable' => 'الزبون لا يرد على الهاتف',
        'incorrect_address' => 'العنوان غير صحيح',
        'reschedule_requested' => 'طُلبت إعادة الجدولة',
        'access_unavailable' => 'تعذّر الوصول إلى المكان',
        'other' => 'سبب آخر',
        _ => 'لم يتم الوصول إلى المستلم',
      };

  void _more(BuildContext context, OrderModel o) {
    showSheet(context, title: o.code, body: Column(children: [
      LiTile('file', 'الإيصال', first: true, onTap: () {
        Get.back();
        Get.toNamed('/receipt', arguments: {'order_id': o.id});
      }),
      LiTile('headset', 'الدعم', onTap: () {
        Get.back();
        supportCall();
      }),
    ]));
  }
}

// -------------------------------------------------------------- cancel sheet

void cancelSheet(BuildContext context, OrderModel o) async {
  final reasons = await backend.cancelReasons();
  if (!context.mounted) return;
  final list = reasons.getOrElse(() => const []);
  var sel = list.isEmpty ? '' : list.first.key;
  final note = TextEditingController();
  var busy = false;
  String? err;
  showSheet(context, title: 'إلغاء الطلب', body: StatefulBuilder(builder: (ctx, set) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (list.isEmpty) Text('تعذّر تحميل الأسباب.', style: T.sm(ctx.sc.tx2)),
      for (final r in list) ...[OptCard(on: sel == r.key, title: r.label, onTap: () => set(() => sel = r.key)), const SizedBox(height: 8)],
      const SizedBox(height: 8),
      Fld(label: 'ملاحظة', hint: 'أخبرنا المزيد…', controller: note, optional: true, maxLines: 3),
      if (err != null) ...[const SizedBox(height: 8), FieldError(err!)],
      const SizedBox(height: 18),
      SBtn('إلغاء الطلب', kind: BtnKind.danger, full: true, loading: busy, disabled: sel.isEmpty, onTap: () async {
        set(() {
          busy = true;
          err = null;
        });
        final r = await backend.cancel(o.id, sel, note: note.text);
        r.fold((f) {
          set(() => busy = false);
          if (f.code == ApiErrorCodes.invalidTransition) {
            Get.back();
            showDlg(context, kind: 'warn', icon: 'alert', title: 'لا يمكن إلغاء الطلب الآن', text: 'الطلب مع السائق وفي الطريق إليك. للمساعدة تواصل مع الدعم.', foot: [
              SBtn('اتصل بالدعم', icon: 'phone', full: true, onTap: supportCall),
              SBtn('حسنًا', kind: BtnKind.ghost, full: true, onTap: () => Get.back()),
            ]);
          } else {
            set(() => err = failureText(f));
          }
        }, (_) {
          Get.back();
          if (Get.isRegistered<OrderDetailController>()) Get.find<OrderDetailController>().load();
          showToast('أُلغي الطلب');
        });
      }),
      const SizedBox(height: 8),
      SBtn('تراجع', kind: BtnKind.ghost, full: true, onTap: () => Get.back()),
    ]);
  }));
}

// -------------------------------------------------------------- share sheet

void shareSheet(BuildContext context, OrderModel o) async {
  final c = context.sc;
  final r = await backend.createShareLink(o.id);
  if (!context.mounted) return;
  r.fold((f) => showToast(failureText(f), icon: 'alertC'), (link) {
    showSheet(context, title: 'شارك تتبّع طلبك', body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('أي شخص لديه الرابط يرى حالة الطلب والوقت المتوقع وموقعًا تقريبيًا، دون تسجيل دخول. الرابط صالح 48 ساعة.', style: T.sm(c.tx2)),
      const SizedBox(height: 16),
      Panel(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), child: Row(children: [
        Expanded(child: Text(link.url, textDirection: TextDirection.ltr, maxLines: 1, overflow: TextOverflow.ellipsis, style: T.sm(c.tx))),
        SBtn('نسخ', kind: BtnKind.sec, size: BtnSize.xs, icon: 'copy', onTap: () {
          Clipboard.setData(ClipboardData(text: link.url));
          showToast('تم النسخ', icon: 'copy');
        }),
      ])),
      const SizedBox(height: 8),
      SBtn('معاينة الصفحة العامة', kind: BtnKind.ghost, icon: 'eye', onTap: () {
        Get.back();
        Get.toNamed('/track', arguments: {'token': link.token});
      }),
    ]), foot: [
      SBtn('أوقف مشاركة الرابط', kind: BtnKind.danger, icon: 'x', full: true, onTap: () async {
        final s = await backend.stopShareLinks(o.id);
        Get.back();
        s.fold((f) => showToast(failureText(f), icon: 'alertC'), (_) => showToast('أُوقفت مشاركة الرابط'));
      }),
      SBtn('إغلاق', kind: BtnKind.ghost, full: true, onTap: () => Get.back()),
    ]);
  });
}

// ----------------------------------------------------------------- tracking

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

/// خريطة حقيقية (OSM) بعلامات بتصميم المعتمد: المكتبة، وجهة التسليم، السائق.
class RouteMap extends StatelessWidget {
  const RouteMap({super.key, required this.height, this.pickup, this.drop, this.driver, this.tail = const [], this.radius = 0});
  final double height;
  final LatLng? pickup;
  final LatLng? drop;
  final LatLng? driver;
  final List<LatLng> tail;
  final double radius;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final pts = [if (pickup != null) pickup!, if (drop != null) drop!, if (driver != null) driver!];
    final center = pts.isEmpty ? const LatLng(31.9, 35.2) : LatLng(pts.map((p) => p.latitude).reduce((a, b) => a + b) / pts.length, pts.map((p) => p.longitude).reduce((a, b) => a + b) / pts.length);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        height: height,
        child: FlutterMap(
          options: MapOptions(initialCenter: center, initialZoom: 14, initialCameraFit: pts.length >= 2 ? CameraFit.coordinates(coordinates: pts, padding: const EdgeInsets.all(48), maxZoom: 16) : null, interactionOptions: const InteractionOptions(flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag)),
          children: [
            TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.example.project'),
            if (tail.length > 1) PolylineLayer(polylines: [Polyline(points: tail, color: c.pri, strokeWidth: 5)]),
            MarkerLayer(markers: [
              if (pickup != null) Marker(point: pickup!, width: 26, height: 26, child: Container(decoration: BoxDecoration(color: c.amber, borderRadius: BorderRadius.circular(8)), child: Center(child: SIcon('home', size: 16, color: const Color(0xFF2A1626))))),
              if (drop != null) Marker(point: drop!, width: 40, height: 46, alignment: Alignment.topCenter, child: SIcon('pin', size: 40, color: c.pri)),
              if (driver != null) Marker(point: driver!, width: 36, height: 36, child: Container(decoration: BoxDecoration(color: c.pri, shape: BoxShape.circle, border: Border.all(color: c.sf, width: 3)), child: Center(child: SIcon('nav', size: 16, color: c.onPri)))),
            ]),
          ],
        ),
      ),
    );
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
      final stale = !d.hasLocation || d.isStale();
      final driverPt = d.hasLocation ? LatLng(d.driverLat!, d.driverLng!) : null;
      return Page2(
        top: TopBar(title: 'تتبّع الطلب', right: SIconBtn('share', onTap: o == null ? null : () => shareSheet(context, o))),
        flush: true,
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Stack(children: [
            RouteMap(height: 360, pickup: d.pickupLat == null ? null : LatLng(d.pickupLat!, d.pickupLng!), drop: d.dropLat == null ? null : LatLng(d.dropLat!, d.dropLng!), driver: driverPt, tail: [for (final p in d.tail) LatLng(p.$1, p.$2)]),
            Positioned(top: 12, left: 16, right: 16, child: Note('cream', icon: stale ? 'alert' : null, child: stale ? Row(children: [Expanded(child: Text(d.hasLocation ? 'آخر موقع للسائق قبل ${DateTime.now().difference(d.lastSeenAt!).inMinutes} دقائق. قد يكون في منطقة ضعيفة التغطية.' : 'لا يوجد موقع للسائق بعد. سيظهر عند وصول أول تحديث.'))]) : Row(children: [const LiveDot(), const SizedBox(width: 12), const Text('يتحدّث الموقع تلقائيًا كل بضع ثوانٍ')]))),
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
                if ((o?.deliveryCode ?? '').isNotEmpty) ...[const SizedBox(height: 24), Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('رمز التسليم', style: T.cap(c.tx2)), const SizedBox(height: 6), CodeBox(o!.deliveryCode!, bg: c.sf)]))],
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

class NotificationsController extends GetxController {
  final bool driver;
  NotificationsController({this.driver = false});
  final list = <NotificationModel>[].obs;
  final loading = true.obs;
  final failure = Rxn<Failure>();
  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    failure.value = null;
    final r = await backend.notifications(driver: driver);
    r.fold((f) => failure.value = f, (v) => list.assignAll(v));
    loading.value = false;
  }

  Future<void> readAll() async {
    await backend.readAllNotifications(driver: driver);
    await load();
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key, this.driver = false});
  final bool driver;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final ctl = Get.put(NotificationsController(driver: driver), tag: driver ? 'd' : 'c');
    return Obx(() {
      if (!ctl.loading.value && ctl.failure.value == null && ctl.list.isEmpty) {
        return Page2(tab: driver ? 'home' : 'home', role: driver ? TabRole.driver : TabRole.customer, top: const TopBar(title: 'الإشعارات'), center: true, body: const EmptyState(ill: 'books', title: 'لا إشعارات بعد', text: 'سنُعلمك هنا بكل جديد يخص طلباتك.'));
      }
      return Page2(
        tab: 'home',
        role: driver ? TabRole.driver : TabRole.customer,
        top: TopBar(title: 'الإشعارات', right: SBtn('قراءة الكل', kind: BtnKind.ghost, size: BtnSize.xs, onTap: ctl.readAll)),
        onRefresh: ctl.load,
        body: ctl.loading.value
            ? Column(children: [for (var i = 0; i < 4; i++) const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Row(children: [Skel(w: 44, h: 44, r: 14), SizedBox(width: 14), Expanded(child: Skel(h: 36))]))])
            : ctl.failure.value != null
                ? EmptyState(ill: 'offline', title: 'تعذّر التحميل', text: failureText(ctl.failure.value!), cta: SBtn('أعد المحاولة', full: true, onTap: ctl.load))
                : Column(children: [
                    for (var i = 0; i < ctl.list.length; i++)
                      LiTile('bell', ctl.list[i].title, sub: '${ctl.list[i].body}\n${timeLabel(ctl.list[i].createdAt)}', first: i == 0, iconBg: ctl.list[i].unread ? c.plumSoft : c.sf2, end: ctl.list[i].unread ? PinDot(color: c.coral) : const SizedBox.shrink(), onTap: () async {
                        backend.notificationOpened(ctl.list[i].id, driver: driver);
                        final oid = ctl.list[i].orderId;
                        if (oid != null && !driver) Get.toNamed('/order', arguments: {'order_id': oid});
                      }),
                  ]),
      );
    });
  }
}
