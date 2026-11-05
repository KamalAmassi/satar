import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/config/remote_config.dart';
import 'package:project/core/config/remote_config_repository.dart';
import 'package:project/core/design/icons.dart';
import 'package:project/core/design/shell.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/design/widgets.dart';
import 'package:project/core/errors/api_error_codes.dart';
import 'package:project/core/storage/session_store.dart';
import 'package:project/customer/features/cart/domain/entities/cart_product_line.dart';
import 'package:project/customer/features/cart/presentation/controllers/cart_controller.dart';
import 'package:project/customer/features/checkout/presentation/controllers/checkout_controller.dart';
import 'package:project/customer/features/printing/domain/entities/print_job.dart';
import 'package:project/core/widgets/common_widgets.dart';

int? lineUnit(CartProductLine line) {
  final info = cartCtl.productInfo[line.productId];
  if (info == null || info.isInspectionPriced) return null;
  var unit = info.price.amount;
  line.options.forEach((key, choices) {
    final option = info.option(key);
    for (final c in choices) {
      unit += option?.choices.where((x) => x.key == c).firstOrNull?.price.amount ?? 0;
    }
  });
  return unit;
}

String lineOptionsLabel(CartProductLine line) {
  final info = cartCtl.productInfo[line.productId];
  final out = <String>[];
  line.options.forEach((key, choices) {
    final o = info?.option(key);
    for (final c in choices) {
      out.add(o?.choices.where((x) => x.key == c).firstOrNull?.label ?? c);
    }
  });
  return out.join(' · ');
}

String specSummary(PrintJob j, PrintingConfig? cfg) {
  final s = j.spec;
  final paper = cfg?.paper(s.paperSize)?.label ?? s.paperSize;
  final bind = cfg?.binding(s.binding)?.label;
  return [paper, s.color == 'color' ? 'ملوّن' : 'أبيض وأسود', s.sides == 'double' ? 'وجهان' : 'وجه واحد', '${s.copies} نسخ', if (bind != null && s.binding != 'none') bind].join(' · ');
}

class LineThumbRow extends StatelessWidget {
  const LineThumbRow({super.key, required this.title, this.sub, required this.name, this.imageUrl, this.seed = 0, this.trailing, this.qty});
  final String title;
  final String? sub;
  final String name;
  final String? imageUrl;
  final int seed;
  final Widget? trailing;
  final int? qty;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Row(children: [
      ProdThumb(imageUrl: imageUrl, name: name, seed: seed),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: T.h3(c.tx, size: 15).copyWith(height: 1.45)),
        if (sub != null && sub!.isNotEmpty) Text(sub!, style: T.sm(c.tx2)),
        if (qty != null || trailing != null)
          Padding(padding: const EdgeInsets.only(top: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [if (qty != null) Num('× $qty', style: T.sm(c.tx2)) else const SizedBox(), if (trailing != null) trailing!])),
      ])),
    ]);
  }
}

