import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/design/widgets.dart';
import 'package:project/core/l10n/app_localizations.dart';
import 'package:project/core/utils/haptics.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/proposed_item.dart';
import 'package:project/customer/features/ai_assistant/presentation/controllers/voice_controller.dart';
import 'package:project/customer/features/cart/domain/entities/cart_product_line.dart';
import 'package:project/customer/features/cart/presentation/bindings/cart_binding.dart';

/// ورقة المراجعة. تُرجع true بعد إضافة الأصناف المحددة للسلة (بعد نقرة المستخدم الصريحة فقط).
Future<bool?> showVoiceSummarySheet(BuildContext context, VoiceController ctl) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _Sheet(ctl: ctl),
  );
}

class _Sheet extends StatelessWidget {
  const _Sheet({required this.ctl});
  final VoiceController ctl;

  void _confirm(BuildContext context) {
    final cart = CartBinding.ensureCart();
    for (final it in ctl.proposals.where((e) => e.selected && e.product.isAvailable)) {
      final p = it.product;
      cart.addProduct(
        CartItemRequest(productId: p.id, quantity: it.quantity, options: {for (final e in p.selectedOptions.entries) e.key: [e.value]}),
        maxQty: p.maxQuantity == 0 ? 99 : p.maxQuantity,
      );
    }
    Haptics.confirm();
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final l = AppLocalizations.of(context)!;
    final maxH = MediaQuery.sizeOf(context).height * 0.78;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxH),
      child: Container(
        decoration: BoxDecoration(color: c.bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(Rad.xl))),
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.paddingOf(context).bottom),
        child: Obx(() {
          final items = ctl.proposals.toList();
          final chosen = items.where((e) => e.selected && e.product.isAvailable).toList();
          final total = chosen.fold<int>(0, (s, e) => s + e.lineTotal);
          return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.voiceSummaryTitle, style: T.h2(c.tx)),
            const SizedBox(height: 12),
            if (items.isEmpty)
              Padding(padding: const EdgeInsets.symmetric(vertical: 24), child: Center(child: Text(l.voiceNoItems, style: T.bd(c.tx2))))
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _Row(item: items[i], ctl: ctl),
                ),
              ),
            const SizedBox(height: 12),
            Row(children: [
              Text(l.voiceTotal, style: T.h3(c.tx)),
              const Spacer(),
              Text('${(total / 100).toStringAsFixed(2)} ₪', style: T.h3(c.tx)),
            ]),
            const SizedBox(height: 12),
            SBtn(l.voiceConfirmAdd, full: true, disabled: chosen.isEmpty, onTap: () => _confirm(context)),
            const SizedBox(height: 8),
            SBtn(l.voiceContinue, full: true, kind: BtnKind.ghost, onTap: () => Navigator.of(context).pop(false)),
          ]);
        }),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.item, required this.ctl});
  final ProposedItem item;
  final VoiceController ctl;

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final l = AppLocalizations.of(context)!;
    final p = item.product;
    final ok = p.isAvailable;
    return Opacity(
      opacity: ok ? 1 : 0.5,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: c.sf, borderRadius: BorderRadius.circular(Rad.m), border: Border.all(color: c.ln)),
        child: Row(children: [
          Checkbox(value: item.selected && ok, onChanged: ok ? (_) => ctl.toggleSelected(p.id) : null, activeColor: c.pri),
          SizedBox(width: 48, height: 48, child: ClipRRect(borderRadius: BorderRadius.circular(Rad.s), child: ProductArt(imageUrl: p.imageUrl, name: p.name, seed: p.id, decodeWidth: 96))),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: T.sm(c.tx, w: FontWeight.w600)),
              Text(ok ? p.priceLabel : l.voiceOutOfStock, style: T.cap(c.tx2)),
            ]),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            color: c.tx2,
            onPressed: ok && item.quantity > ProposedItem.minQty ? () => ctl.setQuantity(p.id, item.quantity - 1) : null,
          ),
          Text('${item.quantity}', style: T.h3(c.tx)),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            color: c.pri,
            onPressed: ok && item.quantity < ProposedItem.maxQty ? () => ctl.setQuantity(p.id, item.quantity + 1) : null,
          ),
        ]),
      ),
    );
  }
}
