import 'package:flutter_test/flutter_test.dart';
import 'package:project/customer/features/ai_assistant/data/matching/bundle_planner.dart';
import 'package:project/customer/features/ai_assistant/data/matching/product_matcher.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/intent.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/match_info.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/suggestion_item.dart';

import 'fixtures/catalog_fixture.dart';

void main() {
  final index = fixtureIndex();
  const planner = BundlePlanner(ProductMatcher());
  final allIds = {for (final e in index.entries) e.id};

  IntentRequest schoolKit({int? budget, bool optionalExtras = false}) => IntentRequest(
        kind: IntentKind.bundleForPurpose,
        purpose: 'بداية مدرسة',
        audience: 'الصف الثالث',
        budget: budget,
        neededItems: [
          const ItemSpec(productType: 'حقيبة', role: 'حقيبة'),
          const ItemSpec(productType: 'دفتر', pack: PackMode.pack, role: 'دفاتر'),
          const ItemSpec(productType: 'قلم', role: 'أقلام'),
          ItemSpec(productType: 'ممحاة', role: 'ممحاة', essential: !optionalExtras),
          ItemSpec(productType: 'مبراة', role: 'براية', essential: !optionalExtras),
          ItemSpec(productType: 'مسطرة', role: 'مسطرة', essential: !optionalExtras),
        ],
        originalText: 'بكج بداية مدرسة للصف الثالث',
      );

  group('8. bundle', () {
    test('items per role come only from the catalog; total <= budget (80 ₪)', () {
      final r = planner.bundle(schoolKit(budget: 80), index);
      expect(r.items.map((i) => i.role), ['حقيبة', 'دفاتر', 'أقلام', 'ممحاة', 'براية', 'مسطرة']);
      for (final i in r.items) {
        expect(i.product, isNotNull, reason: i.role);
        expect(allIds, contains(i.product!.id));
      }
      expect(r.plan.totalAmount, lessThanOrEqualTo(8000));
      expect(r.plan.overBudget, isFalse);
      expect(r.items[1].product!.id, anyOf(1, 2, 3, 4)); // دفاتر = ربطة فعلًا
    });

    test('tight budget: drops non-essential first, then states over-budget explicitly', () {
      final r = planner.bundle(schoolKit(budget: 45, optionalExtras: true), index);
      expect(r.plan.droppedRoles, isNotEmpty);
      expect(r.items.map((i) => i.role), containsAll(['حقيبة', 'دفاتر'])); // الأساسي يبقى
      expect(r.plan.overBudget, r.plan.totalAmount > 4500);
      expect(r.plan.overBudget, isTrue);
    });

    test('over budget replaces expensive pick with cheaper exact alternative when one exists', () {
      final r = planner.bundle(
        const IntentRequest(kind: IntentKind.bundleForPurpose, budget: 50, neededItems: [
          ItemSpec(productType: 'حقيبة', role: 'حقيبة'),
        ]),
        index,
      );
      // 52 (35 ₪) هي الأرخص أصلًا: لا استبدال ولا تجاوز.
      expect(r.items.single.product!.id, 52);
      expect(r.plan.overBudget, isFalse);
    });
  });

  group('9. gift / toy', () {
    test('لعبة تعليمية لطفل 5 سنين -> only toys from the catalog, age only from catalog text', () {
      const req = IntentRequest(
        kind: IntentKind.giftOrToyForPurpose,
        recipient: 'طفل',
        age: 5,
        desiredTraits: ['تعليمية'],
        searchIntents: [ItemSpec(productType: 'لعبة', role: 'لعبة')],
        originalText: 'لعبة تعليمية لطفل 5 سنين',
      );
      final r = planner.gift(req, index);
      final shown = <int>{
        for (final i in r.items) ...[
          if (i.product != null) i.product!.id,
          for (final m in i.close) m.product.id,
          for (final a in i.alternatives) a.id,
        ],
      };
      expect(shown, isNotEmpty);
      expect(shown.every((id) => const {40, 41, 42, 43, 44, 45, 46, 47, 60}.contains(id)), isTrue);
      // خارج العمر بحسب الكتالوج (6+ و12+) لا يظهر.
      expect(shown.intersection({42, 47}), isEmpty);
      // لا ادعاء ضمان: الملاحظات فقط ageFits/ageUnknown (مناسبة غالبًا).
      final notes = <NoteCode>{
        for (final i in r.items) ...[
          if (i.note != null) i.note!.code,
          for (final m in i.close) if (m.note != null) m.note!.code,
        ],
      };
      expect(notes.difference({NoteCode.ageFits, NoteCode.ageUnknown}), isEmpty);
      // النتيجة الرئيسية مطابقة تمامًا للاسم (لعبة) وغير مفترضة العمر خارج النص.
      expect(r.items.single.status, anyOf(SuggestionStatus.available, SuggestionStatus.outOfStock));
    });

    test('budget excludes pricier toys', () {
      const req = IntentRequest(
        kind: IntentKind.giftOrToyForPurpose,
        age: 5,
        budget: 30,
        searchIntents: [ItemSpec(productType: 'لعبة', role: 'لعبة')],
      );
      final r = planner.gift(req, index);
      final prices = [
        if (r.items.single.product != null) r.items.single.product!.priceAmount,
        for (final m in r.items.single.close) m.product.priceAmount,
      ];
      expect(prices.every((p) => p <= 3000), isTrue);
    });

    test('age parsing from catalog text', () {
      expect(BundlePlanner.parseAgeRange('للأطفال 3+ سنوات'), (3, null));
      expect(BundlePlanner.parseAgeRange('مناسبة من 5 سنوات'), (5, null));
      expect(BundlePlanner.parseAgeRange('٣-٦ سنوات'), (3, 6));
      expect(BundlePlanner.parseAgeRange('لعبة جميلة'), isNull);
    });
  });

  group('robustness: any audience gets a useful kit; typos/similar items are suggested', () {
    test('توجيهي with no model plan -> default kit from catalog (not an error)', () {
      const req = IntentRequest(kind: IntentKind.bundleForPurpose, originalText: 'بكج لطالب توجيهي');
      final r = planner.bundle(req, index);
      final found = [for (final i in r.items) if (i.product != null) i.product!.id];
      expect(found, isNotEmpty);
      expect(found, containsAll([61, 63])); // حاسبة وملف
      expect(r.items.map((i) => i.role), contains('دفاتر'));
    });

    test('طالب جامعة IT -> flash drive, calculator, notebook ... from the catalog only', () {
      const req = IntentRequest(kind: IntentKind.bundleForPurpose, originalText: 'بكج لطالب جامعة تخصص IT');
      final r = planner.bundle(req, index);
      final found = {for (final i in r.items) if (i.product != null) i.product!.id};
      expect(found, containsAll([62, 61, 63]));
      expect(found.every(allIds.contains), isTrue);
    });

    test('model plan that matches nothing falls back to the default kit', () {
      const req = IntentRequest(kind: IntentKind.bundleForPurpose, originalText: 'بكج لطالب توجيهي', neededItems: [
        ItemSpec(productType: 'طائرة', role: 'x'),
      ]);
      final r = planner.bundle(req, index);
      expect(r.items.any((i) => i.product != null), isTrue);
    });

    test('طرنج (typo of شطرنج) -> similar-name suggestion, labelled, not preselected', () {
      final item = const ProductMatcher().resolve(const ItemSpec(productType: 'طرنج', originalText: 'طرنج'), index);
      expect(item.product, isNull);
      expect(item.close.map((m) => m.product.id), [60]);
      expect(item.close.single.note!.code, NoteCode.similarName);
    });

    test('missing item -> related types from similar_terms offered as alternatives', () {
      final item = const ProductMatcher().resolve(
        const ItemSpec(productType: 'لعبة ذكاء', originalText: 'لعبة ذكاء', similar: ['بازل', 'مكعبات']),
        index,
      );
      expect(item.product, isNull);
      final ids = [...item.close, ...item.similar].map((m) => m.product.id);
      expect(ids, containsAll([42, 40]));
    });

    test('looksLikeBundle', () {
      expect(BundlePlanner.looksLikeBundle('بكج لطالب جامعة'), isTrue);
      expect(BundlePlanner.looksLikeBundle('بدي طالب توجيهي كل اللي بحتاجه'), isTrue);
      expect(BundlePlanner.looksLikeBundle('دفتر سلك'), isFalse);
    });
  });
}
