import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/core/design/icons.dart';
import 'package:project/core/design/illustrations.dart';
import 'package:project/core/design/shell.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/design/widgets.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/routes/route_args.dart';
import 'package:project/customer/features/library_offer/domain/entities/library_offer.dart';
import 'package:project/customer/features/library_offer/presentation/bindings/offer_binding.dart';
import 'package:project/customer/features/library_offer/presentation/controllers/offer_controller.dart';
import 'package:project/customer/features/payment/presentation/bindings/transfer_payment_binding.dart';
import 'package:project/customer/features/payment/presentation/controllers/transfer_payment_controller.dart';
import 'package:project/customer/features/printing/domain/entities/file_check.dart';
import 'package:project/data/models.dart';
import 'package:project/features/common.dart';

// -------------------------------------------------------------------- offer

class OfferScreen extends StatelessWidget {
  const OfferScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    OfferBinding().dependencies();
    final ctl = Get.find<OfferController>();
    return Obx(() {
      final st = ctl.viewState.value;
      final o = ctl.offer.value;
      if (st == OfferViewState.loading) return Page2(top: const TopBar(title: 'عرض المكتبة'), body: const Column(children: [Skel(h: 56), SizedBox(height: 16), Skel(h: 200, r: 20), SizedBox(height: 16), Skel(h: 120, r: 20)]));
      if (st == OfferViewState.notReady) {
        return Page2(top: const TopBar(title: 'عرض المكتبة'), center: true, body: Column(mainAxisSize: MainAxisSize.min, children: [const Ill('wait', width: 190), const SizedBox(height: 16), Text('المكتبة تسعّر طلبك', textAlign: TextAlign.center, style: T.d2(c.tx)), const SizedBox(height: 8), Text('سيظهر العرض هنا فور جاهزيته، وستصلك رسالة بذلك.', textAlign: TextAlign.center, style: T.bd(c.tx2)), const SizedBox(height: 16), Row(mainAxisAlignment: MainAxisAlignment.center, children: [const LiveDot(), const SizedBox(width: 10), Text('تُحدَّث الصفحة تلقائيًا', style: T.sm(c.tx2))])]));
      }
      if (st == OfferViewState.failed || o == null) {
        return Page2(top: const TopBar(title: 'عرض المكتبة'), center: true, body: EmptyState(ill: 'offline', title: 'تعذّر تحميل العرض', text: failureText(ctl.failure.value ?? const UnknownFailure()), cta: SBtn('أعد المحاولة', full: true, onTap: ctl.load)));
      }
      if (st == OfferViewState.approved && !ctl.handledApproval) {
        ctl.handledApproval = true;
        WidgetsBinding.instance.addPostFrameCallback((_) => Get.offNamed('/offer/approved', arguments: {'order_id': ctl.orderId}));
      }
      if (st != OfferViewState.changed) ctl.shownChanged = false;
      if (st == OfferViewState.changed && !ctl.shownChanged) {
        ctl.shownChanged = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (ctl.viewState.value != OfferViewState.changed) return;
          showDlg(context, kind: 'warn', icon: 'refresh', title: 'حدّثت المكتبة السعر', text: 'أصبح الإجمالي ${fmtMinor(o.total.amount)}. راجع العرض الجديد قبل الموافقة.', dismissible: false, foot: [
            SBtn('راجع العرض الجديد', full: true, onTap: () {
              Get.back();
              ctl.viewState.value = OfferViewState.open;
            }),
          ]);
        });
      }
      final expired = st == OfferViewState.expired;
      final subs = o.hasSubstitutions;
      final rejected = st == OfferViewState.rejected;
      return Page2(
        top: const TopBar(title: 'عرض المكتبة'),
        onRefresh: ctl.load,
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Note(expired || rejected ? 'err' : 'warn', icon: 'clock', child: expired ? const Text.rich(TextSpan(text: 'انتهت مدة العرض.', style: TextStyle(fontWeight: FontWeight.w700))) : rejected ? const Text.rich(TextSpan(text: 'رُفض هذا العرض.', style: TextStyle(fontWeight: FontWeight.w700))) : (o.expiresAt == null ? const Text('العرض بانتظار موافقتك') : Row(children: [const Text('العرض صالح لمدة '), CountdownText(ctl.remaining.value.inSeconds, key: ValueKey(o.id), style: TextStyle(fontFamily: Fonts.ui, fontWeight: FontWeight.w700, color: c.amberInk))]))),
          const SizedBox(height: 16),
          Text(subs ? 'راجع السعر والبدائل' : 'راجع السعر', style: T.h1(c.tx)),
          const SizedBox(height: 8),
          Text(subs ? 'بعض العناصر غير متوفرة. اقترحت المكتبة بدائل بفرق سعر. لا يتم الاستبدال بدون موافقتك.' : 'هذا هو السعر النهائي الذي حدّدته المكتبة لطلبك.', style: T.sm(c.tx2)),
          const SizedBox(height: 16),
          Card2(child: Column(children: [
            for (var i = 0; i < o.items.length; i++) ...[
              if (i > 0) const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider2()),
              _offerItem(context, o.items[i]),
            ],
          ])),
          if ((o.note ?? '').isNotEmpty) ...[const SizedBox(height: 16), Note('plum', icon: 'info', text: o.note)],
          if (subs && !expired && !rejected) ...[
            const SizedBox(height: 16),
            OptCard(on: ctl.substitutionsAccepted.value, title: 'أوافق على الاستبدال المقترح وعلى الإجمالي الجديد', check: false, trailing: SCheck(ctl.substitutionsAccepted.value), onTap: () => ctl.substitutionsAccepted.toggle()),
          ],
          const SizedBox(height: 16),
          PriceBox(rows: [('المنتجات', Mny(o.itemsTotal.amount)), ('التوصيل', Mny(o.deliveryFee.amount))], totalMinor: o.total.amount),
          if (ctl.failure.value != null && !expired) ...[const SizedBox(height: 16), Note('err', text: failureText(ctl.failure.value!))],
        ]),
        foot: FootBar(child: expired || rejected
            ? Column(mainAxisSize: MainAxisSize.min, children: [SBtn('العودة إلى الطلب', full: true, onTap: () => Get.offNamed('/order', arguments: {'order_id': ctl.orderId})), const SizedBox(height: 8), const Text('قد ترسل المكتبة عرضًا جديدًا. تصلك رسالة عند ذلك.', textAlign: TextAlign.center)])
            : Column(mainAxisSize: MainAxisSize.min, children: [
                SBtn('أوافق على السعر', full: true, loading: ctl.acting.value, disabled: !ctl.canApprove, onTap: ctl.approve),
                const SizedBox(height: 8),
                SBtn('أرفض', kind: BtnKind.ghost, full: true, disabled: ctl.acting.value, onTap: () => _rejectSheet(context, ctl)),
              ])),
      );
    });
  }

  Widget _offerItem(BuildContext context, LibraryOfferItem it) {
    final c = context.sc;
    if (!it.available) {
      return Column(children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ProdThumb(name: it.name, seed: it.id),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(it.name, style: T.h3(c.tx, size: 15).copyWith(height: 1.45)), const SizedBox(height: 2), Row(children: [const STag('غير متوفر', kind: 'err'), const SizedBox(width: 8), Mny(it.unitPrice.amount, strike: true)])])),
        ]),
        if (it.substitute != null) ...[
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider2()),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ProdThumb(name: it.substitute!.name, seed: it.id + 1),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(it.substitute!.name, style: T.h3(c.tx, size: 15).copyWith(height: 1.45)),
              const SizedBox(height: 2),
              Row(children: [const STag('بديل مقترح', kind: 'soft'), const SizedBox(width: 8), Mny(it.substitute!.unitPrice.amount)]),
              if ((it.substituteDifference?.amount ?? 0) != 0) Text('${it.substituteDifference!.amount > 0 ? '+' : '-'} ${fmtMinor(it.substituteDifference!.amount.abs())} عن الأصلي', style: TextStyle(fontFamily: Fonts.ui, fontSize: 14, fontWeight: FontWeight.w600, color: c.amberInk)),
            ])),
          ]),
        ],
      ]);
    }
    return Row(children: [
      ProdThumb(name: it.name, seed: it.id),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(it.name, style: T.h3(c.tx, size: 15).copyWith(height: 1.45)),
        if ((it.note ?? '').isNotEmpty) Text(it.note!, style: T.sm(c.tx2)),
        Padding(padding: const EdgeInsets.only(top: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Num('× ${it.qty}', style: T.sm(c.tx2)), Mny(it.lineTotal.amount)])),
      ])),
    ]);
  }

  void _rejectSheet(BuildContext context, OfferController ctl) {
    var reason = 'السعر مرتفع';
    showSheet(context, title: 'رفض العرض؟', body: StatefulBuilder(builder: (ctx, set) {
      final c = ctx.sc;
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('سيُلغى الطلب ولن يتم تحصيل أي مبلغ. هل تريد إخبارنا بالسبب؟', style: T.sm(c.tx2)),
        const SizedBox(height: 16),
        Wrap(spacing: 8, runSpacing: 8, children: [for (final r in const ['السعر مرتفع', 'غيّرت رأيي', 'البديل لا يناسبني', 'سبب آخر']) SChip(r, on: reason == r, onTap: () => set(() => reason = r))]),
      ]);
    }), foot: [
      SBtn('نعم، ارفض وألغِ الطلب', kind: BtnKind.danger, full: true, onTap: () async {
        Get.back();
        await ctl.reject(reason: reason);
        if (ctl.viewState.value == OfferViewState.rejected) {
          showToast('رُفض العرض وأُلغي الطلب');
          Get.offNamed('/order', arguments: {'order_id': ctl.orderId});
        }
      }),
      SBtn('رجوع للعرض', kind: BtnKind.ghost, full: true, onTap: () => Get.back()),
    ]);
  }
}

