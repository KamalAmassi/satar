import 'package:flutter_test/flutter_test.dart';
import 'package:project/customer/features/ai_assistant/data/matching/arabic_lexicon.dart';

import 'fixtures/catalog_fixture.dart';

void main() {
  group('Arabic normalization', () {
    test('أقلام/اقلام, ربطه/ربطة, دفاتر/دفتر, tashkeel', () {
      expect(ArabicLexicon.stems('أقلام'), ArabicLexicon.stems('اقلام'));
      expect(ArabicLexicon.stems('ربطه'), ArabicLexicon.stems('ربطة'));
      expect(ArabicLexicon.stems('دفاتر'), ArabicLexicon.stems('دفتر'));
      expect(ArabicLexicon.stems('الدفتر'), ArabicLexicon.stems('دفتر'));
      expect(ArabicLexicon.stems('دَفْتَر'), ArabicLexicon.stems('دفتر'));
      expect(ArabicLexicon.stems('دفترين'), ArabicLexicon.stems('دفتر'));
      expect(ArabicLexicon.stems('٣ اقلام'), ['3', 'قلم']);
    });
  });

  group('catalog index', () {
    final index = fixtureIndex();

    test('pack detection', () {
      bool pack(int id) => index.entries.firstWhere((e) => e.id == id).isPack;
      expect(pack(1), isTrue);
      expect(pack(3), isTrue);
      expect(pack(23), isTrue);
      expect(pack(5), isFalse);
      expect(pack(7), isFalse);
      expect(pack(20), isFalse);
    });

    test('candidates by head noun include name and category matches', () {
      final ids = index.candidates('دفاتر').map((c) => c.entry.id).toSet();
      expect(ids, containsAll([1, 5, 7, 9, 11]));
      expect(ids, contains(10)); // نوتة داخل فئة دفاتر
      expect(ids, isNot(contains(20)));
    });

    test('synonyms: شنطة finds حقائب', () {
      expect(index.candidates('شنطة').map((c) => c.entry.id), containsAll([34, 35, 52]));
    });
  });
}
