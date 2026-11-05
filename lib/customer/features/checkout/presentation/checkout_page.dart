import 'dart:async';

import 'package:flutter/material.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/widgets/success_badge.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:project/core/config/remote_config_repository.dart';
import 'package:project/core/design/icons.dart';
import 'package:project/core/design/illustrations.dart';
import 'package0/core/design/shell.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/design/widgets.dart';
import 'package:project/core/errors/api_error_codes.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/utils/haptics.dart';
import 'package:project/core/routes/route_nav.dart';
import 'package:project/customer/features/checkout/domain/entities/checkout_address.dart';
import 'package:project/customer/features/checkout/domain/entities/checkout_details.dart';
import 'package:project/customer/features/checkout/domain/entities/pickup_point.dart';
import 'package:project/customer/features/checkout/presentation/bindings/checkout_binding.dart';
import 'package:project/customer/features/checkout/presentation/controllers/checkout_controller.dart';
import 'package:project/customer/features/cart/presentation/controllers/cart_controller.dart';
import 'package:project/core/data/models.dart';
import 'package:project/core/widgets/common_widgets.dart';

const kCheckoutFlow = {'/checkout', '/checkout/quote', '/order-placed', '/order-uncertain', '/cart', '/print/upload', '/print/specs', '/print/review'};

CheckoutController checkoutCtl() {
  CheckoutBinding().dependencies();
  return Get.find<CheckoutController>();
}

extension AddressTitle on CheckoutAddress {
  String get title => (label ?? '').isEmpty ? 'عنوان' : label!;
}

String payTitle(String m) => m == PaymentMethod.cash ? 'الدفع نقدًا عند التسليم' : 'تحويل بنكي';
String paySub(String m) => m == PaymentMethod.cash ? 'تدفع للسائق عند استلام الطلب' : 'بعد موافقتك على السعر، تحوّل وترفع الإشعار';
String payIcon(String m) => m == PaymentMethod.cash ? 'cash' : 'bank';