class OfferApprovedScreen extends StatefulWidget {
  const OfferApprovedScreen({super.key});
  @override
  State<OfferApprovedScreen> createState() => _OfferApprovedScreenState();
}

class _OfferApprovedScreenState extends State<OfferApprovedScreen> {
  final int id = RouteArgs.readOrderId() ?? 0;
  OrderModel? o;
  @override
  void initState() {
    super.initState();
    backend.order(id).then((r) => r.fold((_) {}, (v) => mounted ? setState(() => o = v) : null));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final cash = o?.isCash ?? false;
    return Page2(
      center: true,
      body: Column(mainAxisSize: MainAxisSize.min, children: [
        const Ill('done', width: 190),
        const SizedBox(height: 24),
        Text('تمت الموافقة', style: T.d2(c.tx)),
        const SizedBox(height: 8),
        Text(cash ? 'ستدفع نقدًا عند التسليم. المكتبة بدأت تجهيز طلبك.' : 'بانتظار أن تقبل المكتبة الطلب وتفتح لك الدفع. سنُعلمك فور ذلك.', textAlign: TextAlign.center, style: T.bd(c.tx2)),
      ]),
      foot: Foot(child: SBtn('عرض الطلب', full: true, onTap: () {
        Get.until((r) => r.settings.name == '/orders' || r.settings.name == '/home' || r.isFirst);
        Get.toNamed('/order', arguments: {'order_id': id});
      })),
    );
  }
}

