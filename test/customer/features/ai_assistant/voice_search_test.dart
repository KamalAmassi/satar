import 'package:flutter_test/flutter_test.dart';
import 'package:project/core/network/masar_model/masar_models.dart';
import 'package:project/customer/features/ai_assistant/data/catalog/catalog_index.dart';
import 'package:project/customer/features/ai_assistant/data/datasources/catalog_remote_datasource.dart';
import 'package:project/customer/features/ai_assistant/data/datasources/gemini_voice_datasource.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/intent.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/match_info.dart';
import 'package:project/customer/features/ai_assistant/domain/repositories/voice_repository.dart';
import 'package:project/customer/features/ai_assistant/presentation/bindings/voice_binding.dart';

import 'fixtures/catalog_fixture.dart';

class _Ds implements CatalogRemoteDataSource {
  int fetches = 0;
  @override
  Future<List<Product>> fetchProducts() async {
    fetches++;
    return [for (final p in loadCatalogJson().products) Product.fromJson(p)];
  }

  @override
  Future<Map<int, String>> fetchCategories() async => loadCatalogJson().categories;

  @override
  Future<List<Product>> search(String q) async => const [];
}

void main() {
  test('voice search_catalog: verified exact first (<=3), close labelled, wire/notepad never exact', () async {
    final provider = CatalogProvider(_Ds());
    final r = await verifiedCatalogSearch(provider, const VoiceSearchArgs(productType: 'دفتر', pack: PackMode.pack, mustNot: ['سلك', 'نوتة']));
    final exact = r.where((m) => m.level == MatchLevel.exact).map((m) => m.product.id).toList();
    expect(exact.length, lessThanOrEqualTo(3));
    expect(exact, everyElement(anyOf(1, 2, 3, 4)));
    expect(r.where((m) => m.level == MatchLevel.close).length, lessThanOrEqualTo(2));
    expect(r.length, lessThanOrEqualTo(5));
    // exact قبل close دائمًا.
    final levels = r.map((m) => m.level.index).toList();
    expect(levels, [...levels]..sort());
  });

  test('voice search: nothing invented for unknown product', () async {
    final r = await verifiedCatalogSearch(CatalogProvider(_Ds()), const VoiceSearchArgs(productType: 'حاسوب'));
    expect(r, isEmpty);
  });

  test('catalog is cached for the TTL (one fetch for many searches), then refreshed', () async {
    final ds = _Ds();
    var now = DateTime(2026, 1, 1);
    final provider = CatalogProvider(ds, clock: () => now);
    await provider.load();
    await provider.load();
    await verifiedCatalogSearch(provider, const VoiceSearchArgs(productType: 'قلم'));
    expect(ds.fetches, 1);
    now = now.add(const Duration(minutes: 11));
    await provider.load();
    expect(ds.fetches, 2);
  });

  test('voice system prompt: plain-text rules, one question, exact-only, bans markdown', () {
    const p = GeminiVoiceDataSource.systemPrompt;
    expect(p, contains('12 كلمة'));
    expect(p, contains('exact'));
    expect(p, contains('3 أصناف'));
    expect(p, contains('propose_item'));
    expect(p, contains('سؤالًا توضيحيًا واحدًا'));
    expect(p, contains('ممنوع Markdown'));
  });
}