Widget printLine(BuildContext context, String t, String s) {
  final c = context.sc;
  return Row(children: [
    Container(width: 64, height: 64, decoration: BoxDecoration(color: c.hero, borderRadius: BorderRadius.circular(14)), child: Center(child: SIcon('printer', size: 28, color: c.onHero))),
    const SizedBox(width: 14),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: T.h3(c.tx, size: 15)), Text(s, style: T.sm(c.tx2))])),
  ]);
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    cartCtl.ensureLoaded().then((_) => cartCtl.refreshProductInfo());
  }

  Widget? _stockBanner(BuildContext context) {
    if (!Get.isRegistered<CheckoutController>()) return null;
    final f = Get.find<CheckoutController>().quoteFailure.value;
    if (f == null || f.code != ApiErrorCodes.outOfStock) return null;
    final pid = f.details?['product_id'];
    final avail = f.details?['available'];
    if (pid is! int || avail is! int) return const Note('err', title: 'الكمية المطلوبة أكبر من المتوفر.', text: 'عدّل الكميات ثم تابع.');
    final name = cartCtl.productInfo[pid]?.name ?? 'المنتج';
    return Note('err', title: 'الكمية المطلوبة أكبر من المتوفر.', text: 'المتوفر من «$name» هو $avail فقط.', action: 'اضبط على $avail', onActionTap: () {
      final line = cartCtl.products.firstWhereOrNull((l) => l.productId == pid);
      if (line != null) cartCtl.setQuantity(line.id, avail == 0 ? 1 : avail);
      Get.find<CheckoutController>().quoteFailure.value = null;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Obx(() {
      cartCtl.revision.value;
      cartCtl.productInfo.length;
      final cart = cartCtl;
      if (cart.isEmpty) {
        return Page2(
          top: const TopBar(title: 'سلتي'),
          center: true,
          body: EmptyState(ill: 'bag', title: 'سلتك فارغة', text: 'أضف كتبًا أو قرطاسية، أو ارفع ملفًا للطباعة.', cta: Column(children: [
            SBtn('تصفّح المنتجات', full: true, onTap: () => Get.toNamed('/products', arguments: {'title': 'المنتجات'})),
            const SizedBox(height: 8),
            SBtn('اطبع ملفًا', kind: BtnKind.sec, icon: 'printer', full: true, onTap: () => goTab('/print')),
          ])),
        );
      }
      final est = cartEstimate();
      final cfg = Get.find<RemoteConfigRepository>().current?.printing;
      final banner = _stockBanner(context);
      final blocked = banner != null || cart.hasUploadsInFlight || cart.hasFailedUploads || cart.hasInterruptedUploads;
      final total = est.products + est.printing;
      return Page2(
        top: const TopBar(title: 'سلتي'),
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (banner != null) ...[banner, const SizedBox(height: 16)],
          if (cart.hasInterruptedUploads || cart.hasFailedUploads) ...[
            Note('warn', title: 'ملفات الطباعة تحتاج انتباهك.', text: 'ملف لم يكتمل رفعه. اختره من جديد من شاشة الملفات.', action: 'فتح الملفات', onActionTap: () => Get.toNamed('/print/upload')),
            const SizedBox(height: 16),
          ],
          for (final line in cart.products) ...[
            _ProductLineCard(line),
            const SizedBox(height: 16),
          ],
          if (cart.shoppingRequest.value.trim().isNotEmpty) ...[
            Card2(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                Container(width: 64, height: 64, decoration: BoxDecoration(color: c.plumSoft, borderRadius: BorderRadius.circular(14)), child: Center(child: SIcon('edit', size: 28, color: c.plumInk))),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('طلب نصي للمكتبة', style: T.h3(c.tx, size: 15)), Text('تسعّره المكتبة وتعرض عليك السعر للموافقة.', style: T.sm(c.tx2))])),
                SIconBtn('trash', size: 20, box: 40, onTap: cart.clearShoppingRequest),
              ]),
              const SizedBox(height: 8),
              Text(cart.shoppingRequest.value, style: T.sm(c.tx)),
            ])),
            const SizedBox(height: 16),
          ],
          if (cart.printJobs.isNotEmpty) ...[
            Card2(child: Column(children: [
              printLine(context, 'طباعة · ${cart.printJobs.length == 1 ? 'ملف' : '${cart.printJobs.length} ملفات'}', specSummary(cart.printJobs.first, cfg)),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [Text('تقدير الطباعة ', style: T.sm(c.tx2)), Mny(est.printing)]),
                Row(children: [SBtn('تعديل', kind: BtnKind.ghost, size: BtnSize.xs, onTap: () => Get.toNamed('/print/specs')), SIconBtn('trash', size: 20, box: 40, onTap: () {
                  for (final j in cart.printJobs.toList()) {
                    cart.removePrintJob(j.id);
                  }
                })]),
              ]),
            ])),
            const SizedBox(height: 16),
          ],
          Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('تضيف شيئًا؟', style: T.h3(c.tx)),
            const SizedBox(height: 8),
            Row(children: [
              SBtn('منتجات', kind: BtnKind.sec, size: BtnSize.xs, icon: 'plus', onTap: () => Get.toNamed('/products', arguments: {'title': 'المنتجات'})),
              const SizedBox(width: 8),
              SBtn('طباعة', kind: BtnKind.sec, size: BtnSize.xs, icon: 'printer', onTap: () => goTab('/print')),
              const SizedBox(width: 8),
              SBtn('المساعد', kind: BtnKind.sec, size: BtnSize.xs, icon: 'sparkles', onTap: () => goTab('/assistant')),
            ]),
          ])),
          const SizedBox(height: 16),
          PriceBox(
            rows: [
              ('المنتجات', est.productsKnown ? Mny(est.products) : Text('يُحدَّد بعد التسعير', style: T.sm(c.tx2))),
              if (cart.printJobs.isNotEmpty) ('الطباعة (تقدير)', Mny(est.printing)),
              ('التوصيل', Text('يُحسب حسب العنوان', style: T.sm(c.tx2))),
            ],
            totalMinor: total,
            totalLabel: 'قبل التوصيل',
          ),
          const SizedBox(height: 16),
          Text('السعر النهائي يحدده الخادم في الخطوة التالية.', textAlign: TextAlign.center, style: T.sm(c.tx2)),
        ]),
        foot: FootBar(child: Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text('قبل التوصيل', style: T.cap(c.tx2)), Mny(total, size: 22)]),
          const SizedBox(width: 16),
          Expanded(child: SBtn('متابعة إلى الدفع', full: true, disabled: blocked, onTap: () {
            if (!Get.find<SessionStore>().isSignedIn) {
              Get.toNamed('/auth/phone');
              return;
            }
            Get.toNamed('/checkout');
          })),
        ])),
      );
    });
  }
}

class _ProductLineCard extends StatelessWidget {
  const _ProductLineCard(this.line);
  final CartProductLine line;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final info = cartCtl.productInfo[line.productId];
    final fail = cartCtl.productInfoFailures[line.productId];
    final unit = lineUnit(line);
    final max = (info?.stock == null ? 99 : info!.stock!.clamp(1, 99));
    final err = line.fieldErrors.values.firstOrNull;
    return Card2(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ProdThumb(imageUrl: info?.imageUrl, name: info?.name ?? '', seed: line.productId),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(info?.name ?? (fail != null ? 'منتج غير متاح' : '…'), style: T.h3(c.tx, size: 15).copyWith(height: 1.45)),
          if (lineOptionsLabel(line).isNotEmpty) Text(lineOptionsLabel(line), style: T.sm(c.tx2)),
          const SizedBox(height: 2),
          if (unit != null) Mny(unit * line.quantity) else if (info?.isInspectionPriced ?? false) Text('يُسعَّر بعد المعاينة', style: T.sm(c.tx2)),
        ])),
        SIconBtn('trash', size: 20, box: 40, onTap: () => cartCtl.removeProduct(line.id)),
      ]),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Stepper2(value: line.quantity, maxed: line.quantity >= max, onInc: () => cartCtl.setQuantity(line.id, line.quantity + 1, maxQty: max), onDec: () => cartCtl.setQuantity(line.id, line.quantity - 1, maxQty: max)),
        if (info?.stock != null && line.quantity >= max) Text('الحد المتاح $max', style: TextStyle(fontFamily: Fonts.ui, fontSize: 14, fontWeight: FontWeight.w600, color: c.amberInk)),
      ]),
      if (err != null) ...[const SizedBox(height: 8), FieldError(err)],
    ]));
  }
}