// ------------------------------------------------------------------ payment

class PayScreen extends StatefulWidget {
  const PayScreen({super.key});
  @override
  State<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends State<PayScreen> {
  final int id = RouteArgs.readOrderId() ?? 0;
  OrderModel? o;
  Failure? f;
  Timer? t;

  @override
  void initState() {
    super.initState();
    _load();
    t = Timer.periodic(const Duration(seconds: 10), (_) => _load());
  }

  @override
  void dispose() {
    t?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final r = await backend.order(id);
    if (!mounted) return;
    r.fold((e) => setState(() => f = e), (v) => setState(() {
          o = v;
          f = null;
        }));
  }

  Widget _gateway(BuildContext context, OrderModel o) {
    final c = context.sc;
    final g = o.gateway;
    if (g == null) return const Note('warn', text: 'لم تُفتح بيانات التحويل بعد.');
    return Card2(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(color: c.hero, borderRadius: BorderRadius.circular(14)), child: Center(child: SIcon('bank', size: 22, color: c.onHero))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(g.name, style: T.h3(c.tx, size: 15.5)), if ((g.holder ?? '').isNotEmpty) Text('اسم صاحب الحساب: ${g.holder}', style: T.sm(c.tx2))])),
        if ((g.qrUrl ?? '').isNotEmpty) Container(width: 64, height: 64, padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: c.sf, borderRadius: BorderRadius.circular(12), border: Border.all(color: c.ln)), child: Image.network(g.qrUrl!, fit: BoxFit.contain, errorBuilder: (_, __, ___) => SIcon('qr', size: 28, color: c.tx3))),
      ]),
      const SizedBox(height: 16),
      Panel(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('رقم الحساب', style: T.cap(c.tx2)), Text(g.accountNumber ?? '—', textDirection: TextDirection.ltr, style: TextStyle(fontFamily: Fonts.ui, fontSize: 19, fontWeight: FontWeight.w700, letterSpacing: .8, color: c.tx))]),
        SBtn('نسخ', kind: BtnKind.sec, size: BtnSize.xs, icon: 'copy', onTap: () {
          Clipboard.setData(ClipboardData(text: g.accountNumber ?? ''));
          showToast('تم النسخ', icon: 'copy');
        }),
      ])),
    ]));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final x = o;
    if (x == null) return Page2(top: const TopBar(title: 'الدفع بالتحويل'), center: true, body: f == null ? const Skel(h: 220, r: 20) : EmptyState(ill: 'offline', title: 'تعذّر تحميل الدفع', text: failureText(f!), cta: SBtn('أعد المحاولة', full: true, onTap: _load)));
    final k = x.statusKey;
    if (x.isCash) {
      return Page2(top: const TopBar(title: 'الدفع نقدًا'), body: Column(children: [
        const SizedBox(height: 20),
        const Ill('bag', width: 170),
        const SizedBox(height: 16),
        Text('الدفع نقدًا عند التسليم', textAlign: TextAlign.center, style: T.d2(c.tx)),
        const SizedBox(height: 8),
        Text('جهّز المبلغ للسائق عند وصول طلبك. لا حاجة لرفع أي إشعار.', textAlign: TextAlign.center, style: T.bd(c.tx2)),
        const SizedBox(height: 24),
        HeroBox(child: Column(children: [Text('ادفع للسائق', style: T.cap(c.onHero.withValues(alpha: .75))), Mny(x.total.amount, size: 40, color: c.onHero)])),
      ]));
    }
    if (k == 'payment_review') {
      return Page2(top: const TopBar(title: 'الدفع بالتحويل'), body: Column(children: [
        const SizedBox(height: 10),
        const Ill('wait', width: 190),
        const SizedBox(height: 16),
        Text('نراجع إشعارك', textAlign: TextAlign.center, style: T.d2(c.tx)),
        const SizedBox(height: 8),
        Text('وصل إشعار التحويل. سنُعلمك فور اعتماد الدفع أو إن احتجنا لتصحيح.', textAlign: TextAlign.center, style: T.bd(c.tx2)),
        const SizedBox(height: 24),
        Card2(child: Row(children: [
          Container(width: 64, height: 64, decoration: BoxDecoration(color: c.plumSoft, borderRadius: BorderRadius.circular(14)), clipBehavior: Clip.antiAlias, child: (x.receipt?.url ?? '').isNotEmpty && (x.receipt!.mime.startsWith('image')) ? Image.network(x.receipt!.url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Center(child: SIcon('image', size: 26, color: c.plumInk))) : Center(child: SIcon('image', size: 26, color: c.plumInk))),
          const SizedBox(width: 12),
          Expanded(child: Text('إشعار التحويل', style: T.h3(c.tx, size: 15))),
          const StatusPill('', label: 'قيد المراجعة', tone: 'wait'),
        ])),
        const SizedBox(height: 16),
        Text('لا يمكن تعديل الإشعار أثناء المراجعة.', style: T.sm(c.tx2)),
      ]));
    }
    if (['preparing', 'ready_for_delivery', 'accepted', 'picked_up', 'on_the_way', 'arrived', 'delivered'].contains(k)) {
      return Page2(center: true, body: Column(mainAxisSize: MainAxisSize.min, children: [const Ill('done', width: 190), const SizedBox(height: 24), Text('تم اعتماد الدفع', style: T.d2(c.tx)), const SizedBox(height: 8), Text('شكرًا لك. المكتبة تجهّز طلبك الآن.', style: T.bd(c.tx2))]), foot: Foot(child: SBtn('عرض الطلب', full: true, onTap: () => Get.offNamed('/order', arguments: {'order_id': x.id}))));
    }
    if (k == 'awaiting_payment') {
      final corr = (x.reviewNote ?? '').trim().isNotEmpty;
      return Page2(
        top: const TopBar(title: 'الدفع بالتحويل'),
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (corr) ...[Note('warn', icon: 'alert', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('طلبت المكتبة تصحيح الإشعار', style: TextStyle(fontWeight: FontWeight.w700)), Text('«${x.reviewNote}»')])), const SizedBox(height: 24)],
          HeroBox(child: Column(children: [Text('المبلغ المطلوب تحويله', style: T.cap(c.onHero.withValues(alpha: .75))), Mny(x.total.amount, size: 42, color: c.onHero), Text('طلب ${x.code}', style: T.sm(c.onHero.withValues(alpha: .8)))])),
          const SizedBox(height: 24),
          _gateway(context, x),
          const SizedBox(height: 24),
          for (final (i, s) in [('حوّل المبلغ من تطبيق البنك أو المحفظة', 'المبلغ كما هو، بدون زيادة أو نقص.'), ('صوّر إشعار التحويل', 'صورة واضحة أو ملف PDF.'), ('ارفعه هنا', 'تراجعه المكتبة وتعتمد الدفع.')].indexed)
            Padding(padding: EdgeInsets.only(top: i == 0 ? 0 : 16), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 30, height: 30, decoration: BoxDecoration(color: c.plumSoft, shape: BoxShape.circle), alignment: Alignment.center, child: Text('${i + 1}', style: TextStyle(fontFamily: Fonts.dis, fontWeight: FontWeight.w700, fontSize: 15, color: c.plumInk))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(s.$1, style: T.h3(c.tx, size: 15)), Text(s.$2, style: T.sm(c.tx2))])),
            ])),
        ]),
        foot: FootBar(child: SBtn(corr ? 'أرسل إشعارًا جديدًا' : 'ارفع إشعار التحويل', icon: 'upload', full: true, onTap: () async {
          await Get.toNamed('/pay/upload', arguments: {'order_id': x.id});
          _load();
        })),
      );
    }
    // pending (أو awaiting_pricing/priced): الدفع لم يُفتح بعد
    return Page2(top: const TopBar(title: 'الدفع بالتحويل'), center: true, body: Column(mainAxisSize: MainAxisSize.min, children: [
      const Ill('wait', width: 190),
      const SizedBox(height: 16),
      Text('الدفع لم يُفتح بعد', textAlign: TextAlign.center, style: T.d2(c.tx)),
      const SizedBox(height: 8),
      Text('وافقت على السعر. بانتظار قبول المكتبة للطلب، وعندها تظهر بيانات التحويل هنا تلقائيًا.', textAlign: TextAlign.center, style: T.bd(c.tx2)),
      const SizedBox(height: 24),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [const LiveDot(), const SizedBox(width: 10), Text('تُحدَّث الصفحة تلقائيًا', style: T.sm(c.tx2))]),
    ]));
  }
}

