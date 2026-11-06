import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/core/network/masar_model/masar_models.dart';
import 'package:project/customer/features/ai_assistant/data/datasources/catalog_remote_datasource.dart';
import 'package:project/customer/features/ai_assistant/data/datasources/gemini_extractor.dart';
import 'package:project/customer/features/ai_assistant/data/datasources/gemini_judge.dart';
import 'package:project/customer/features/ai_assistant/data/matching/product_matcher.dart';
import 'package:project/customer/features/ai_assistant/data/matching/request_parser.dart';
import 'package:project/customer/features/ai_assistant/data/repositories/ai_assistant_repository_impl.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/intent.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/match_info.dart';

import 'assistant_flows_test.dart' show FakeNet, content, product;
import 'fixtures/catalog_fixture.dart';

void main() {
  final index = fixtureIndex();
  final scorer = const ProductMatcher().scorer;
  const spec = ItemSpec(productType: 'دفتر', pack: PackMode.pack, originalText: 'ربطة دفاتر');
  final scored = scorer.score(spec, index);

  JudgeVerdict v(int id, MatchLevel l, [String r = '']) => JudgeVerdict(request: 0, id: id, level: l, reason: r);

  group('applyJudge guard', () {
    test('model cannot promote: close stays close, alternative stays alternative', () {
      final out = applyJudge(scored, [
        v(1, MatchLevel.exact), v(2, MatchLevel.exact), v(3, MatchLevel.exact), v(4, MatchLevel.exact),
        v(5, MatchLevel.exact), // 5 كان close (مفرد)
        v(7, MatchLevel.exact), // سلك: كان close
      ]);
      MatchLevel levelOf(int id) => out.firstWhere((m) => m.entry.id == id).level;
      expect(levelOf(5), MatchLevel.close);
      expect(levelOf(7), MatchLevel.close);
      expect(levelOf(1), MatchLevel.exact);
    });

    test('model can demote with reason; reject removes; unselected exact -> close', () {
      final out = applyJudge(scored, [
        v(1, MatchLevel.exact),
        v(2, MatchLevel.close, 'عدد دفاتر أكبر'),
        v(3, MatchLevel.reject),
      ]);
      final byId = {for (final m in out) m.entry.id: m};
      expect(byId[2]!.level, MatchLevel.close);
      expect(byId[2]!.note, const MatchNote(NoteCode.judged, 'عدد دفاتر أكبر'));
      expect(byId.containsKey(3), isFalse);
      expect(byId[4]!.level, MatchLevel.close); // لم يُختر
    });

    test('invented ids are ignored', () {
      final out = applyJudge(scored, [v(9999, MatchLevel.exact)]);
      expect(out.length, scored.length);
    });

    test('empty verdicts (judge failed) leave the deterministic result', () {
      expect(applyJudge(scored, const []), same(scored));
    });
  });

  group('call budget', () {
    AiAssistantRepositoryImpl repo(FakeNet net) {
      final g = Dio(BaseOptions(baseUrl: 'https://g.test'))..httpClientAdapter = net;
      final app = Dio(BaseOptions(baseUrl: 'https://api.test/api/'))..httpClientAdapter = net;
      return AiAssistantRepositoryImpl(
        CatalogRemoteDataSourceImpl(app),
        GeminiRestExtractor(g, hasKey: true),
        const RequestParser(),
        const ProductMatcher(),
        judge: GeminiRestJudge(g, hasKey: true),
      );
    }

    Map<String, dynamic> intent(String type) => content([
          {
            'text': jsonEncode({
              'transcript': 't',
              'unclear': false,
              'requests': [
                {
                  'kind': 'specific_item',
                  'original_text': type,
                  'item': {'product_type': type, 'pack': 'single', 'quantity': 1},
                },
              ],
            }),
          },
        ]);

    test('single exact -> judge skipped (1 model call)', () async {
      final net = FakeNet(gemini: [intent('دفتر')], catalog: [product(1, 'دفتر 80 ورقة'), product(2, 'قلم أزرق')]);
      final r = (await repo(net).suggestFromText('دفتر')).getOrElse(() => throw StateError('x'));
      expect(net.geminiBodies.length, 1);
      expect(r.items.single.product!.id, 1);
    });

    test('several exact -> exactly one judge call (2 total); verdict demotes', () async {
      final judgeReply = content([
        {
          'text': jsonEncode({
            'selected': [
              {'request': 0, 'id': 1, 'level': 'exact', 'reason': ''},
              {'request': 0, 'id': 2, 'level': 'close', 'reason': 'ثمانين ورقة فقط'},
              {'request': 0, 'id': 777, 'level': 'exact', 'reason': 'invented'},
            ],
          }),
        },
      ]);
      final net = FakeNet(gemini: [intent('دفتر'), judgeReply], catalog: [product(1, 'دفتر 80 ورقة'), product(2, 'دفتر 100 ورقة')]);
      final r = (await repo(net).suggestFromText('دفتر')).getOrElse(() => throw StateError('x'));
      expect(net.geminiBodies.length, 2);
      // الحكم ما يرى إلا معرّفات الكتالوج.
      final sent = jsonEncode(net.geminiBodies[1]);
      expect(sent.contains('777'), isFalse);
      expect(r.items.single.product!.id, 1);
      expect(r.items.single.close.map((m) => m.product.id), [2]);
      expect(r.items.single.close.single.note!.arg, 'ثمانين ورقة فقط');
    });

    test('judge failure (429) -> deterministic result still returned', () async {
      final net = FakeNet(gemini: [intent('دفتر')], catalog: [product(1, 'دفتر 80 ورقة'), product(2, 'دفتر 100 ورقة')]);
      // الحكم يحصل على نفس الرد (intent) فلا يُفهم كحكم: يُتجاهل بصمت.
      final r = (await repo(net).suggestFromText('دفتر')).getOrElse(() => throw StateError('x'));
      expect(r.items.single.product, isNotNull);
      expect(r.items.single.alternatives.length + 1, 2);
    });
  });

  test('Product import sanity', () => expect(Product, isNotNull));
}
