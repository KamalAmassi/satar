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
import 'package:project/customer/features/catalog/presentation/catalog_page.dart';
import 'package:project/customer/features/orders/presentation/orders_page.dart';
import 'package:project/core/data/models.dart';
import 'package:project/core/widgets/common_widgets.dart';
import 'package:project/core/network/masar_model/masar_models.dart';
import 'package:project/core/services/push/notification_pagination_parser.dart';
import 'package:project/core/services/push/notification_router.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> callPhone(String? phone) async {
  if (phone == null || phone.isEmpty) return;
  await launchUrl(Uri.parse('tel:$phone'));
}

Future<void> callUrl(String u) async => launchUrl(Uri.parse(u), mode: LaunchMode.externalApplication);

Future<void> supportCall() async => callPhone(Get.find<RemoteConfigRepository>().current?.supportPhone);

class OrdersController extends GetxController {
  final tab = 'active'.obs;
  final list = <OrderSummaryModel>[].obs;
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
    final r = await backend.orders(scope: tab.value);
    r.fold((f) => failure.value = f, (v) => list.assignAll(v));
    loading.value = false;
  }

  void switchTab(String t) {
    if (tab.value == t) return;
    tab.value = t;
    load();
  }
}

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final ctl = Get.put(OrdersController());
    return Obx(() {
      return Page2(
        tab: 'orders',
        top: const TopBar(title: 'طلباتي', back: false),
        onRefresh: ctl.load,
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Seg(items: const [('active', 'النشطة'), ('history', 'السابقة')], value: ctl.tab.value, onChanged: ctl.switchTab),
          const SizedBox(height: 16),
          if (ctl.loading.value)
            Column(children: [for (var i = 0; i < 3; i++) const Padding(padding: EdgeInsets.only(bottom: 12), child: Skel(h: 130, r: 20))])
          else if (ctl.failure.value != null)
            EmptyState(ill: 'offline', title: 'تعذّر التحميل', text: failureText(ctl.failure.value!), cta: SBtn('أعد المحاولة', full: true, onTap: ctl.load))
          else if (ctl.list.isEmpty)
            EmptyState(ill: 'bag', title: ctl.tab.value == 'active' ? 'لا طلبات نشطة' : 'لا يوجد شيء هنا', text: ctl.tab.value == 'active' ? 'اطلب من المساعد أو تصفح المنتجات لإنشاء طلبك الأول.' : 'تظهر هنا طلباتك المكتملة أو الملقاة.')
          else
            Column(children: [
              for (final o in ctl.list) ...[
                _OrderCard(o),
                const SizedBox(height: 12),
              ],
            ]),
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
    final hot = o.status.key == 'priced' || o.status.key == 'awaiting_payment';
    return Card2(
      onTap: () => Get.toNamed(hot ? '/offer' : '/order', arguments: {'order_id': o.id}),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [Text(o.code, style: T.h3(c.tx, size: 15.5)), const SizedBox(width: 8), StatusPill(o.status.key, label: statusLabel(o.status))]),
          Text(timeLabel(o.createdAt), style: T.cap(c.tx2)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: c.sf2, borderRadius: BorderRadius.circular(12)), child: Center(child: SIcon('box', size: 22, color: c.plumInk))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(o.summary.isEmpty ? 'طلب سطر' : o.summary, maxLines: 1, overflow: TextOverflow.ellipsis, style: T.sm(c.tx, w: FontWeight.w600)),
            Text('${o.itemsCount} ${o.itemsCount == 1 ? 'عنصر' : 'عناصر'}', style: T.cap(c.tx2)),
          ])),
          if (o.total != null) Mny(o.total!.amount, size: 17),
        ]),
      ]),
    );
  }
}

