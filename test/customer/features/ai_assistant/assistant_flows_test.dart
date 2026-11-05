import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/network/api_client.dart';
import 'package:project/core/services/stt_service.dart';
import 'package:project/core/services/tts_service.dart';
import 'package:project/core/storage/session_store.dart';
import 'package:project/customer/features/ai_assistant/data/datasources/catalog_remote_datasource.dart';
import 'package:project/customer/features/ai_assistant/data/datasources/gemini_extractor.dart';
import 'package:project/customer/features/ai_assistant/data/datasources/gemini_voice_datasource.dart';
import 'package:project/customer/features/ai_assistant/data/matching/product_matcher.dart';
import 'package:project/customer/features/ai_assistant/data/matching/request_parser.dart';
import 'package:project/customer/features/ai_assistant/data/repositories/ai_assistant_repository_impl.dart';
import 'package:project/customer/features/ai_assistant/data/repositories/voice_repository_impl.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/audio_clip.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/suggested_product.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/suggestion_item.dart';
import 'package:project/customer/features/ai_assistant/domain/failures/ai_failures.dart';
import 'package:project/customer/features/ai_assistant/domain/repositories/voice_repository.dart';
import 'package:project/customer/features/ai_assistant/domain/usecases/run_voice_turn_usecase.dart';
import 'package:project/customer/features/ai_assistant/domain/usecases/suggest_from_audio_usecase.dart';
import 'package:project/customer/features/ai_assistant/domain/usecases/suggest_products_usecase.dart';
import 'package:project/customer/features/ai_assistant/presentation/bindings/voice_binding.dart';
import 'package:project/customer/features/ai_assistant/presentation/controllers/voice_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'voice_test.dart' show FakeStt, FakeTts;

/// محوّل HTTP وهمي: لا شبكة ولا مفتاح. يوجّه حسب المسار.
class FakeNet implements HttpClientAdapter {
  FakeNet({this.gemini = const [], this.catalog = const [], this.geminiStatus = 200, this.networkError = false});
  final List<Map<String, dynamic>> gemini;
  final List<Map<String, dynamic>> catalog;
  final int geminiStatus;
  final bool networkError;
  final geminiBodies = <Map<String, dynamic>>[];
  final catalogQueries = <Map<String, dynamic>>[];
  var _g = 0;

  static final _json = {
    Headers.contentTypeHeader: [Headers.jsonContentType]
  };

  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<List<int>>? s, Future<void>? c) async {
    if (networkError) throw DioException(requestOptions: o, type: DioExceptionType.connectionError);
    if (o.path.contains(':generateContent')) {
      geminiBodies.add(jsonDecode(jsonEncode(o.data)) as Map<String, dynamic>);
      if (geminiStatus != 200) return ResponseBody.fromString('{}', geminiStatus, headers: _json);
      final r = gemini[_g < gemini.length - 1 ? _g++ : _g];
      return ResponseBody.fromString(jsonEncode(r), 200, headers: _json);
    }
    if (o.path.contains('v1/products')) {
      catalogQueries.add(Map<String, dynamic>.from(o.queryParameters));
      return ResponseBody.fromString(jsonEncode({'success': true, 'message': 'ok', 'data': catalog, 'meta': <String, dynamic>{}, 'request_id': 'r'}), 200, headers: _json);
    }
    return ResponseBody.fromString('{}', 404, headers: _json);
  }

  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> product(int id, String name, {bool inStock = true}) => {
      'id': id,
      'name': name,
      'price': {'amount': 500, 'formatted': '5.00 ₪'},
      'in_stock': inStock,
      'stock': inStock ? 50 : 0,
      'options': <dynamic>[],
      'fields': <String, dynamic>{},
    };

Map<String, dynamic> content(List<Map<String, dynamic>> parts) => {
      'candidates': [
        {
          'content': {'role': 'model', 'parts': parts},
        },
      ],
    };