class PayUploadScreen extends StatefulWidget {
  const PayUploadScreen({super.key});
  @override
  State<PayUploadScreen> createState() => _PayUploadScreenState();
}

class _PayUploadScreenState extends State<PayUploadScreen> {
  late final TransferPaymentController ctl;
  Worker? _w;
  @override
  void initState() {
    super.initState();
    TransferPaymentBinding().dependencies();
    ctl = Get.find<TransferPaymentController>();
    _w = ever(ctl.justSubmitted, (v) {
      if (v == true) {
        showToast('أُرسل الإشعار للمراجعة');
        Get.back();
      }
    });
  }

  @override
  void dispose() {
    _w?.dispose();
    super.dispose();
  }

  Future<void> _camera() async {
    final x = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 85, maxWidth: 2400);
    if (x == null) return;
    final b = await x.readAsBytes();
    await ctl.attachBytes(x.name, b.length, b);
  }

  void _pick(BuildContext context) {
    showSheet(context, title: 'إشعار التحويل', body: Column(children: [
      LiTile('camera', 'التقط صورة', sub: 'بالكاميرا', first: true, onTap: () {
        Get.back();
        _camera();
      }),
      LiTile('file', 'اختر ملفًا', sub: 'من المعرض أو الملفات', onTap: () {
        Get.back();
        ctl.pickReceipt();
      }),
    ]));
  }

  String _rej(FileRejection r) => switch (r) {
        FileRejection.tooLarge => 'الملف أكبر من ${(ctl.transfer.value?.receiptMaxBytes ?? 10485760) ~/ 1048576} ميغابايت. اختر صورة أو ملفًا أصغر.',
        FileRejection.unsupportedType => 'نوع الملف غير مدعوم. استخدم JPEG أو PNG أو WebP أو PDF.',
        FileRejection.empty => 'الملف فارغ.',
      };

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Obx(() {
      final r = ctl.receipt.value;
      final rej = ctl.rejection.value;
      final sending = ctl.submitting.value;
      final fail = ctl.submitFailure.value;
      return Page2(
        top: const TopBar(title: 'الدفع بالتحويل'),
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('أرسل إشعار التحويل', style: T.h1(c.tx)),
          const SizedBox(height: 8),
          Text('JPEG أو PNG أو WebP أو PDF، حتى ${(ctl.transfer.value?.receiptMaxBytes ?? 10485760) ~/ 1048576} ميغابايت.', style: T.sm(c.tx2)),
          const SizedBox(height: 24),
          if (r == null) DropZone(icon: 'camera', title: 'التقط صورة أو اختر ملفًا', sub: 'من المعرض أو الملفات', onTap: () => _pick(context)),
          if (rej != null) ...[const SizedBox(height: 16), FileRow(name: 'الملف المختار', ext: 'PDF', state: 'bad', error: _rej(rej), actionLabel: 'استبدل', onAction: () => _pick(context))],
          if (r != null && !sending) Card2(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(height: 210, decoration: BoxDecoration(color: c.sf2, borderRadius: BorderRadius.circular(Rad.m)), clipBehavior: Clip.antiAlias, child: r.mime.startsWith('image') ? Image.memory(r.bytes, fit: BoxFit.contain) : Column(mainAxisAlignment: MainAxisAlignment.center, children: [SIcon('file', size: 44, color: c.tx2), const SizedBox(height: 6), Text(r.name, textDirection: TextDirection.ltr, style: T.sm(c.tx2))])),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('${(r.size / 1048576).toStringAsFixed(1)} MB', textDirection: TextDirection.ltr, style: T.sm(c.tx2)), Row(children: [SBtn('استبدال', kind: BtnKind.ghost, size: BtnSize.xs, onTap: () => _pick(context)), SBtn('حذف', kind: BtnKind.ghost, size: BtnSize.xs, onTap: ctl.removeReceipt)])]),
          ])),
          if (r != null && sending) Card2(child: Row(children: [
            Container(width: 40, height: 48, decoration: BoxDecoration(color: c.plumSoft, borderRadius: BorderRadius.circular(8)), child: Center(child: SIcon('image', size: 22, color: c.plumInk))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(r.name, textDirection: TextDirection.ltr, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: Fonts.ui, fontWeight: FontWeight.w600, color: c.tx)), const SizedBox(height: 8), ProgressBar(ctl.uploadProgress.value)])),
          ])),
          if (fail != null) ...[const SizedBox(height: 16), Note('err', text: ctl.stateChanged.value ? 'تغيّرت حالة الطلب. حدّث الصفحة.' : failureText(fail))],
          const SizedBox(height: 16),
          const Note('plum', text: 'رفع الإشعار لا يعني اعتماد الدفع. تراجعه المكتبة أولًا.'),
        ]),
        foot: FootBar(child: SBtn(sending ? 'جارٍ الإرسال' : 'أرسل الإشعار', full: true, loading: sending, disabled: !ctl.canSubmit && !sending, onTap: ctl.submit)),
      );
    });
  }
}