bool pointInZone(double lat, double lng) {
  final zones = Get.find<RemoteConfigRepository>().current?.zones ?? const [];
  if (zones.isEmpty) return true;
  for (final z in zones) {
    var inside = false;
    for (var i = 0, j = z.length - 1; i < z.length; j = i++) {
      final a = z[i], b = z[j];
      if (((a.lat > lat) != (b.lat > lat)) && (lng < (b.lng - a.lng) * (lat - a.lat) / (b.lat - a.lat) + a.lng)) inside = !inside;
    }
    if (inside) return true;
  }
  return false;
}

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late final ctl = checkoutCtl();
  final recName = TextEditingController();
  final recPhone = TextEditingController();
  final dnotes = TextEditingController();
  final lnotes = TextEditingController();
  final coupon = TextEditingController();
  bool recipient = false;
  bool couponOpen = false;
  bool busy = false;

  @override
  void initState() {
    super.initState();
    lnotes.text = cartCtl.note.value;
    ctl.start().then((_) {
      if (ctl.details.value.paymentMethod == null) {
        final m = ctl.availablePaymentMethods;
        if (m.isNotEmpty) ctl.setPaymentMethod(m.first);
      }
      if (cartCtl.substitutionPreference.value == null && cartCtl.products.isNotEmpty) {
        cartCtl.setSubstitutionPreference('ask_before_replacing');
      }
    });
  }

  @override
  void dispose() {
    for (final t in [recName, recPhone, dnotes, lnotes, coupon]) {
      t.dispose();
    }
    super.dispose();
  }

  Future<void> _review() async {
    if (busy) return;
    setState(() => busy = true);
    await ctl.requestQuote();
    if (!mounted) return;
    setState(() => busy = false);
    final f = ctl.quoteFailure.value;
    if (ctl.quoteState.value == QuoteState.ready) {
      Get.toNamed('/checkout/quote');
      return;
    }
    if (f == null) {
      showToast('أكمل العنوان وطريقة الدفع أولًا', icon: 'alertC');
      return;
    }
    switch (f.code) {
      case ApiErrorCodes.outOfStock:
        Get.toNamed('/cart');
      case ApiErrorCodes.vendorClosed:
        showDlg(context, kind: 'warn', icon: 'clock', title: 'المكتبة مغلقة الآن', text: 'لا يمكن إرسال الطلب حاليًا. يمكنك جدولة التوصيل لوقت لاحق.', foot: [
          SBtn('جدولة التوصيل', full: true, onTap: () {
            Get.back();
            _scheduleSheet();
          }),
          SBtn('حسنًا', kind: BtnKind.ghost, full: true, onTap: () => Get.back()),
        ]);
      case ApiErrorCodes.slotFull:
        showToast('هذه الفترة ممتلئة. اختر فترة أخرى.', icon: 'alertC');
        _scheduleSheet(slotFull: true);
      default:
        if (f is ValidationFailure && f.fieldErrors.keys.any((k) => k.startsWith('print_items'))) {
          showToast('صحّح مواصفات الطباعة', icon: 'alertC');
          Get.toNamed('/print/specs');
        } else if (f.code != ApiErrorCodes.outOfZone) {
          showToast(failureText(f), icon: 'alertC');
        }
    }
  }

  void _addressSheet() {
    showSheet(context, title: 'عنوان التوصيل', body: Obx(() => Column(children: [
          for (final a in ctl.addresses) ...[
            OptCard(on: ctl.details.value.addressId == a.id, icon: 'pin', title: a.title + (a.isDefault ? ' · الافتراضي' : ''), sub: a.details, onTap: () => ctl.selectAddress(a.id)),
            const SizedBox(height: 8),
          ],
        ])), foot: [
      SBtn('إضافة عنوان جديد', kind: BtnKind.sec, icon: 'plus', full: true, onTap: () async {
        Get.back();
        final id = await Get.toNamed('/address/form');
        await ctl.loadAddresses();
        if (id is int) ctl.selectAddress(id);
      }),
      SBtn('تأكيد', full: true, onTap: () => Get.back()),
    ]);
  }

  void _scheduleSheet({bool slotFull = false}) {
    final c = context.sc;
    DateTime? sel = ctl.details.value.scheduledFor;
    int day = 0;
    showSheet(context, title: 'وقت التوصيل', body: StatefulBuilder(builder: (ctx, set) {
      final base = DateTime.now().add(Duration(days: day));
      final windows = [10, 12, 14, 16, 18];
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        OptCard(on: sel == null, icon: 'zap', title: 'في أقرب وقت', sub: 'حسب توفر السائقين', onTap: () => set(() => sel = null)),
        const SizedBox(height: 8),
        OptCard(on: sel != null, icon: 'cal', title: 'جدولة التوصيل', sub: 'اختر يومًا وفترة', onTap: () => set(() => sel ??= DateTime(base.year, base.month, base.day, windows.first))),
        if (slotFull) ...[const SizedBox(height: 12), const Note('err', text: 'الفترة التي اخترتها ممتلئة. اختر فترة أخرى.')],
        if (sel != null) ...[
          const SizedBox(height: 16),
          Row(children: [
            for (final (i, l) in ['اليوم', 'غدًا', 'بعد غد'].indexed) ...[SChip(l, icon: i == 0 ? 'cal' : null, on: day == i, onTap: () => set(() {
                  day = i;
                  sel = null;
                })), const SizedBox(width: 8)],
          ]),
          const SizedBox(height: 16),
          GridView.count(crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 2, children: [
            for (final h in windows)
              () {
                final start = DateTime(base.year, base.month, base.day, h);
                final past = start.isBefore(DateTime.now());
                final on = sel != null && sel!.hour == h && sel!.day == start.day;
                return OptTile(compact: true, on: on, dis: past, label: '${h > 12 ? h - 12 : h} – ${(h + 2) > 12 ? h + 2 - 12 : h + 2}', onTap: () => set(() => sel = start));
              }(),
          ]),
        ],
      ]);
    }), foot: [
      SBtn('تأكيد الموعد', full: true, onTap: () {
        ctl.details.value = sel == null ? ctl.details.value.copyWith(clearSchedule: true) : ctl.details.value.copyWith(scheduledFor: sel);
        Get.back();
      }),
    ]);
    final _ = c;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Obx(() {
      cartCtl.revision.value;
      final d = ctl.details.value;
      final addr = ctl.addresses.firstWhereOrNull((a) => a.id == d.addressId);
      final oos = d.addressId != null && ctl.outOfZoneAddressIds.contains(d.addressId);
      final methods = ctl.availablePaymentMethods;
      final est = cartEstimate();
      return Page2(
        top: const TopBar(title: 'إتمام الطلب'),
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const StepsBar(step: 1, total: 2, labels: ['التسليم والدفع', 'مراجعة السعر']),
          const SizedBox(height: 6),
          Card2(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('عنوان التوصيل', style: T.h3(c.tx)), SBtn('تغيير', kind: BtnKind.ghost, size: BtnSize.xs, onTap: _addressSheet)]),
            const SizedBox(height: 16),
            if (ctl.addressesLoading.value)
              const Skel(h: 44)
            else if (addr == null)
              Column(children: [Text(ctl.addressesFailure.value != null ? failureText(ctl.addressesFailure.value!) : 'لا عناوين محفوظة بعد.', style: T.sm(c.tx2)), const SizedBox(height: 8), SBtn('إضافة عنوان', icon: 'plus', kind: BtnKind.sec, onTap: () async {
                    final id = await Get.toNamed('/address/form');
                    await ctl.loadAddresses();
                    if (id is int) ctl.selectAddress(id);
                  })])
            else
              Row(children: [
                Container(width: 44, height: 44, decoration: BoxDecoration(color: c.hero, borderRadius: BorderRadius.circular(14)), child: Center(child: SIcon('pin', size: 22, color: c.onHero))),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(addr.title, style: T.h3(c.tx, size: 15.5)), Text(addr.details ?? '', style: T.sm(c.tx2))])),
              ]),
            if (oos) ...[const SizedBox(height: 12), const Note('err', title: 'هذا العنوان خارج منطقة الخدمة.', text: 'اختر عنوانًا آخر أو أضف عنوانًا داخل المنطقة.')],
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('الاستلام لشخص آخر', style: T.sm(c.tx)), SSwitch(recipient, onChanged: (v) {
                  setState(() => recipient = v);
                  if (!v) {
                    ctl.setRecipientName('');
                    ctl.setRecipientPhone('');
                  }
                })]),
            if (recipient) ...[
              const SizedBox(height: 16),
              Fld(label: 'اسم المستلم', hint: 'الاسم', controller: recName, onChanged: ctl.setRecipientName),
              const SizedBox(height: 16),
              Fld(label: 'جوال المستلم', hint: '0599…', controller: recPhone, keyboard: TextInputType.phone, ltr: true, onChanged: ctl.setRecipientPhone, error: ctl.isRecipientPhoneValid ? null : 'رقم الجوال غير صحيح.', helper: 'للتنسيق عند التسليم فقط. رمز التسليم يبقى مع صاحب الحساب.'),
            ],
            const SizedBox(height: 16),
            Fld(label: 'وصف مكان التسليم', hint: 'بجانب الصيدلية، الطابق الثاني', controller: dnotes, optional: true, onChanged: ctl.setDeliveryNotes),
            const SizedBox(height: 8),
            LiTile('clock', 'وقت التوصيل', sub: d.scheduledFor == null ? 'في أقرب وقت' : '${dateLabel(d.scheduledFor)} · ${two(d.scheduledFor!.hour)}:00', onTap: _scheduleSheet),
          ])),
          const SizedBox(height: 24),
          Text('طريقة الدفع', style: T.h2(c.tx, size: 18)),
          const SizedBox(height: 8),
          if (methods.isEmpty)
            Skel(h: 64, r: 14)
          else
            for (final m in methods) ...[OptCard(on: d.paymentMethod == m, icon: payIcon(m), title: payTitle(m), sub: paySub(m), onTap: () => ctl.setPaymentMethod(m)), const SizedBox(height: 8)],
          if (d.paymentMethod == PaymentMethod.transfer) const Note('plum', text: 'لا تدفع الآن. بعد موافقتك على السعر النهائي تظهر لك بيانات التحويل. الدفع يتم عبر تطبيق البنك أو المحفظة خارج سطر.'),
          if (cartCtl.products.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('إن لم يتوفر منتج', style: T.h2(c.tx, size: 18)),
            const SizedBox(height: 8),
            for (final o in const [('ask_before_replacing', 'أستشيرني قبل الاستبدال', 'يُعرض البديل وفرق السعر لموافقتي'), ('remove_unavailable', 'احذف غير المتوفر', 'يُحذف من الطلب بدون بديل')]) ...[
              OptCard(on: cartCtl.substitutionPreference.value == o.$1, title: o.$2, sub: o.$3, onTap: () => cartCtl.setSubstitutionPreference(o.$1)),
              const SizedBox(height: 8),
            ],
          ],
          const SizedBox(height: 16),
          Fld(label: 'ملاحظة للمكتبة', hint: 'أي شيء تريد إضافته؟', controller: lnotes, optional: true, maxLines: 3, onChanged: cartCtl.setNote),
          const SizedBox(height: 8),
          LiTile('tag', 'لديك كود خصم؟', onTap: () => setState(() => couponOpen = !couponOpen)),
          if (couponOpen) Padding(padding: const EdgeInsets.only(bottom: 8), child: Fld(hint: 'أدخل الكود', controller: coupon, ltr: true, onChanged: (v) => ctl.details.value = ctl.details.value.copyWith(coupon: v))),
        ]),
        foot: FootBar(child: Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text('قبل التوصيل', style: T.cap(c.tx2)), Mny(est.products + est.printing, size: 20)]),
          const SizedBox(width: 16),
          Expanded(child: SBtn('راجع السعر', full: true, loading: busy, disabled: !ctl.canContinueFromDelivery || d.paymentMethod == null || ctl.quoteState.value == QuoteState.loading, onTap: _review)),
        ])),
      );
    });
  }
}

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});
  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  late final ctl = checkoutCtl();
  Worker? _w;
  bool dlgOpen = false;
  bool leaving = false;

  @override
  void initState() {
    super.initState();
    _w = ever(ctl.submitState, (s) {
      if (s == SubmitState.created) {
        leaveFlowTo('/order-placed', kCheckoutFlow);
      } else if (s == SubmitState.uncertain) {
        Get.offNamed('/order-uncertain');
      } else if (s == SubmitState.rejected) {
        Haptics.error();
      }
    });
  }

  @override
  void dispose() {
    _w?.dispose();
    super.dispose();
  }

  void _expiredDialog() {
    if (dlgOpen) return;
    dlgOpen = true;
    showDlg(context, kind: 'warn', icon: 'clock', title: 'انتهت صلاحية السعر', text: 'مرّت 10 دقائق على آخر تسعيرة. نحدّث السعر لك الآن، وقد يختلف قليلًا.', dismissible: false, foot: [
      SBtn('حدّث السعر', icon: 'refresh', full: true, onTap: () {
        Get.back();
        dlgOpen = false;
        ctl.requestQuote();
      }),
      SBtn('رجوع للسلة', kind: BtnKind.ghost, full: true, onTap: () {
        Get.back();
        dlgOpen = false;
        Get.until((r) => r.settings.name == '/cart' || r.isFirst);
      }),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Obx(() {
      final st = ctl.quoteState.value;
      final q = ctl.quote.value;
      if (st == QuoteState.expired || st == QuoteState.used) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (st == QuoteState.used) {
            if (!leaving) {
              leaving = true;
              Get.offNamed('/order-uncertain');
            }
          } else {
            _expiredDialog();
          }
        });
      }
      final d = ctl.details.value;
      final addr = ctl.addresses.firstWhereOrNull((a) => a.id == d.addressId);
      final sub = ctl.submitState.value == SubmitState.submitting;
      return Page2(
        top: const TopBar(title: 'مراجعة السعر'),
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const StepsBar(step: 2, total: 2, labels: ['التسليم والدفع', 'مراجعة السعر']),
          if (q == null)
            Column(children: [
              if (st == QuoteState.loading || st == QuoteState.idle) ...[const Skel(h: 56), const SizedBox(height: 16), const Skel(h: 220, r: 20)] else EmptyState(ill: 'offline', title: 'تعذّر تسعير الطلب', text: ctl.quoteFailure.value == null ? 'تحقق من بيانات الطلب ثم حاول مجددًا.' : failureText(ctl.quoteFailure.value!), cta: SBtn('أعد المحاولة', full: true, onTap: ctl.requestQuote)),
            ])
          else ...[
            if (ctl.needsPriceAcceptance.value)
              Note('warn', child: Text.rich(TextSpan(children: [const TextSpan(text: 'تغيّر السعر. ', style: TextStyle(fontWeight: FontWeight.w700)), TextSpan(text: 'كان ${fmtMinor(ctl.previousQuote.value?.total.amount ?? 0)} وأصبح ${fmtMinor(q.total.amount)}. وافق على السعر الجديد للمتابعة.')])))
            else if (ctl.paymentTermsChanged.value)
              const Note('warn', text: 'تغيّرت طريقة الدفع في التسعيرة. راجع التفاصيل قبل التأكيد.')
            else
              Note('cream', icon: 'clock', child: Row(children: [const Text('السعر صالح لمدة '), CountdownText(ctl.remaining.value.inSeconds, key: ValueKey(q.token), style: TextStyle(fontFamily: Fonts.ui, fontWeight: FontWeight.w700, color: c.onHero))])),
            const SizedBox(height: 16),
            Card2(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text('تفاصيل السعر', style: T.h3(c.tx)),
              const SizedBox(height: 8),
              for (final l in q.breakdown) KV(l.label, null, vWidget: l.amount.amount < 0 ? Text('- ${fmtMinor(-l.amount.amount)}', textDirection: TextDirection.ltr, style: TextStyle(fontFamily: Fonts.ui, fontWeight: FontWeight.w600, color: c.okInk)) : Mny(l.amount.amount)),
              KV('الإجمالي', null, total: true, vWidget: Mny(q.total.amount, size: 18)),
            ])),
            const SizedBox(height: 16),
            Panel(child: Column(children: [
              Row(children: [SIcon('pin', size: 20, color: c.tx), const SizedBox(width: 12), Expanded(child: Text(addr == null ? '' : '${addr.title} · ${addr.details ?? ''}', style: T.sm(c.tx)))]),
              const SizedBox(height: 12),
              Row(children: [SIcon(payIcon(d.paymentMethod ?? ''), size: 20, color: c.tx), const SizedBox(width: 12), Expanded(child: Text(payTitle(d.paymentMethod ?? ''), style: T.sm(c.tx))), SBtn('تغيير', kind: BtnKind.ghost, size: BtnSize.xs, onTap: () => Get.back())]),
            ])),
            const SizedBox(height: 16),
            const Note('plum', text: 'قد تعدّل المكتبة السعر عند تجهيز الطلب (مثلًا لعدم توفر منتج). لن يُعتمد أي تعديل أو دفع بدون موافقتك.'),
            if (ctl.submitState.value == SubmitState.rejected && ctl.submitFailure.value != null) ...[const SizedBox(height: 16), Note('err', text: failureText(ctl.submitFailure.value!))],
          ],
        ]),
        foot: FootBar(child: Column(mainAxisSize: MainAxisSize.min, children: [
          SBtn(
            q == null ? 'أكّد الطلب' : (ctl.needsPriceAcceptance.value ? 'أوافق على السعر الجديد · ${(q.total.amount / 100).toStringAsFixed(2)} ₪' : 'أكّد الطلب · ${(q.total.amount / 100).toStringAsFixed(2)} ₪'),
            full: true,
            loading: sub,
            hapticOnPress: false,
            disabled: q == null || (!ctl.needsPriceAcceptance.value && !ctl.canConfirm),
            onTap: () {
              if (ctl.needsPriceAcceptance.value) {
                ctl.acceptNewPrice();
              } else {
                ctl.confirmOrder();
              }
            },
          ),
          const SizedBox(height: 6),
          Text('بالتأكيد يُرسل طلبك إلى المكتبة لتسعيره نهائيًا.', textAlign: TextAlign.center, style: T.cap(c.tx2)),
        ])),
      );
    });
  }
}

