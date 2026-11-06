import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/services/stt_service.dart';
import 'package:project/core/services/tts_service.dart';
import 'package:project/customer/features/ai_assistant/data/datasources/gemini_voice_datasource.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/intent.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/match_info.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/suggested_product.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/voice_turn.dart';
import 'package:project/customer/features/ai_assistant/domain/repositories/voice_repository.dart';
import 'package:project/customer/features/ai_assistant/domain/usecases/run_voice_turn_usecase.dart';
import 'package:project/customer/features/ai_assistant/presentation/controllers/voice_controller.dart';

class FakeStt extends SttService {
  final events = <String>[];
  void Function(String)? _fin;
  void Function()? _empty;

  @override
  Future<bool> initialize() async => true;

  @override
  Future<void> listen({void Function(String)? onPartial, required void Function(String) onFinal, void Function(double)? onSoundLevel, required void Function() onEmpty}) async {
    events.add('listen');
    listening = true;
    _fin = onFinal;
    _empty = onEmpty;
  }

  void say(String t) {
    listening = false;
    _fin!(t);
  }

  void silence() {
    listening = false;
    _empty!();
  }

  @override
  Future<void> cancel() async {
    events.add('cancel');
    listening = false;
  }

  @override
  Future<void> stop() async => listening = false;

  @override
  void onClose() {}
}

class FakeTts extends TtsService {
  FakeTts(this.stt);
  final FakeStt stt;
  final listeningDuringSpeak = <bool>[];
  final spoken = <String>[];

  @override
  Future<bool> init() async => true;

  @override
  Future<void> speak(String text) async {
    listeningDuringSpeak.add(stt.listening);
    spoken.add(text);
    await Future<void>.delayed(Duration.zero);
  }

  @override
  Future<void> stop() async {}

  @override
  void onClose() {}
}

class FakeRepo implements VoiceRepository {
  @override
  Future<Either<Failure, VoiceTurn>> runTurn(String t, VoiceTools tools) async => Right(VoiceTurn(userText: t, reply: 'رد'));
  @override
  void reset() {}
}

SuggestedProduct prod(int id, {bool inStock = true}) => SuggestedProduct(id: id, name: 'دفتر $id', priceAmount: 500, priceLabel: '5.00 ₪', inStock: inStock);

VoiceController make(FakeStt stt, FakeTts tts, {List<MatchedProduct>? catalog}) => VoiceController(
      stt: stt,
      tts: tts,
      runTurn: RunVoiceTurnUseCase(FakeRepo()),
      searchCatalog: (_) async => catalog ?? [MatchedProduct(product: prod(1), level: MatchLevel.exact), MatchedProduct(product: prod(2, inStock: false), level: MatchLevel.close, note: const MatchNote(NoteCode.singleNotPack))],
      requestMic: () async => true,
      echoGuard: Duration.zero,
    );

Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 20));

class _Adapter implements HttpClientAdapter {
  _Adapter(this.responses);
  final List<Map<String, dynamic>> responses;
  final bodies = <Map<String, dynamic>>[];
  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<List<int>>? s, Future<void>? c) async {
    bodies.add(jsonDecode(jsonEncode(o.data)) as Map<String, dynamic>);
    final r = responses.removeAt(0);
    return ResponseBody.fromString(jsonEncode(r), 200, headers: {Headers.contentTypeHeader: [Headers.jsonContentType]});
  }

  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> _call(String name, Map<String, dynamic> args) => {
      'candidates': [
        {
          'content': {
            'role': 'model',
            'parts': [
              {'functionCall': {'name': name, 'args': args}, 'thoughtSignature': 'sig'},
            ],
          },
        },
      ],
    };

Map<String, dynamic> _text(String t) => {
      'candidates': [
        {
          'content': {
            'role': 'model',
            'parts': [
              {'text': t},
            ],
          },
        },
      ],
    };

class _Tools implements VoiceTools {
  final proposed = <int>[];
  @override
  bool propose(int id, int q) {
    final ok = id == 1;
    if (ok) proposed.add(id);
    return ok;
  }