class OrderDetailController extends GetxController {
  final order = Rxn<OrderModel>();
  final loading = true.obs;
  final failure = Rxn<Failure>();
  late final int id;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    final a = Get.arguments;
    id = a is Map ? (a['order_id'] as int? ?? a['id'] as int? ?? 0) : (a is int ? a : 0);
    load();
    _timer = Timer.periodic(const Duration(seconds: 12), (_) => refreshSilent());
  }

  Future<void> load() async {
    loading.value = order.value == null;
    failure.value = null;
    final r = await backend.order(id);
    r.fold((f) => failure.value = f, (v) => order.value = v);
    loading.value = false;
  }

  Future<void> refreshSilent() async {
    final r = await backend.order(id);
    r.fold((_) {}, (v) => order.value = v);
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final ctl = Get.put(OrderDetailController());
    return Obx(() {
      final o = ctl.order.value;
      if (ctl.loading.value && o == null) return Page2(top: const TopBar(title: 'تفاصيل الطلب'), body: const Column(children: [Skel(h: 160, r: 20), SizedBox(height: 16), Skel(h: 200, r: 20)]));
      if (o == null) return Page2(top: const TopBar(title: ''), center: true, body: EmptyState(ill: 'offline', title: 'تعذّر تحميل الطلب', text: failureText(ctl.failure.value ?? const UnknownFailure()), cta: SBtn('أعد المحاولة', full: true, onTap: ctl.load)));
      final k = o.status.key;
      return Page2(
        top: TopBar(title: 'طلب ${o.code}', right: SIconBtn('refresh', size: 20, onTap: ctl.load)),
        onRefresh: ctl.load,
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          HeroBox(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [StatusPill(k, label: statusLabel(o.status)), Text(dateLabel(o.createdAt), style: T.cap(c.onHero))]),
              const SizedBox(height: 12),
              Text(statusDesc(k), style: T.bd(c.onHero)),
              if (k == 'priced') ...[
                const SizedBox(height: 16),
                FootBar(child: SBtn('راجع العرض', full: true, onTap: () => Get.toNamed('/offer', arguments: {'order_id': o.id}))),
              ] else if (k == 'awaiting_payment') ...[
                const SizedBox(height: 16),
                FootBar(child: SBtn('ارفع إشعار التحويل', full: true, onTap: () => Get.toNamed('/pay', arguments: {'order_id': o.id}))),
              ],
            ]),
          ),
          const SizedBox(height: 16),
          Card2(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('البنود', style: T.h3(c.tx)), Text('${o.items.length} بنود', style: T.cap(c.tx2))]),
            const SizedBox(height: 12),
            for (final it in o.items) ...[
              Row(children: [
                ProdThumb(imageUrl: it.imageUrl, name: it.name, seed: it.productId ?? 0),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(it.name, style: T.sm(c.tx, w: FontWeight.w600)), Text('الكمية: ${it.quantity}', style: T.cap(c.tx2))])),
                if (it.totalPrice != null) Mny(it.totalPrice!.amount),
              ]),
              const SizedBox(height: 12),
            ],
          ])),
          const SizedBox(height: 16),
          if (o.breakdown.isNotEmpty)
            Card2(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text('ملخص السعر', style: T.h3(c.tx)),
              const SizedBox(height: 8),
              for (final b in o.breakdown) KV(b.label, null, vWidget: Mny(b.amount.amount)),
              if (o.total != null) KV('الإجمالي', null, total: true, vWidget: Mny(o.total!.amount, size: 18)),
            ])),
          const SizedBox(height: 16),
          Row(children: [
            if (o.can('cancel')) SBtn('إلغاء الطلب', kind: BtnKind.ghost, size: BtnSize.sm, icon: 'x', onTap: () => cancelSheet(context, ctl)),
            if (['picked_up', 'on_the_way', 'arrived'].contains(k)) SBtn('شارك رابط التتبع', kind: BtnKind.sec, size: BtnSize.sm, icon: 'share', onTap: () => shareSheet(context, o.id)),
            const Spacer(),
            if (o.ratingStars == 0 && o.can('rate')) SBtn('قيّم الطلب', size: BtnSize.sm, onTap: () => Get.toNamed('/rate', arguments: {'order_id': o.id})),
            if (o.receiptUrl != null) SBtn('الإيصال', size: BtnSize.sm, kind: BtnKind.sec, onTap: () => Get.toNamed('/receipt', arguments: {'order_id': o.id})),
          ]),
        ]),
      );
    });
  }
}

void cancelSheet(BuildContext context, OrderDetailController ctl) {
  var reason = 'غيّرت رأيي';
  final note = TextEditingController();
  showSheet(context, title: 'إلغاء الطلب', body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    for (final r in const ['غيّرت رأيي', 'تأخر الوقت', 'السعر غير مناسب', 'سبب آخر']) ...[
      OptCard(on: reason == r, title: r, onTap: () => reason = r),
      const SizedBox(height: 8),
    ],
    Fld(label: 'ملاحظة (إضافي)', controller: note, optional: true),
  ]), foot: [
    SBtn('إلغاء الطلب', kind: BtnKind.danger, full: true, onTap: () async {
      Get.back();
      final res = await backend.cancel(ctl.id, reason, note: note.text);
      res.fold((f) => showToast(failureText(f), icon: 'alertC'), (_) {
        showToast('أُلغي الطلب');
        ctl.load();
      });
    }),
    SBtn('تراجع', kind: BtnKind.ghost, full: true, onTap: () => Get.back()),
  ]);
}

void shareSheet(BuildContext context, int id) {
  showSheet(context, title: 'مشاركة التتبع', body: Column(children: [
    const Ill('route', width: 150),
    const SizedBox(height: 12),
    Text('أنشئ رابطًا عامًا للتتبع يمكن لأي شخص فتح التقرير الحي من خلاله.', style: T.sm(context.sc.tx2)),
  ]), foot: [
    SBtn('إنشاء رابط', full: true, onTap: () async {
      Get.back();
      final r = await backend.createShareLink(id);
      r.fold((f) => showToast(failureText(f), icon: 'alertC'), (l) {
        Clipboard.setData(ClipboardData(text: l.url));
        showToast('نسخ الرابط');
      });
    }),
  ]);
}

