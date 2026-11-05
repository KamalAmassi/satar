import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/core/config/remote_config_repository.dart';
import 'package:project/core/design/icons.dart';
import 'package:project/core/design/illustrations.dart';
import 'package:project/core/design/shell.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/design/widgets.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/uploads/upload_repository.dart';
import 'package:project/customer/features/checkout/presentation/controllers/checkout_controller.dart';
import 'package:project/customer/features/library_offer/domain/entities/library_offer.dart';
import 'package:project/customer/features/library_offer/presentation/bindings/offer_binding.dart';
import 'package:project/customer/features/library_offer/presentation/controllers/offer_controller.dart';
import 'package:project/customer/features/payment/presentation/bindings/transfer_payment_binding.dart';
import 'package:project/customer/features/payment/presentation/controllers/transfer_payment_controller.dart';
import 'package:project/customer/features/orders/presentation/orders_page.dart';
import 'package:project/core/data/models.dart';
import 'package:project/core/widgets/common_widgets.dart';

OfferController offerCtl() {
  OfferBinding().dependencies();
  return Get.find<OfferController>();
}

class OfferScreen extends StatefulWidget {
  const OfferScreen({super.key});
  @override
  State<OfferScreen> createState() => _OfferScreenState();
}

class _OfferScreenState extends State<OfferScreen> {
  late final ctl = offerCtl();

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Obx(() {
      final o = ctl.offer.value;
      final st = ctl.viewState.value;
      if (st == OfferViewState.loading && o == null) return Page2(top: const TopBar(title: 'عرض المكتبة'), body: const Column(children: [Skel(h: 180, r: 20), SizedBox(height: 16), Skel(h: 220, r: 20)]));
      if (st == OfferViewState.failed && o == null) {
        return Page2(top: const TopBar(title: 'عرض المكتبة'), center: true, body: EmptyState(ill: 'offline', title: 'تعذّر تحميل العرض', text: ctl.failure.value == null ? '' : failureText(ctl.failure.value!), cta: SBtn('أعد المحاولة', full: true, onTap: ctl.load)));
      }
      if (st == OfferViewState.approved) {
        WidgetsBinding.instance.addPostFrameCallback((_) => Get.offNamed('/offer/approved', arguments: {'order_id': ctl.orderId}));
      }
      if (o == null) return Page2(top: const TopBar(title: 'عرض المكتبة'), center: true, body: const EmptyState(ill: 'books', title: 'لا يوجد عرض بعد', text: 'تراجع المكتبة طلبك وتجهّز العرض قريبًا.'));
      final total = o.total.amount;
      final pending = st == OfferViewState.open;
      return Page2(
        top: TopBar(title: 'عرض المكتبة · #${o.orderId}', right: SIconBtn('refresh', size: 20, onTap: ctl.load)),
        onRefresh: ctl.load,
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (st == OfferViewState.changed) ...[
            const Note('warn', text: 'هذا العرض قديم. أرسلت المكتبة عرضًا أحدث.'),
            const SizedBox(height: 12),
            SBtn('راجع العرض الجديد', full: true, onTap: ctl.load),
            const SizedBox(height: 16),
          ],
          if (st == OfferViewState.expired) ...[
            const Note('err', text: 'انتهت صلاحية هذا العرض. تواصل مع المكتبة لإعادة التفعيل.'),
            const SizedBox(height: 16),
          ],
          if (pending) ...[
            Note('cream', icon: 'clock', child: Row(children: [const Text('العرض صالح لمدة '), CountdownText(ctl.remaining.value.inSeconds, style: TextStyle(fontFamily: Fonts.ui, fontWeight: FontWeight.w700, color: c.tx))])),
            const SizedBox(height: 16),
          ],
          Card2(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('تغييرات البنود', style: T.h3(c.tx)),
            const SizedBox(height: 12),
            for (final it in o.items) ...[
              _OfferItemRow(it),
              const SizedBox(height: 12),
            ],
          ])),
          const SizedBox(height: 16),
          PriceBox(
            rows: [
              ('مجموع البنود', Mny(o.itemsTotal.amount)),
              ('التوصيل', Mny(o.deliveryFee.amount)),
            ],
            totalMinor: total,
            totalLabel: 'الإجمالي النهائي',
          ),
          const SizedBox(height: 16),
          if (pending)
            Column(children: [
              if (o.hasSubstitutions)
                Row(children: [
                  SCheck(ctl.substitutionsAccepted.value, onTap: () => ctl.substitutionsAccepted.value = !ctl.substitutionsAccepted.value),
                  const SizedBox(width: 12),
                  Expanded(child: Text('أوافق على البدائل المقترحة وتعديل الكميات', style: T.sm(c.tx, w: FontWeight.w600))),
                ]),
              const SizedBox(height: 16),
              SBtn('أوافق على السعر النهائي', full: true, loading: ctl.acting.value, disabled: !ctl.canApprove, onTap: ctl.approve),
              const SizedBox(height: 8),
              SBtn('أرفض العرض', kind: BtnKind.ghost, full: true, disabled: ctl.acting.value, onTap: () => _rejectSheet(context, ctl)),
            ]),
        ]),
      );
    });
  }
}