class OrderPlacedScreen extends StatelessWidget {
  const OrderPlacedScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final ctl = checkoutCtl();
    final o = ctl.createdOrder.value;
    return Page2(
      center: true,
      body: Column(mainAxisSize: MainAxisSize.min, children: [
        SuccessBadge(eventKey: o == null ? null : 'order-placed:${o.id}', semanticsLabel: context.l10n.celebrationOrderPlaced),
        const SizedBox(height: 24),
        if (o != null) STag(o.code, kind: 'plum'),
        const SizedBox(height: 8),
        Text('وصل طلبك', style: T.d2(c.tx)),
        const SizedBox(height: 8),
        Text('تراجع المكتبة طلبك وترسل لك عرض السعر النهائي لتوافق عليه.', textAlign: TextAlign.center, style: T.bd(c.tx2)),
        const SizedBox(height: 24),
        Card2(child: Column(children: [
          for (final (i, a) in [('المكتبة تسعّر', 'عادةً خلال وقت قصير. سنُعلمك بإشعار.'), ('توافق على العرض', 'بعدها يُفتح الدفع إن كان تحويلًا.'), ('نجهّز ونوصّل', 'وتتابع الطلب هنا.')].indexed)
            Padding(padding: EdgeInsets.only(top: i == 0 ? 0 : 16), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 30, height: 30, decoration: BoxDecoration(color: c.plumSoft, shape: BoxShape.circle), alignment: Alignment.center, child: Text('${i + 1}', style: TextStyle(fontFamily: Fonts.dis, fontWeight: FontWeight.w700, fontSize: 15, color: c.plumInk))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(a.$1, style: T.h3(c.tx, size: 15)), Text(a.$2, style: T.sm(c.tx2))])),
            ])),
        ])),
      ]),
      foot: Foot(child: Column(mainAxisSize: MainAxisSize.min, children: [
        SBtn('تابع الطلب', full: true, onTap: () {
          ctl.resetAfterExit();
          if (o != null) {
            Get.offAllNamed('/home');
            Get.toNamed('/order', arguments: {'order_id': o.id});
          } else {
            Get.offAllNamed('/orders');
          }
        }),
        const SizedBox(height: 8),
        SBtn('العودة للرئيسية', kind: BtnKind.ghost, full: true, onTap: () {
          ctl.resetAfterExit();
          Get.offAllNamed('/home');
        }),
      ])),
    );
  }
}

