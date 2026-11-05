import 'package:dio/dio.dart';
import 'package:project/core/config/ai_config.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/suggested_product.dart';
import 'package:project/customer/features/ai_assistant/domain/failures/ai_failures.dart';
import 'package:project/customer/features/ai_assistant/domain/repositories/voice_repository.dart';

/// محادثة صوتية متعددة الجولات مع Gemini + Function Calling (REST).
///
/// تنبيه أمان: المفتاح هنا على جهة العميل للتطوير فقط (dart-define عبر AiConfig)؛
/// في الإنتاج يجب تمرير الطلبات عبر الـ backend حتى لا يُكشف المفتاح.
/// لا نسجّل المفتاح ولا نص الكلام.
class GeminiVoiceDataSource {
  GeminiVoiceDataSource(this._dio, {bool? hasKey}) : _hasKey = hasKey ?? AiConfig.hasGeminiKey;

  final Dio _dio;
  final bool _hasKey;
  final List<Map<String, dynamic>> _history = [];

  static const maxRounds = 3;
  static const maxHistory = 16;

  static const systemPrompt = 'أنت "قلم"، المساعد الصوتي لمتجر سطر للكتب والقرطاسية والألعاب والهدايا والطباعة. '
      'تحدّث باللهجة الفلسطينية، بجمل قصيرة منطوقة فقط (12 كلمة كحد أقصى). '
      'ممنوع Markdown أو نقاط أو إيموجي أو رموز مثل * # - _ لأن القارئ الصوتي يقرؤها حرفيًا. '
      'لا تخترع منتجات أو أسعارًا أو توفرًا: استدعِ search_catalog دائمًا قبل ذكر أي منتج أو سعر، وقل فقط ما أرجعته. '
      'إن لم يوجد شيء مطابق قل ذلك واطلب وصفًا آخر. اسأل عن الكمية إن كانت ناقصة. '
      'أكّد مع المستخدم قبل استدعاء propose_item. لا تقل أبدًا إن الطلب تم؛ اطلب منه أن يقول "خلصت" ليراجع ويضيف للسلة. سؤال واحد فقط في كل مرة.';

  static const _tools = [
    {
      'functionDeclarations': [
        {
          'name': 'search_catalog',
          'description': 'البحث عن الكتب والقرطاسية والألعاب والهدايا في كتالوج متجر سطر',
          'parameters': {
            'type': 'OBJECT',
            'properties': {
              'query': {'type': 'STRING', 'description': 'ما يبحث عنه المستخدم'},
            },
            'required': ['query'],
          },
        },
        {
          'name': 'propose_item',
          'description': 'اقتراح صنف بعد موافقة المستخدم عليه فقط',
          'parameters': {
            'type': 'OBJECT',
            'properties': {
              'product_id': {'type': 'INTEGER'},
              'quantity': {'type': 'INTEGER'},
            },
            'required': ['product_id', 'quantity'],
          },
        },
      ],
    },
  ];

  void reset() => _history.clear();

  /// جولة كاملة: يعيد النص المنطوق النهائي. يرمي [AiQuotaFailure]/[AiUnavailableFailure].
  Future<String> turn(String userText, VoiceTools tools) async {
    if (!_hasKey) throw const AiUnavailableFailure();
    _history.add({
      'role': 'user',
      'parts': [
        {'text': userText},
      ],
    });
    _trim();
    for (var round = 0; round <= maxRounds; round++) {
      // بعد 3 جولات أدوات نطلب النص النهائي بلا أدوات.
      final useTools = round < maxRounds;
      final content = await _generate(useTools);
      final parts = ((content['parts'] as List?) ?? const []).cast<Map>();
      final calls = [
        for (final p in parts)
          if (p['functionCall'] is Map) Map<String, dynamic>.from(p['functionCall'] as Map),
      ];
      // المحتوى يُحفظ كما هو (مع thoughtSignature) كما تتطلب النماذج الأحدث.
      _history.add(content);
      if (calls.isEmpty || !useTools) {
        return stripMarkdown(parts.map((p) => p['text'] is String && p['thought'] != true ? p['text'] as String : '').join(' '));
      }
      final responses = <Map<String, dynamic>>[];
      for (final call in calls) {
        responses.add({
          'functionResponse': {'name': call['name'], 'response': await _execute(call, tools)},
        });
      }
      _history.add({'role': 'user', 'parts': responses});
    }
    return '';
  }

