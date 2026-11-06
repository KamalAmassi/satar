// تقييم حي اختياري (مُعطَّل افتراضيًا). يعمل فقط مع:
//   flutter test test/customer/features/ai_assistant/live_eval_test.dart \
//     --dart-define=AI_LIVE_EVAL=true --dart-define=GEMINI_API_KEY=<dev key>
// يستخدم كتالوج fixtures المحلي، ويطبع الدقة لكل استعلام، ولا يطبع المفتاح أبدًا.
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/core/config/ai_config.dart';
import 'package:project/customer/features/ai_assistant/data/datasources/gemini_extractor.dart';
import 'package:project/customer/features/ai_assistant/data/matching/product_matcher.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/intent.dart';

import 'fixtures/catalog_fixture.dart';

const _enabled = bool.fromEnvironment('AI_LIVE_EVAL');

/// (استعلام، أسماء متوقعة داخل exact، أسماء ممنوعة داخل exact)
const _cases = <(String, List<String>, List<String>)>[
  ('ربطة دفاتر', ['ربطة', 'باكيت'], ['سلك', 'نوتة']),
  ('بدي ربطة دفاتر مدرسية', ['ربطة'], ['سلك', 'نوتة']),
  ('باكيت دفاتر مسطر', ['باكيت', 'ربطة'], ['سلك']),
  ('دفتر سلك', ['سلك'], ['ربطة']),
  ('دفتر سلك كبير A4', ['سلك'], []),
  ('نوتة', ['نوتة'], ['80 ورقة']),
  ('نوتات صغيرة', ['نوت'], []),
  ('دفترين', ['دفتر'], ['ربطة', 'باكيت']),
  ('دفتر مربعات', ['مربعات'], ['سلك']),
  ('3 اقلام ازرق', ['أزرق'], ['أحمر', 'أسود']),
  ('قلم احمر', ['أحمر'], ['أزرق']),
  ('قلم رصاص', ['رصاص'], ['حبر']),
  ('علبة اقلام رصاص ملون', ['ملون'], []),
  ('ممحاة', ['ممحاة'], []),
  ('مبراة', ['مبراة'], []),
  ('مسطرة', ['مسطرة'], []),
  ('مقص', ['مقص'], []),
  ('شنطة مدرسية', ['حقيبة'], []),
  ('حقيبة للصف الثالث', ['الثالث'], []),
  ('صمغ', ['صمغ'], []),
  ('ألوان خشبية', ['ألوان'], []),
  ('لعبة تعليمية', ['لعبة'], []),
  ('لعبة تركيب مكعبات', ['مكعبات'], []),
  ('بطاقة هدية', ['بطاقة'], []),
  ('كراسة رسم', ['كراسة'], []),
];

void main() {
  test('live precision (skipped unless AI_LIVE_EVAL + key)', () async {
    final extractor = GeminiRestExtractor(
      Dio(BaseOptions(baseUrl: AiConfig.geminiBaseUrl, headers: {'x-goog-api-key': AiConfig.geminiApiKey})),
    );
    final index = fixtureIndex();
    const matcher = ProductMatcher();
    var total = 0.0;
    for (final (q, want, forbid) in _cases) {
      final e = await extractor.fromText(q);
      final specs = [for (final r in e.requests) if (r.kind == IntentKind.specificItem && r.item != null) r.item!];
      final exact = [
        for (final s in specs) ...matcher.scorer.resolve(s, index).exact.map((m) => m.entry.product.name),
      ];
      final bad = exact.where((n) => forbid.any(n.contains)).length;
      final good = exact.where((n) => want.any(n.contains)).length;
      final precision = exact.isEmpty ? 0.0 : (exact.length - bad) / exact.length;
      total += precision;
      // ignore: avoid_print
      print('P=${precision.toStringAsFixed(2)} exact=${exact.length} wanted=$good forbidden=$bad  q="$q"');
    }
    // ignore: avoid_print
    print('mean precision = ${(total / _cases.length).toStringAsFixed(2)}');
  }, skip: !_enabled || !AiConfig.hasGeminiKey ? 'live eval disabled (set AI_LIVE_EVAL=true and GEMINI_API_KEY)' : false, timeout: const Timeout(Duration(minutes: 10)));
}
