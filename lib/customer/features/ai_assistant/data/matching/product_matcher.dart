import 'package:project/customer/features/ai_assistant/data/catalog/catalog_index.dart';
import 'package:project/customer/features/ai_assistant/data/matching/product_scorer.dart';
import 'package:project/customer/features/ai_assistant/data/models/suggested_product_model.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/intent.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/match_info.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/suggested_product.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/suggestion_item.dart';

/// فهم ← استرجاع ← تحقق: يحوّل [ItemSpec] إلى سطر اقتراح من الكتالوج الفعلي فقط.
class ProductMatcher {
  const ProductMatcher({this.scorer = const ProductScorer()});

  final ProductScorer scorer;

  SuggestionItem resolve(ItemSpec spec, CatalogIndex index) => fromRanked(spec, scorer.resolve(spec, index));

  /// يبني السطر من نتيجة مصنّفة (يُستخدم أيضًا بعد الحكم الاختياري).
  SuggestionItem fromRanked(ItemSpec spec, RankedMatches r) {
    final text = spec.originalText.isNotEmpty ? spec.originalText : spec.productType;
    final close = [for (final m in r.close) _matched(m)];
    final similar = [for (final m in r.alternatives) _matched(m)];
    if (r.exact.isEmpty) {
      return SuggestionItem.resolve(
        requestText: text,
        requestedQty: spec.quantity,
        close: close,
        similar: similar,
        role: spec.role,
      );
    }
    final main = r.exact.first;
    return SuggestionItem.resolve(
      requestText: text,
      requestedQty: spec.quantity,
      product: SuggestedProductModel.fromProduct(main.entry.product),
      alternatives: [for (final m in r.exact.skip(1)) if (m.entry.available) SuggestedProductModel.fromProduct(m.entry.product)],
      level: MatchLevel.exact,
      note: main.note,
      close: close,
      similar: similar,
      role: spec.role,
    );
  }

  MatchedProduct _matched(ScoredMatch m) =>
      MatchedProduct(product: SuggestedProductModel.fromProduct(m.entry.product), level: m.level, note: m.note);

  SuggestedProduct product(ScoredMatch m) => SuggestedProductModel.fromProduct(m.entry.product);
}