class _OfferItemRow extends StatelessWidget {
  const _OfferItemRow(this.it);
  final LibraryOfferItem it;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final sub = it.substitute;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: c.sf2, borderRadius: BorderRadius.circular(Rad.m)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(it.name, style: T.h3(c.tx, size: 15))),
          if (!it.available) const STag('غير متوفر', kind: 'err') else if (sub != null) const STag('بديل مقترح', kind: 'soft'),
        ]),
        const SizedBox(height: 4),
        Text('الكمية: ${it.qty}', style: T.sm(c.tx2)),
        if (sub != null) ...[
          const SizedBox(height: 8),
          Text('البديل: ${sub.name}', style: T.sm(c.plumInk, w: FontWeight.w600)),
          Text('السعر: ${fmtMinor(sub.unitPrice.amount)}', style: T.cap(c.tx2)),
        ],
      ]),
    );
  }
}

void _rejectSheet(BuildContext context, OfferController ctl) {
  showSheet(context, title: 'رفض العرض؟', body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    const Note('err', text: 'رفض العرض يلغي الطلب. إذا كنت دفعت مبلغًا تواصل مع المكتبة.'),
  ]), foot: [
    SBtn('نعم، أرفض العرض', kind: BtnKind.danger, full: true, onTap: () async {
      Get.back();
      await ctl.reject();
    }),
    SBtn('تراجع', kind: BtnKind.ghost, full: true, onTap: () => Get.back()),
  ]);
}

class OfferApprovedScreen extends StatelessWidget {
  const OfferApprovedScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final a = Get.arguments;
    final id = a is Map ? (a['order_id'] as int? ?? 0) : 0;
    return Page2(
      center: true,
      body: Column(mainAxisSize: MainAxisSize.min, children: [
        const Ill('done', width: 200),
        const SizedBox(height: 24),
        Text('تمت الموافقة على العرض', style: T.d2(c.tx)),
        const SizedBox(height: 8),
        Text('تتابع المكتبة تجهيز طلبك. يمكنك المتابعة من شاشة الطلب.', textAlign: TextAlign.center, style: T.bd(c.tx2)),
      ]),
      foot: Foot(child: SBtn('عرض الطلب', full: true, onTap: () {
        Get.offAllNamed('/home');
        if (id > 0) Get.toNamed('/order', arguments: {'order_id': id});
      })),
    );
  }
}

TransferPaymentController payCtl() {
  TransferPaymentBinding().dependencies();
  return Get.find<TransferPaymentController>();
}

