import 'dart:convert';
import 'dart:io';

import 'package:project/core/network/masar_model/masar_models.dart';
import 'package:project/customer/features/ai_assistant/data/catalog/catalog_index.dart';

/// يحمّل fixtures/catalog_snapshot.json ويوسّعه لشكل /v1/products الحقيقي.
({List<Map<String, dynamic>> products, Map<int, String> categories}) loadCatalogJson() {
  final raw = jsonDecode(File('test/customer/features/ai_assistant/fixtures/catalog_snapshot.json').readAsStringSync()) as Map<String, dynamic>;
  final products = [
    for (final p in raw['products'] as List)
      {
        'id': p['id'],
        'name': p['name'],
        'description': p['description'],
        'price': {'amount': p['price'], 'formatted': '${(p['price'] as int) / 100} ₪'},
        'in_stock': (p['stock'] as int) > 0,
        'stock': p['stock'],
        'category_id': p['category_id'],
        'options': <dynamic>[],
        'fields': <String, dynamic>{},
      },
  ];
  final categories = {
    for (final e in (raw['categories'] as Map).entries) int.parse(e.key as String): e.value as String,
  };
  return (products: products, categories: categories);
}

CatalogIndex fixtureIndex() {
  final c = loadCatalogJson();
  return CatalogIndex(
    [for (final p in c.products) Product.fromJson(p)],
    categories: c.categories,
  );
}
