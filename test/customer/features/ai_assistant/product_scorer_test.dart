import 'package:flutter_test/flutter_test.dart';
import 'package:project/customer/features/ai_assistant/data/matching/product_matcher.dart';
import 'package:project/customer/features/ai_assistant/data/matching/product_scorer.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/intent.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/match_info.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/suggestion_item.dart';

import 'fixtures/catalog_fixture.dart';

void main() {
  final index = fixtureIndex();
  const scorer = ProductScorer();

  Set<int> ids(List<ScoredMatch> l) => {for (final m in l) m.entry.id};

  group('golden: deterministic scorer (structured intent in, no LLM)', () {
    test('1. ربطة دفاتر -> only packs of notebooks exact; wire/notepads never exact', () {
      const spec = ItemSpec(
        productType: 'دفتر',
        pack: PackMode.pack,
        originalText: 'ربطة دفاتر',
        mustNot: ['سلك', 'نوتة', 'ملاحظات'],
      );
      final r = scorer.resolve(spec, index);
      expect(ids(r.exact), {1, 2, 3, 4});
      // سلك ونوتة: لا تظهر في الرئيسية؛ إن ظهرت فهي close مع سبب، والنوتة المستقلة مرفوضة.
      for (final m in r.close) {
        if ({7, 8, 9, 11}.contains(m.entry.id)) {
          expect(m.note?.code, NoteCode.unwantedTerm, reason: 'id ${m.entry.id}');
        }
      }
      expect(ids(r.exact).intersection({7, 8, 9, 10, 11, 12}), isEmpty);
      expect(ids(r.close), isNot(contains(10)));
      expect(r.exact.length + r.close.length, lessThanOrEqualTo(5));
    });

    test('1b. same without model-supplied must_not: lexicon still demotes wire/notepad', () {
      const spec = ItemSpec(productType: 'دفتر', pack: PackMode.pack, originalText: 'ربطة دفاتر');
      final all = scorer.score(spec, index);
      MatchLevel levelOf(int id) => all.firstWhere((m) => m.entry.id == id).level;
      expect(levelOf(9), MatchLevel.close);
      expect(levelOf(7), MatchLevel.close);
      expect(all.any((m) => m.entry.id == 10), isFalse);
    });

    test('2. دفتر سلك -> wire notebooks exact; plain packs not exact', () {
      const spec = ItemSpec(productType: 'دفتر', attributes: {'ruling': 'سلك'}, originalText: 'دفتر سلك');
      final r = scorer.resolve(spec, index);
      expect(ids(r.exact), {7, 8});
      expect(ids(r.exact).intersection({1, 2, 3, 5, 6, 9}), isEmpty);
    });

    test('3. نوتة -> notepads exact; school notebooks not exact', () {
      const spec = ItemSpec(productType: 'نوتة', originalText: 'نوتة');
      final r = scorer.resolve(spec, index);
      expect(ids(r.exact), containsAll([10, 11, 12]));
      expect(ids(r.exact).intersection({1, 5, 6, 7}), isEmpty);
    });

    test('4. 3 اقلام ازرق -> blue pens, qty 3, other colors not exact', () {
      const spec = ItemSpec(productType: 'قلم', quantity: 3, attributes: {'color': 'أزرق'}, originalText: '3 اقلام ازرق');
      final r = scorer.resolve(spec, index);
      expect(ids(r.exact), {20, 26});
      expect(ids(r.exact).intersection({21, 22, 24}), isEmpty);
      final item = const ProductMatcher().fromRanked(spec, r);
      expect(item.requestedQty, 3);
      expect(item.quantity, 3);
    });

    test('5. دفترين (qty 2, single) -> packs are not exact', () {
      const spec = ItemSpec(productType: 'دفتر', quantity: 2, originalText: 'دفترين');
      final r = scorer.resolve(spec, index);
      expect(ids(r.exact).intersection({1, 2, 3, 4}), isEmpty);
      expect(ids(r.exact), containsAll([5, 6]));
      final item = const ProductMatcher().fromRanked(spec, r);
      expect(item.requestedQty, 2);
      expect(item.quantity, 2);
    });

    test('6a. out-of-stock exact item flagged + in-stock alternative; available preferred as main', () {
      // دفتر مربعات ربطة: الوحيدة المطابقة في المخزون بالنسبة للـ pack، لكن id 4 نفد.
      const spec = ItemSpec(productType: 'دفتر', pack: PackMode.pack, attributes: {'ruling': 'مربعات'}, originalText: 'ربطة دفاتر مربعات');
      final r = scorer.resolve(spec, index);
      expect(ids(r.exact), {4});
      final item = const ProductMatcher().fromRanked(spec, r);
      expect(item.status, SuggestionStatus.outOfStock);
      expect(item.product!.id, 4);
      // اقتراحات بديلة قريبة (ربطات أخرى) تظهر كـ close مع سبب.
      expect(item.close.map((m) => m.product.id), containsAll([1, 2]));
      expect(item.close.every((m) => m.note != null), isTrue);
    });

    test('6b. nothing invented when no product matches', () {
      const spec = ItemSpec(productType: 'حاسوب', originalText: 'حاسوب');
      final item = const ProductMatcher().resolve(spec, index);
      expect(item.status, SuggestionStatus.notFound);
      expect(item.product, isNull);
      expect(item.close, isEmpty);
      expect(item.similar, isEmpty);
    });

    test('7. normalization variants give the same results', () {
      List<int> run(String t) => scorer.resolve(ItemSpec(productType: t, pack: PackMode.pack), index).exact.map((m) => m.entry.id).toList();
      expect(run('دفاتر'), run('دفتر'));
      expect(run('الدفتر'), run('دفتر'));
      expect(run('دَفْتَر'), run('دفتر'));
      expect(scorer.resolve(const ItemSpec(productType: 'أقلام'), index).exact.map((m) => m.entry.id),
          scorer.resolve(const ItemSpec(productType: 'اقلام'), index).exact.map((m) => m.entry.id));
    });

    test('cap: never more than 5 results across exact+close', () {
      const spec = ItemSpec(productType: 'قلم', originalText: 'قلم');
      final r = scorer.resolve(spec, index);
      expect(r.exact.length + r.close.length, lessThanOrEqualTo(5));
      expect(r.alternatives, isEmpty);
    });
  });
}