  Future<Map<String, dynamic>> _execute(Map<String, dynamic> call, VoiceTools tools) async {
    final args = Map<String, dynamic>.from((call['args'] as Map?) ?? const {});
    switch (call['name']) {
      case 'search_catalog':
        final List<SuggestedProduct> found = await tools.search('${args['query'] ?? ''}');
        return {
          'items': [
            for (final p in found.take(5)) {'id': p.id, 'name': p.name, 'price': p.priceLabel, 'available': p.isAvailable},
          ],
        };
      case 'propose_item':
        final id = (args['product_id'] as num?)?.toInt();
        final qty = (args['quantity'] as num?)?.toInt() ?? 1;
        final ok = id != null && tools.propose(id, qty);
        return {'ok': ok, if (!ok) 'error': 'unknown or unavailable product_id'};
      default:
        return {'error': 'unknown function'};
    }
  }

  Future<Map<String, dynamic>> _generate(bool useTools) async {
    final body = {
      'systemInstruction': {
        'parts': [
          {'text': systemPrompt},
        ],
      },
      'contents': _history,
      if (useTools) 'tools': _tools,
      'generationConfig': {'temperature': 0.6, 'maxOutputTokens': 300},
    };
    Object? last;
    for (final model in AiConfig.geminiModels) {
      try {
        final r = await _dio.post<dynamic>('/v1beta/models/$model:generateContent', data: body);
        final cands = (Map<String, dynamic>.from(r.data as Map)['candidates'] as List?) ?? const [];
        if (cands.isEmpty) throw const AiUnavailableFailure();
        final content = (cands.first as Map)['content'];
        if (content is! Map) throw const AiUnavailableFailure();
        return Map<String, dynamic>.from(content);
      } on DioException catch (e) {
        final code = e.response?.statusCode;
        last = code == 429 ? const AiQuotaFailure() : const AiUnavailableFailure();
        // أخطاء المفتاح/الطلب لا تتحسن بتغيير الموديل.
        if (code == 400 || code == 401 || code == 403) throw last;
      }
    }
    throw last ?? const AiUnavailableFailure();
  }

  /// نحتفظ بآخر ~16 رسالة ونبدأ دائمًا برسالة مستخدم نصية (لا بنتيجة أداة يتيمة).
  void _trim() {
    while (_history.length > maxHistory) {
      _history.removeAt(0);
    }
    while (_history.isNotEmpty && !_isUserText(_history.first)) {
      _history.removeAt(0);
    }
  }

  static bool _isUserText(Map<String, dynamic> c) =>
      c['role'] == 'user' && ((c['parts'] as List).first as Map).containsKey('text');

  static Dio buildDio() => Dio(BaseOptions(
        baseUrl: AiConfig.geminiBaseUrl,
        connectTimeout: const Duration(seconds: 25),
        receiveTimeout: const Duration(seconds: 25),
        sendTimeout: const Duration(seconds: 25),
        headers: {'Content-Type': 'application/json', 'x-goog-api-key': AiConfig.geminiApiKey},
      ));
}


/// يزيل رموز Markdown قبل النطق (لا يقرؤها TTS كحروف).
String stripMarkdown(String t) => t
    .replaceAll(RegExp(r'[*_`#>~]+'), '')
    .replaceAll(RegExp(r'^\s*[-•]\s+', multiLine: true), '')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();
