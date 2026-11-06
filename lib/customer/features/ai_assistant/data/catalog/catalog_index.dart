import 'package:flutter/foundation.dart';
import 'package:project/core/network/masar_model/masar_models.dart';
import 'package:project/customer/features/ai_assistant/data/datasources/catalog_remote_datasource.dart';
import 'package:project/customer/features/ai_assistant/data/matching/arabic_lexicon.dart';

enum HeadMatch { none, category, name }

/// منتج مفهرس: نصوص مطبّعة جاهزة للمطابقة (لا شبكة هنا).
class CatalogEntry {
  CatalogEntry(this.product, {String? categoryName})
      : categoryName = categoryName ?? '',
        nameStems = ArabicLexicon.stems(product.name),
        descStems = ArabicLexicon.stems(product.description ?? '').toSet(),
        categoryStems = ArabicLexicon.stems(categoryName ?? '').toSet() {
    nameSet = nameStems.toSet();
    final pack = _detectPack(nameStems);
    isPack = pack.$1;
    packCount = pack.$2;
  }

  final Product product;
  final String categoryName;
  final List<String> nameStems;
  final Set<String> descStems;
  final Set<String> categoryStems;
  late final Set<String> nameSet;
  late final bool isPack;
  late final int? packCount;

  int get id => product.id;
  int get priceAmount => product.price.amount;
  bool get available => product.inStock && (product.stock == null || product.stock! > 0);

  /// كلمات الاسم + الوصف + الفئة (للتحقق من الصفات).
  bool hasStem(String s) => nameSet.contains(s) || descStems.contains(s) || categoryStems.contains(s);

  static (bool, int?) _detectPack(List<String> stems) {
    for (var i = 0; i < stems.length; i++) {
      if (ArabicLexicon.packStems.contains(stems[i])) {
        int? n;
        for (final j in [i - 1, i + 1]) {
          if (j >= 0 && j < stems.length) n ??= int.tryParse(stems[j]);
        }
        return (true, n);
      }
      final n = int.tryParse(stems[i]);
      if (n != null && n >= 2 && n <= 500 && i + 1 < stems.length && ArabicLexicon.unitStems.contains(stems[i + 1])) {
        return (true, n);
      }
    }
    return (false, null);
  }
}

/// فهرس الكتالوج في الذاكرة.
class CatalogIndex {
  CatalogIndex(Iterable<Product> products, {Map<int, String> categories = const {}})
      : entries = [
          for (final p in products) CatalogEntry(p, categoryName: categories[p.categoryId]),
        ];

  final List<CatalogEntry> entries;
  int get size => entries.length;

  /// كل جذع من [headStems] (أو مرادفه) يجب أن يظهر: في الاسم ← name، وإلا في الفئة ← category.
  HeadMatch headMatch(CatalogEntry e, List<String> headStems) {
    if (headStems.isEmpty) return HeadMatch.none;
    var inName = true;
    var inCat = true;
    for (final s in headStems) {
      final group = ArabicLexicon.synonymsOf(s);
      final n = group.any(e.nameSet.contains);
      final c = group.any(e.categoryStems.contains);
      if (!n) inName = false;
      if (!n && !c) inCat = false;
    }
    if (inName) return HeadMatch.name;
    if (inCat) return HeadMatch.category;
    return HeadMatch.none;
  }

  /// المرشّحون: ما يطابق نوع المنتج في الاسم أو الفئة. لا حذف حسب must_not هنا.
  List<({CatalogEntry entry, HeadMatch head})> candidates(String productType) {
    final head = ArabicLexicon.stems(productType);
    final out = <({CatalogEntry entry, HeadMatch head})>[];
    for (final e in entries) {
      final m = headMatch(e, head);
      if (m != HeadMatch.none) out.add((entry: e, head: m));
    }
    return out;
  }

  /// للتطوير فقط: كم منتجاً في الكتالوج يطابق كل مفردة من القاموس.
  void lexiconCoverage() {
    if (!kDebugMode) return;
    final packs = entries.where((e) => e.isPack).length;
    final wire = entries.where((e) => e.nameSet.contains(ArabicLexicon.stemOf('سلك'))).length;
    final notepads = entries.where((e) => e.nameSet.contains(ArabicLexicon.stemOf('نوتة'))).length;
    debugPrint('[ai-lexicon] products=$size packs=$packs wire=$wire notepads=$notepads');
  }
}

/// يحمّل الكتالوج مرة لكل جلسة ويحتفظ به [ttl] (الافتراضي 10 دقائق).
class CatalogProvider {
  CatalogProvider(this._ds, {this.ttl = const Duration(minutes: 10), DateTime Function()? clock})
      : _now = clock ?? DateTime.now;

  final CatalogRemoteDataSource _ds;
  final Duration ttl;
  final DateTime Function() _now;

  CatalogIndex? _index;
  DateTime? _at;
  Future<CatalogIndex>? _loading;

  Future<CatalogIndex> load() {
    final fresh = _index != null && _at != null && _now().difference(_at!) < ttl;
    if (fresh) return Future.value(_index);
    return _loading ??= _fetch().whenComplete(() => _loading = null);
  }

  Future<CatalogIndex> _fetch() async {
    final products = await _ds.fetchProducts();
    final categories = await _ds.fetchCategories();
    final index = CatalogIndex(products, categories: categories);
    _index = index;
    _at = _now();
    index.lexiconCoverage();
    return index;
  }

  void invalidate() {
    _index = null;
    _at = null;
  }
}