  @override
  Future<List<VerifiedMatch>> search(VoiceSearchArgs a) async {
    lastArgs = a;
    return [VerifiedMatch(product: prod(1), level: MatchLevel.exact)];
  }

  VoiceSearchArgs? lastArgs;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('finish phrases are detected after Arabic normalization', () {
    for (final p in ['خلصت', 'خَلاص', 'إنهاء', 'كفاية', 'تمام خلصت', 'كفايه']) {
      expect(VoiceController.isFinishPhrase(p), isTrue, reason: p);
    }
    expect(VoiceController.isFinishPhrase('بدي دفتر ٨٠ ورقة'), isFalse);
    expect(VoiceController.isFinishPhrase('بدي دفتر ثمانين ورقة وقلم وممحاة كفايه'), isFalse); // جملة طويلة
  });

  test('STT is never active while TTS speaks', () async {
    final stt = FakeStt();
    final tts = FakeTts(stt);
    final c = make(stt, tts);
    await c.start();
    expect(c.state.value, VoiceState.listening);
    stt.say('بدي دفتر');
    await settle();
    expect(tts.spoken.length, 2); // الترحيب + الرد
    expect(tts.listeningDuringSpeak, everyElement(isFalse));
    expect(c.state.value, VoiceState.listening); // عاد للاستماع بعد النطق
    c.onClose();
  });

  test('3 empty rounds pause the loop', () async {
    final stt = FakeStt();
    final c = make(stt, FakeTts(stt));
    await c.start();
    for (var i = 0; i < VoiceController.maxEmptyRounds; i++) {
      stt.silence();
      await Future<void>.delayed(const Duration(milliseconds: 260));
    }
    expect(c.paused.value, isTrue);
    expect(c.state.value, VoiceState.idle);
    c.onClose();
  });

  test('finish phrase opens review and stops listening', () async {
    final stt = FakeStt();
    final c = make(stt, FakeTts(stt));
    await c.start();
    stt.say('خلصت');
    await settle();
    expect(c.finishTick.value, 1);
    expect(stt.listening, isFalse);
    c.onClose();
  });

  test('proposals validate id, clamp quantity and merge duplicates', () async {
    final stt = FakeStt();
    final c = make(stt, FakeTts(stt));
    expect(c.propose(1, 2), isFalse); // لم يُبحث عنه بعد
    await c.search(const VoiceSearchArgs(productType: 'دفتر'));
    expect(c.propose(99, 1), isFalse);
    expect(c.propose(2, 1), isFalse); // غير متوفر
    expect(c.propose(1, 2), isTrue);
    expect(c.propose(1, 500), isTrue);
    expect(c.proposals.length, 1);
    expect(c.proposals.single.quantity, 20);
    c.onClose();
  });

  test('function-call loop: tools executed, history sent verbatim, max rounds', () async {
    final adapter = _Adapter([
      _call('search_catalog', {'product_type': 'دفتر', 'pack': 'pack', 'attributes': {'ruling': 'مسطر'}, 'must_not_terms': ['سلك']}),
      _call('propose_item', {'product_id': 1, 'quantity': 2}),
      _call('propose_item', {'product_id': 7, 'quantity': 1}),
      _text('تمام'),
    ]);
    final dio = Dio()..httpClientAdapter = adapter;
    final ds = GeminiVoiceDataSource(dio, hasKey: true);
    final tools = _Tools();
    final reply = await ds.turn('بدي دفتر', tools);
    expect(reply, 'تمام');
    expect(adapter.bodies.length, 4);
    expect(tools.proposed, [1]); // id=7 رُفض
    expect(tools.lastArgs!.pack, PackMode.pack);
    expect(tools.lastArgs!.attributes, {'ruling': 'مسطر'});
    expect(tools.lastArgs!.mustNot, ['سلك']);
    // نتيجة الأداة تحمل المستوى المحقَّق، ولا تُرتّب خارج المحرك.
    expect(jsonEncode(adapter.bodies[1]['contents']), contains('match_level'));
    expect(adapter.bodies.last.containsKey('tools'), isFalse);
    expect(jsonEncode(adapter.bodies.last['contents']), contains('thoughtSignature'));
  });
}