class PayScreen extends StatefulWidget {
  const PayScreen({super.key});
  @override
  State<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends State<PayScreen> {
  late final ctl = payCtl();

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Obx(() {
      final o = ctl.order.value;
      if (ctl.loading.value && o == null) return Page2(top: const TopBar(title: 'الدفع بالتحويل'), body: const Column(children: [Skel(h: 160, r: 20), SizedBox(height: 16), Skel(h: 200, r: 20)]));
      if (o == null) {
        return Page2(top: const TopBar(title: 'الدفع بالتحويل'), center: true, body: EmptyState(ill: 'offline', title: 'تعذّر تحميل بيانات الدفع', text: ctl.loadFailure.value == null ? '' : failureText(ctl.loadFailure.value!), cta: SBtn('أعد المحاولة', full: true, onTap: ctl.load)));
      }
      final banks = ctl.transfer.value?.accounts ?? const [];
      return Page2(
        top: const TopBar(title: 'بيانات التحويل'),
        onRefresh: ctl.load,
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          HeroBox(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('المبلغ المطلوب', style: T.cap(c.onHero)),
            const SizedBox(height: 4),
            Mny(o.total.amount, size: 28, color: c.onHero),
            const SizedBox(height: 8),
            Text('حوّل المبلغ إلى أحد الحسابات التالية ثم ارفع صورة الإشعار.', style: T.sm(c.onHero)),
          ])),
          const SizedBox(height: 16),
          Text('حسابات المكتبة', style: T.h2(c.tx, size: 18)),
          const SizedBox(height: 8),
          for (final b in banks) ...[
            Card2(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(b.provider, style: T.h3(c.tx, size: 15.5)), SBtn('نسخ', kind: BtnKind.sec, size: BtnSize.xs, icon: 'copy', onTap: () {
                Clipboard.setData(ClipboardData(text: b.number));
                showToast('نسخ الحساب');
              })]),
              const SizedBox(height: 4),
              Text('اسم الحساب: ${b.holder}', style: T.sm(c.tx2)),
              Text('رقم الحساب: ${b.number}', style: T.sm(c.tx, w: FontWeight.w600)),
              if (b.iban != null) Text('IBAN: ${b.iban}', style: T.cap(c.tx2)),
            ])),
            const SizedBox(height: 12),
          ],
        ]),
        foot: FootBar(child: SBtn('ارفع إشعار التحويل', icon: 'upload', full: true, onTap: () => Get.toNamed('/pay/upload', arguments: {'order_id': ctl.orderId}))),
      );
    });
  }
}

class PayUploadScreen extends StatefulWidget {
  const PayUploadScreen({super.key});
  @override
  State<PayUploadScreen> createState() => _PayUploadScreenState();
}

class _PayUploadScreenState extends State<PayUploadScreen> {
  late final ctl = payCtl();
  Worker? _done;

  @override
  void initState() {
    super.initState();
    _done = ever<bool>(ctl.justSubmitted, (v) {
      if (!v) return;
      Get.offAllNamed('/home');
      Get.toNamed('/order', arguments: {'order_id': ctl.orderId});
    });
  }

  @override
  void dispose() {
    _done?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Obx(() {
      final r = ctl.receipt.value;
      final sending = ctl.submitting.value;
      return Page2(
        top: const TopBar(title: 'رفع إشعار التحويل'),
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Card2(
            onTap: sending ? null : ctl.pickReceipt,
            child: Column(children: [
              if (sending) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 12),
                Text('جارٍ رفع الصورة…', style: T.sm(c.tx2)),
              ] else if (r != null) ...[
                SIcon('checkC', size: 40, color: c.okInk),
                const SizedBox(height: 8),
                Text(r.name, style: T.h3(c.tx)),
                Text('اضغط للتغيير', style: T.cap(c.tx2)),
              ] else ...[
                SIcon('upload', size: 36, color: c.plumInk),
                const SizedBox(height: 8),
                Text('اختر صورة إشعار التحويل', style: T.h3(c.tx)),
                Text('صورة من تطبيق البنك أو المحفظة', style: T.sm(c.tx2)),
              ],
            ]),
          ),
          if (ctl.rejection.value != null) ...[const SizedBox(height: 12), const Note('err', text: 'الملف غير مقبول (الحجم أو النوع). اختر صورة أخرى.')],
          if (ctl.submitFailure.value != null) ...[const SizedBox(height: 12), Note('err', text: failureText(ctl.submitFailure.value!))],
          const SizedBox(height: 16),
          const Note('plum', text: 'تراجع المكتبة الإشعار وتعتمد الدفع لمتابعة التوصيل.'),
        ]),
        foot: FootBar(child: SBtn(sending ? 'جارٍ الإرسال' : 'أرسل الإشعار', full: true, loading: sending, disabled: !ctl.canSubmit, onTap: ctl.submit)),
      );
    });
  }
}