Map<String, dynamic> extraction() => content([
      {
        'text': jsonEncode({
          'transcript': 'بدي دفترين وقلم أزرق',
          'unclear': false,
          'items': [
            {'name': 'دفتر', 'quantity': 2, 'kind': 'product', 'search_terms': ['دفتر', 'دفاتر']},
            {'name': 'قلم أزرق', 'quantity': 1, 'kind': 'product', 'search_terms': ['قلم أزرق', 'قلم']},
          ],
        }),
      },
    ]);

final catalog = [
  product(1, 'دفتر 80 ورقة'),
  product(2, 'قلم أزرق', inStock: false),
  product(3, 'قلم رصاص'),
];

AiAssistantRepositoryImpl repo(FakeNet net) {
  final gemini = Dio(BaseOptions(baseUrl: 'https://g.test'))..httpClientAdapter = net;
  final app = Dio(BaseOptions(baseUrl: 'https://api.test/api/'))..httpClientAdapter = net;
  return AiAssistantRepositoryImpl(CatalogRemoteDataSourceImpl(app), GeminiRestExtractor(gemini, hasKey: true), const RequestParser(), const ProductMatcher());
}

class _Tools implements VoiceTools {
  _Tools(this.onSearch);
  final void Function() onSearch;
  @override
  bool propose(int id, int q) => false;
  @override
  Future<List<SuggestedProduct>> search(String q) async {
    onSearch();
    return [const SuggestedProduct(id: 1, name: 'دفتر 80 ورقة', priceAmount: 500, priceLabel: '5.00 ₪', inStock: true)];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('1. text flow', () {
    test('Arabic request -> matched items with quantities, unavailable item has alternative', () async {
      final net = FakeNet(gemini: [extraction()], catalog: catalog);
      final res = await SuggestProductsUseCase(repo(net))('بدي دفترين وقلم أزرق');
      final r = res.getOrElse(() => throw StateError('expected Right'));
      expect(r.unclear, isFalse);
      expect(r.items.length, 2);
      final notebook = r.items.firstWhere((i) => i.product?.id == 1);
      expect(notebook.quantity, 2);
      expect(notebook.status, SuggestionStatus.available);
      final pen = r.items.firstWhere((i) => i.requestText.contains('قلم'));
      expect(pen.status, SuggestionStatus.outOfStock);
      expect(pen.alternatives.map((a) => a.id), contains(3));
      expect(net.catalogQueries, isNotEmpty);
      expect(net.catalogQueries.every((q) => !q.containsKey('page')), isTrue);
    });
  });

  group('2. voice message flow', () {
    test('audio/wav inlineData base64 is sent and parsed like text', () async {
      final net = FakeNet(gemini: [extraction()], catalog: catalog);
      final bytes = Uint8List.fromList(List.generate(64, (i) => i));
      final res = await SuggestFromAudioUseCase(repo(net))(AudioClip(bytes: bytes, mimeType: 'audio/wav'));
      final r = res.getOrElse(() => throw StateError('expected Right'));
      expect(r.items.firstWhere((i) => i.product?.id == 1).quantity, 2);
      final parts = (net.geminiBodies.first['contents'] as List).first['parts'] as List;
      final inline = (parts.firstWhere((p) => (p as Map).containsKey('inlineData')) as Map)['inlineData'] as Map;
      expect(inline['mimeType'], 'audio/wav');
      expect(inline['data'], base64Encode(bytes));
    });
  });

  group('3. voice conversation', () {
    test('search_catalog once, then plain text without Markdown; history verbatim', () async {
      final net = FakeNet(gemini: [
        content([
          {
            'functionCall': {
              'name': 'search_catalog',
              'args': {'query': 'دفتر'}
            },
            'thoughtSignature': 'sig1'
          },
        ]),
        content([
          {'text': '**لقيت** دفتر 80 ورقة، `بخمسة` شيكل.'},
        ]),
      ]);
      var searches = 0;
      final ds = GeminiVoiceDataSource(Dio()..httpClientAdapter = net, hasKey: true);
      final reply = await ds.turn('بدي دفتر', _Tools(() => searches++));
      expect(searches, 1);
      expect(reply, 'لقيت دفتر 80 ورقة، بخمسة شيكل.');
      expect(reply.contains(RegExp(r'[*_`#]')), isFalse);
      final last = jsonEncode(net.geminiBodies.last['contents']);
      expect(last, contains('thoughtSignature'));
      expect(last, contains('functionResponse'));
    });

    test('state machine: listening -> thinking -> speaking -> listening; STT off while speaking', () async {
      final net = FakeNet(gemini: [
        content([
          {'text': 'تمام، لقيت دفتر'},
        ]),
      ]);
      final stt = FakeStt();
      final tts = FakeTts(stt);
      final c = VoiceController(
        stt: stt,
        tts: tts,
        runTurn: RunVoiceTurnUseCase(VoiceRepositoryImpl(GeminiVoiceDataSource(Dio()..httpClientAdapter = net, hasKey: true))),
        searchCatalog: (_) async => [],
        requestMic: () async => true,
        echoGuard: Duration.zero,
      );
      final states = <VoiceState>[];
      ever(c.state, states.add);
      await c.start();
      stt.say('بدي دفتر');
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(states, containsAllInOrder([VoiceState.thinking, VoiceState.speaking, VoiceState.listening]));
      expect(tts.listeningDuringSpeak, everyElement(isFalse));
      c.onClose();
    });
  });

  group('5. error paths', () {
    test('429 on all models -> AiQuotaFailure (extractor)', () async {
      final gemini = Dio(BaseOptions(baseUrl: 'https://g.test'))..httpClientAdapter = FakeNet(geminiStatus: 429);
      await expectLater(GeminiRestExtractor(gemini, hasKey: true).fromText('x'), throwsA(isA<AiQuotaFailure>()));
    });

    test('network error: repository does not throw', () async {
      final res = await repo(FakeNet(networkError: true)).suggestFromText('بدي دفتر');
      res.fold((f) => expect(f, isA<Failure>()), (_) {});
    });

    test('voice: quota -> AiQuotaFailure, network -> AiUnavailableFailure (Left, no throw)', () async {
      VoiceRepository mk(FakeNet n) => VoiceRepositoryImpl(GeminiVoiceDataSource(Dio()..httpClientAdapter = n, hasKey: true));
      final r1 = await mk(FakeNet(geminiStatus: 429)).runTurn('x', _Tools(() {}));
      expect(r1.swap().getOrElse(() => const UnknownFailure()), isA<AiQuotaFailure>());
      final r2 = await mk(FakeNet(networkError: true)).runTurn('x', _Tools(() {}));
      expect(r2.swap().getOrElse(() => const UnknownFailure()), isA<AiUnavailableFailure>());
    });

    test('controller survives a failed turn and returns to listening', () async {
      final stt = FakeStt();
      final tts = FakeTts(stt);
      final c = VoiceController(
        stt: stt,
        tts: tts,
        runTurn: RunVoiceTurnUseCase(VoiceRepositoryImpl(GeminiVoiceDataSource(Dio()..httpClientAdapter = FakeNet(geminiStatus: 429), hasKey: true))),
        searchCatalog: (_) async => [],
        requestMic: () async => true,
        echoGuard: Duration.zero,
      );
      await c.start();
      stt.say('بدي دفتر');
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(c.state.value, VoiceState.listening);
      expect(tts.spoken.length, 2); // الترحيب + رسالة الحصة
      c.onClose();
    });
  });

  group('4. bindings smoke', () {
    test('VoiceBinding resolves VoiceController and its dependencies', () async {
      SharedPreferences.setMockInitialValues({});
      Get.reset();
      final session = Get.put(SessionStore(await SharedPreferences.getInstance()));
      Get.put(ApiClient(session));
      VoiceBinding().dependencies();
      expect(Get.find<SttService>(), isNotNull);
      expect(Get.find<TtsService>(), isNotNull);
      expect(Get.find<VoiceController>(), isNotNull);
      Get.reset();
    });
  });
}
