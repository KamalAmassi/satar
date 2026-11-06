import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/customer/features/ai_assistant/data/datasources/catalog_remote_datasource.dart';
import 'package:project/customer/features/ai_assistant/data/datasources/gemini_extractor.dart';
import 'package:project/customer/features/ai_assistant/data/matching/product_matcher.dart';
import 'package:project/customer/features/ai_assistant/data/matching/request_parser.dart';
import 'package:project/customer/features/ai_assistant/data/repositories/ai_assistant_repository_impl.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/intent.dart';
import 'package:project/customer/features/ai_assistant/domain/failures/ai_failures.dart';

import 'assistant_flows_test.dart' show FakeNet, content, product;

GeminiRestExtractor extractor(FakeNet net) =>
    GeminiRestExtractor(Dio(BaseOptions(baseUrl: 'https://g.test'))..httpClientAdapter = net, hasKey: true);

Map<String, dynamic> reply(Map<String, dynamic> json) => content([
      {'text': jsonEncode(json)},
    ]);

void main() {
  clarificationFlow();
  test('specific item with pack, attributes and must_not parses', () async {
    final net = FakeNet(gemini: [
      reply({
        'transcript': 'ربطة دفاتر',
        'unclear': false,
        'requests': [
          {
            'kind': 'specific_item',
            'original_text': 'ربطة دفاتر',
            'item': {
              'product_type': 'دفتر',
              'pack': 'pack',
              'quantity': 1,
              'ruling': 'مسطر',
              'must_not_terms': ['سلك', 'نوتة'],
            },
          },
        ],
      }),
    ]);
    final e = await extractor(net).fromText('ربطة دفاتر');
    final item = e.requests.single.item!;
    expect(e.requests.single.kind, IntentKind.specificItem);
    expect(item.pack, PackMode.pack);
    expect(item.attributes, {'ruling': 'مسطر'});
    expect(item.mustNot, ['سلك', 'نوتة']);
    expect(e.clarification, isNull);
  });

  test('clarification_needed parses; fewer than 2 options is dropped', () async {
    final net = FakeNet(gemini: [
      reply({
        'transcript': 'دفاتر',
        'unclear': false,
        'requests': <dynamic>[],
        'clarification_needed': {
          'question': 'أي نوع دفاتر؟',
          'options': ['مدرسية عادية', 'سلك', 'نوتة'],
        },
      }),
      reply({
        'transcript': 'x',
        'unclear': false,
        'requests': <dynamic>[],
        'clarification_needed': {'question': 'سؤال', 'options': ['واحد']},
      }),
    ]);
    final ex = extractor(net);
    final a = await ex.fromText('دفاتر');
    expect(a.clarification!.options.length, 3);
    final b = await ex.fromText('x');
    expect(b.clarification, isNull);
  });

  test('bundle and gift requests parse', () async {
    final net = FakeNet(gemini: [
      reply({
        'transcript': 't',
        'unclear': false,
        'requests': [
          {
            'kind': 'bundle_for_purpose',
            'original_text': 'بكج',
            'purpose': 'بداية مدرسة',
            'budget': 80,
            'needed_items': [
              {'product_type': 'حقيبة', 'pack': 'single', 'quantity': 1, 'role': 'حقيبة'},
              {'product_type': 'دفتر', 'pack': 'pack', 'quantity': 1, 'role': 'دفاتر', 'essential': false},
            ],
          },
          {
            'kind': 'gift_or_toy_for_purpose',
            'original_text': 'لعبة',
            'age': 5,
            'search_intents': [
              {'product_type': 'لعبة', 'pack': 'single', 'quantity': 1},
            ],
          },
        ],
      }),
    ]);
    final e = await extractor(net).fromText('t');
    expect(e.requests[0].budget, 80);
    expect(e.requests[0].neededItems.length, 2);
    expect(e.requests[0].neededItems[1].essential, isFalse);
    expect(e.requests[1].age, 5);
    expect(e.requests[1].searchIntents.single.productType, 'لعبة');
  });

  test('429 on all models -> AiQuotaFailure', () async {
    expect(extractor(FakeNet(geminiStatus: 429)).fromText('x'), throwsA(isA<AiQuotaFailure>()));
  });
}

// ---- repository-level clarification flow (mocked Gemini, no network) ----
void clarificationFlow() {
  test('clarification_needed with no searchable request -> result carries question + options, no items', () async {
    final net = FakeNet(gemini: [
      reply({
        'transcript': 'دفاتر',
        'unclear': false,
        'requests': <dynamic>[],
        'clarification_needed': {
          'question': 'أي نوع دفاتر؟',
          'options': ['مدرسية عادية', 'سلك', 'نوتة'],
        },
      }),
    ]);
    final g = Dio(BaseOptions(baseUrl: 'https://g.test'))..httpClientAdapter = net;
    final app = Dio(BaseOptions(baseUrl: 'https://api.test/api/'))..httpClientAdapter = net;
    final repo = AiAssistantRepositoryImpl(CatalogRemoteDataSourceImpl(app), GeminiRestExtractor(g, hasKey: true), const RequestParser(), const ProductMatcher());
    final r = (await repo.suggestFromText('دفاتر')).getOrElse(() => throw StateError('x'));
    expect(r.items, isEmpty);
    expect(r.unclear, isFalse);
    expect(r.clarification!.options, ['مدرسية عادية', 'سلك', 'نوتة']);
    expect(net.geminiBodies.length, 1); // سؤال التوضيح لا يستهلك نداءً ثانيًا
    expect(net.catalogQueries, isEmpty); // ولا يحمّل الكتالوج
  });

  test('model says unclear for a bundle request -> safety net builds a default kit (no "could not understand")', () async {
    final net = FakeNet(
      gemini: [reply({'transcript': 'بكج لطالب جامعة IT', 'unclear': true, 'requests': <dynamic>[]})],
      catalog: [product(1, 'دفتر 80 ورقة'), product(2, 'فلاشة 32GB'), product(3, 'قلم أزرق')],
    );
    final g = Dio(BaseOptions(baseUrl: 'https://g.test'))..httpClientAdapter = net;
    final app = Dio(BaseOptions(baseUrl: 'https://api.test/api/'))..httpClientAdapter = net;
    final repo = AiAssistantRepositoryImpl(CatalogRemoteDataSourceImpl(app), GeminiRestExtractor(g, hasKey: true), const RequestParser(), const ProductMatcher());
    final r = (await repo.suggestFromText('بكج لطالب جامعة IT')).getOrElse(() => throw StateError('x'));
    expect(r.unclear, isFalse);
    expect(r.plan, isNotNull);
    expect(r.items.where((i) => i.product != null).map((i) => i.product!.id), containsAll([1, 2, 3]));
  });
}