bool _uncertainLeft = false;

class OrderUncertainScreen extends StatelessWidget {
  const OrderUncertainScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final ctl = checkoutCtl();
    _uncertainLeft = false;
    return Obx(() {
      if (ctl.submitState.value == SubmitState.created && !_uncertainLeft) {
        _uncertainLeft = true;
        WidgetsBinding.instance.addPostFrameCallback((_) => leaveFlowTo('/order-placed', kCheckoutFlow));
      }
      return Page2(
        center: true,
        body: Column(mainAxisSize: MainAxisSize.min, children: [
          const Ill('offline', width: 190),
          const SizedBox(height: 24),
          Text('لم نتأكد من وصول طلبك', textAlign: TextAlign.center, style: T.d2(c.tx)),
          const SizedBox(height: 8),
          Text('انقطع الاتصال لحظة الإرسال. تحقق من طلباتك قبل إعادة المحاولة حتى لا يتكرر الطلب.', textAlign: TextAlign.center, style: T.bd(c.tx2)),
        ]),
        foot: Foot(child: Column(mainAxisSize: MainAxisSize.min, children: [
          SBtn('تحقق من طلباتي', full: true, onTap: () => Get.offAllNamed('/orders')),
          const SizedBox(height: 8),
          SBtn('أعد إرسال الطلب', kind: BtnKind.sec, full: true, loading: ctl.submitState.value == SubmitState.submitting, onTap: ctl.recheckSubmission),
        ])),
      );
    });
  }
}

