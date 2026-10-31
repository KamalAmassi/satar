import 'package:project/core/network/masar_model/masar_models.dart';
import 'package:project/core/utils/arabic_text.dart';
import 'package:project/customer/features/ai_assistant/data/matching/request_parser.dart';
import 'package:project/customer/features/ai_assistant/data/models/suggested_product_model.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/suggested_product.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/suggestion_item.dart';

/// مطابقة بين طلب الزبون والكتالوج الفعلي (لا تخترع منتجات ولا أسعار).
class ProductMatcher {
  const ProductMatcher();

  static const _minScore = 0.5;
  static const _maxAlternatives = 3;

  SuggestionItem resolve(RequestedItem request, List<Product> catalog) {
    final main = _variantsOf(request.tokens);
    final altSets = [
      for (final tokens in request.alternatives)
        if (tokens.isNotEmpty) _variantsOf(tokens),
    ];

    Product? best;
    var bestRank = const _Rank(0, 0, 0, 0);

    for (final product in catalog) {
      final stems = ArabicText.normalize(product.name)
          .split(' ')
          .where((t) => t.isNotEmpty)
          .map(ArabicText.stem)
          .toSet();

      final mainMatched = _matchedCount(main, stems);
      var score = main.isEmpty ? 0.0 : mainMatched / main.length;
      for (final alt in altSets) {
        final s = _matchedCount(alt, stems) / alt.length;
        if (s > score) score = s;
      }
      if (score < _minScore) continue;

      final rank = _Rank(
        score,
        mainMatched,
        _isAvailable(product) ? 1 : 0,
        -(stems.length - mainMatched),
      );
      if (best == null || rank.compareTo(bestRank) > 0) {
        best = product;
        bestRank = rank;
      }
    }

    if (best == null) {
      return SuggestionItem.resolve(
        requestText: request.query,
        requestedQty: request.quantity,
      );
    }

    final model = SuggestedProductModel.fromProduct(best);
    var quantity = request.quantity;
    if (!request.hasExplicitQuantity && _looksDual(request, best)) {
      quantity = 2; // "دفترين" = 2
    }

    return SuggestionItem.resolve(
      requestText: request.query,
      requestedQty: quantity,
      product: model,
      alternatives: (!model.isAvailable || quantity > model.maxQuantity)
          ? _alternatives(best, catalog)
          : const [],
    );
  }

  List<Set<String>> _variantsOf(List<String> tokens) =>
      [for (final t in tokens) _variants(t)];

  int _matchedCount(List<Set<String>> variants, Set<String> productStems) {
    var matched = 0;
    for (final v in variants) {
      if (v.any((candidate) => _matches(candidate, productStems))) matched++;
    }
    return matched;
  }

  /// كلمة المستخدم تنتهي بصيغة المثنى ولا تظهر حرفياً في اسم المنتج.
  bool _looksDual(RequestedItem request, Product product) {
    final raw = ArabicText.normalize(product.name).split(' ').toSet();
    return request.tokens.any(
          (t) => t.length >= 5 && t.endsWith('ين') && !raw.contains(t),
    );
  }

  Set<String> _variants(String token) {
    final result = {ArabicText.stem(token)};
    if (token.startsWith('و') && token.length > 3) {
      result.add(ArabicText.stem(token.substring(1)));
    }
    return result;
  }

  bool _matches(String query, Set<String> productStems) {
    if (productStems.contains(query)) return true;
    if (query.length < 3) return false;
    return productStems.any(
          (s) => s.length >= 3 && (s.startsWith(query) || query.startsWith(s)),
    );
  }

  bool _isAvailable(Product p) => p.inStock && (p.stock == null || p.stock! > 0);

  /// بدائل من نفس الفئة، متوفرة، وبأقرب سعر.
  List<SuggestedProduct> _alternatives(Product product, List<Product> catalog) {
    final candidates = catalog
        .where((p) =>
    p.id != product.id &&
        p.categoryId == product.categoryId &&
        _isAvailable(p))
        .toList()
      ..sort((a, b) => (a.price.amount - product.price.amount)
          .abs()
          .compareTo((b.price.amount - product.price.amount).abs()));

    return candidates
        .take(_maxAlternatives)
        .map(SuggestedProductModel.fromProduct)
        .toList();
  }
}

class _Rank implements Comparable<_Rank> {
  const _Rank(this.score, this.mainMatched, this.inStock, this.specificity);

  final double score;
  final int mainMatched;
  final int inStock;
  final int specificity;

  @override
  int compareTo(_Rank other) {
    final byScore = score.compareTo(other.score);
    if (byScore != 0) return byScore;
    final byMain = mainMatched.compareTo(other.mainMatched);
    if (byMain != 0) return byMain;
    final byStock = inStock.compareTo(other.inStock);
    if (byStock != 0) return byStock;
    return specificity.compareTo(other.specificity);
  }
}