extension AppNotificationExt on AppNotification {
  bool get unread => readAt == null;
  int? get orderId {
    final v = data['order_id'] ?? data['order'];
    return v is num ? v.toInt() : int.tryParse('$v');
  }
}

class NotificationsController extends GetxController {
  final bool driver;
  NotificationsController({this.driver = false});

  final list = <AppNotification>[].obs;
  final loading = true.obs;
  final loadingMore = false.obs;
  final hasMore = true.obs;
  final unreadCount = 0.obs;
  final failure = Rxn<Failure>();

  int _currentPage = 1;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    failure.value = null;
    _currentPage = 1;
    hasMore.value = true;

    final r = await backend.notifications(driver: driver, perPage: NotificationPaginationParser.defaultPerPage);
    r.fold(
      (f) => failure.value = f,
      (v) {
        final parsedResult = NotificationPaginationParser.parse(
          responseMap: {
            'data': [for (final n in v) n.toJson()],
            'meta': {'unread': v.where((n) => n.readAt == null).length},
          },
          existingItems: const [],
          requestedPage: 1,
          perPage: NotificationPaginationParser.defaultPerPage,
        );
        list.assignAll(parsedResult.items);
        unreadCount.value = parsedResult.unreadCount;
        hasMore.value = parsedResult.hasMore;
      },
    );
    loading.value = false;
  }

  Future<void> loadMore() async {
    if (loadingMore.value || !hasMore.value) return;
    loadingMore.value = true;
    final nextPage = _currentPage + 1;

    final r = await backend.notifications(driver: driver, perPage: NotificationPaginationParser.defaultPerPage);
    r.fold(
      (_) => hasMore.value = false,
      (v) {
        final parsedResult = NotificationPaginationParser.parse(
          responseMap: {
            'data': [for (final n in v) n.toJson()],
          },
          existingItems: list,
          requestedPage: nextPage,
          perPage: NotificationPaginationParser.defaultPerPage,
        );
        if (parsedResult.items.isNotEmpty) {
          final newItems = parsedResult.items.where((n) => !list.any((x) => x.id == n.id)).toList();
          if (newItems.isNotEmpty) {
            list.addAll(newItems);
            _currentPage = nextPage;
          }
        }
        hasMore.value = parsedResult.hasMore;
      },
    );
    loadingMore.value = false;
  }

  Future<void> readAll() async {
    await backend.readAllNotifications(driver: driver);
    await load();
  }

  Future<void> openNotification(AppNotification item) async {
    backend.notificationOpened(item.id, driver: driver);
    NotificationRouter.routePayload(item.data, isDriver: driver);
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
        return Page2(
          tab: driver ? 'home' : 'home',
          role: driver ? TabRole.driver : TabRole.customer,
          top: const TopBar(title: 'الإشعارات'),
          center: true,
          body: const EmptyState(
            ill: 'books',
            title: 'لا إشعارات بعد',
            text: 'سنُعلمك هنا بكل جديد يخص طلباتك.',
          ),
        );
      }
      return Page2(
        tab: 'home',
        role: driver ? TabRole.driver : TabRole.customer,
        top: TopBar(
          title: 'الإشعارات',
          right: ctl.unreadCount.value > 0
              ? SBtn('قراءة الكل', kind: BtnKind.ghost, size: BtnSize.xs, onTap: ctl.readAll)
              : null,
        ),
        onRefresh: ctl.load,
        body: ctl.loading.value
            ? Column(children: [
                for (var i = 0; i < 4; i++)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Row(children: [
                      Skel(w: 44, h: 44, r: 14),
                      SizedBox(width: 14),
                      Expanded(child: Skel(h: 36)),
                    ]),
                  ),
              ])
            : ctl.failure.value != null
                ? EmptyState(
                    ill: 'offline',
                    title: 'تعذّر التحميل',
                    text: failureText(ctl.failure.value!),
                    cta: SBtn('أعد المحاولة', full: true, onTap: ctl.load),
                  )
                : Column(children: [
                    for (var i = 0; i < ctl.list.length; i++)
                      LiTile(
                        'bell',
                        ctl.list[i].title,
                        sub: '${ctl.list[i].body}\n${timeLabel(ctl.list[i].createdAt)}',
                        first: i == 0,
                        iconBg: ctl.list[i].unread ? c.plumSoft : c.sf2,
                        end: ctl.list[i].unread ? PinDot(color: c.coral) : const SizedBox.shrink(),
                        onTap: () => ctl.openNotification(ctl.list[i]),
                      ),
                    if (ctl.hasMore.value)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: SBtn(
                          'تحميل المزيد',
                          kind: BtnKind.sec,
                          size: BtnSize.sm,
                          loading: ctl.loadingMore.value,
                          onTap: ctl.loadMore,
                        ),
                      ),
                  ]),
      );
    });
  }
}