class AddressFormScreen extends StatefulWidget {
  const AddressFormScreen({super.key});
  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final map = MapController();
  final label = TextEditingController(text: 'البيت');
  final details = TextEditingController();
  AddressModel? editing;
  LatLng center = LatLng(PickupPoint.library.lat, PickupPoint.library.lng);
  bool isDefault = true;
  bool outOfZone = false;
  bool saving = false;
  bool locating = false;
  String? error;

  @override
  void initState() {
    super.initState();
    final a = Get.arguments;
    if (a is AddressModel) {
      editing = a;
      label.text = a.title;
      details.text = a.details ?? '';
      center = LatLng(a.lat, a.lng);
      isDefault = a.isDefault;
    } else {
      isDefault = true;
      _locate(silent: true);
    }
  }

  @override
  void dispose() {
    label.dispose();
    details.dispose();
    super.dispose();
  }

  Future<void> _locate({bool silent = false}) async {
    setState(() => locating = true);
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        if (!silent) {
          Get.toNamed('/perm/location-denied');
        }
        return;
      }
      final p = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
      center = LatLng(p.latitude, p.longitude);
      map.move(center, 16);
      _check();
    } catch (_) {
      if (!silent) showToast('تعذّر تحديد موقعك. حرّك الدبوس يدويًا.', icon: 'alertC');
    } finally {
      if (mounted) setState(() => locating = false);
    }
  }

  void _check() => setState(() => outOfZone = !pointInZone(center.latitude, center.longitude));

  Future<void> _save() async {
    final l = label.text.trim();
    if (l.isEmpty) {
      setState(() => error = 'اكتب اسمًا للعنوان.');
      return;
    }
    setState(() {
      saving = true;
      error = null;
    });
    final r = await backend.saveAddress(id: editing?.id, label: l, lat: center.latitude, lng: center.longitude, details: details.text.trim().isEmpty ? null : details.text.trim(), isDefault: isDefault);
    if (!mounted) return;
    setState(() => saving = false);
    r.fold((f) {
      if (f.code == ApiErrorCodes.outOfZone) {
        setState(() => outOfZone = true);
      } else if (f is ValidationFailure) {
        setState(() => error = f.fieldErrors.values.firstOrNull ?? f.message);
      } else {
        setState(() => error = failureText(f));
      }
    }, (a) => Get.back(result: a.id));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final zones = Get.find<RemoteConfigRepository>().current?.zones ?? const [];
    return Page2(
      top: TopBar(title: editing == null ? 'عنوان جديد' : 'تعديل العنوان'),
      flush: true,
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Rad.l),
            child: SizedBox(
              height: 230,
              child: Stack(children: [
                FlutterMap(
                  mapController: map,
                  options: MapOptions(initialCenter: center, initialZoom: 15, onPositionChanged: (pos, gesture) {
                    center = pos.center;
                    if (gesture) _check();
                  }),
                  children: [
                    TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.example.project'),
                    if (zones.isNotEmpty) PolygonLayer(polygons: [for (final z in zones) Polygon(points: [for (final p in z) LatLng(p.lat, p.lng)], color: c.pri.withValues(alpha: .10), borderColor: c.pri.withValues(alpha: .5), borderStrokeWidth: 2)]),
                  ],
                ),
                Center(child: Transform.translate(offset: const Offset(0, -23), child: SIcon('pin', size: 46, color: outOfZone ? c.err : c.pri))),
                PositionedDirectional(bottom: 10, start: 10, child: SIconBtn('nav', size: 22, bg: c.sf, onTap: locating ? null : () => _locate())),
              ]),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (outOfZone) const Note('err', title: 'هذه النقطة خارج منطقة الخدمة.', text: 'حرّك الدبوس إلى داخل المنطقة المظلّلة.') else Text('حرّك الخريطة ليستقر الدبوس على مدخل بيتك.', style: T.sm(c.tx2)),
            const SizedBox(height: 16),
            Fld(label: 'اسم العنوان', hint: 'البيت، العمل…', controller: label, maxLength: 60, error: error),
            const SizedBox(height: 16),
            Fld(label: 'تفاصيل', hint: 'الشارع، العمارة، الطابق، أقرب معلم', controller: details, optional: true, maxLines: 3, maxLength: 500),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('اجعله العنوان الافتراضي', style: T.sm(c.tx, w: FontWeight.w600)), SSwitch(isDefault, onChanged: (v) => setState(() => isDefault = v))]),
          ]),
        ),
        const SizedBox(height: 16),
      ]),
      foot: FootBar(child: SBtn(outOfZone ? 'خارج منطقة الخدمة' : 'حفظ العنوان', full: true, loading: saving, disabled: outOfZone, onTap: _save)),
    );
  }
}
