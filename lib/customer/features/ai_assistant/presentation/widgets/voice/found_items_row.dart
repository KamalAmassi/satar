import 'package:flutter/material.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/design/widgets.dart';
import 'package:project/core/l10n/app_localizations.dart';
import 'package:project/core/motion/entrance.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/suggested_product.dart';

/// صف أفقي لنتائج آخر بحث في الكتالوج (أسماء وأسعار حقيقية فقط).
class FoundItemsRow extends StatelessWidget {
  const FoundItemsRow({super.key, required this.items, required this.onAdd});

  final List<SuggestedProduct> items;
  final void Function(SuggestedProduct) onAdd;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) => Entrance(index: i, child: _Card(item: items[i], onAdd: () => onAdd(items[i]))),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.item, required this.onAdd});
  final SuggestedProduct item;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final l = AppLocalizations.of(context)!;
    final ok = item.isAvailable;
    return Container(
      width: 168,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: c.sf, borderRadius: BorderRadius.circular(Rad.m), border: Border.all(color: c.ln)),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: T.sm(c.tx, w: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(item.priceLabel, style: T.cap(c.tx2)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: ok ? c.okSoft : c.errSoft, borderRadius: BorderRadius.circular(Rad.s)),
              child: Text(ok ? l.voiceInStock : l.voiceOutOfStock, style: T.cap(ok ? c.okInk : c.errInk)),
            ),
          ]),
        ),
        const SizedBox(width: 6),
        SIconBtn('plus', onTap: ok ? onAdd : null, tonal: true, size: 20, box: 40),
      ]),
    );
  }
}
