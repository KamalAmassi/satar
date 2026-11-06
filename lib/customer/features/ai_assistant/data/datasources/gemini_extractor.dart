import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:project/core/config/ai_config.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/customer/features/ai_assistant/data/models/extraction_model.dart';
import 'package:project/customer/features/ai_assistant/domain/failures/ai_failures.dart';

abstract class GeminiExtractor {
  Future<ExtractionModel> fromText(String text);

  Future<ExtractionModel> fromAudio(Uint8List bytes, String mimeType);
}

class GeminiRestExtractor implements GeminiExtractor {
  GeminiRestExtractor(this._dio, {bool? hasKey}) : _hasKey = hasKey ?? AiConfig.hasGeminiKey;

  final Dio _dio;
  final bool _hasKey;

  static const _systemPrompt = r'''
أنت محرّك "فهم الطلب" لمتجر "سطر" (قرطاسية، كتب، ألعاب، هدايا، طباعة) في فلسطين.
المدخل: كلام أو نص بالعربية (لهجة شامية/فلسطينية). افهم ماذا يريد الزبون فعلاً ثم أرجع JSON حسب المخطط فقط.
لا تخترع منتجات أو أسعاراً. لا تبحث ولا توصِ: فقط افهم وهيكل الطلب.

أنواع الطلب (kind):
- specific_item: صنف محدد. املأ item.
- bundle_for_purpose: "بكج/كل اللي بدي إياه لـ..." (مثل بداية مدرسة). املأ purpose وaudience وage (إن ذُكر الصف/العمر) وbudget بالشيكل، وخطة needed_items من 3 إلى 8 أصناف، لكل منها role (مثل: حقيبة، دفاتر، أقلام، ممحاة، براية، مسطرة) وessential.
- gift_or_toy_for_purpose: لعبة/هدية لشخص أو مناسبة. املأ recipient وage وoccasion وinterests وbudget وdesired_traits (تعليمية، إبداعية، هادئة...) وsearch_intents من 2 إلى 4 (كل منها product_type + صفات).
- question: سؤال عام لا يطلب منتجاً. unclear: غير مفهوم أو لا علاقة له بالتسوق.

قواعد المفردات:
- "ربطة/باكيت/باكت/طقم/دزينة/علبة" = عبوة من عدة وحدات، فاجعل pack="pack". غير ذلك pack="single".
- product_type هو الاسم الرئيسي المفرد فقط (دفتر، قلم، مقص، حقيبة) بلا صفات ولا كلمة العبوة.
- "دفتر سلك" = دفتر حلزوني/سلك، وهو غير دفتر عادي أو ربطة دفاتر عادية. ضع "سلك" في ruling.
- "نوتة/نوتات" = دفتر ملاحظات صغير وليس دفتراً مدرسياً. product_type="نوتة".
- "كراسة" = كراسة مدرسية. "بكج" = حزمة/طقم متكامل.
- الأرقام والمثنى كمية: دفترين = 2، ثلاث أقلام = 3. الافتراضي 1.
- الصفات: size، pages (عدد الأوراق)، ruling (مسطر/مربعات/سلك/خياطة)، color، brand، grade (الصف). اتركها فارغة إن لم تُذكر.
- must_have_terms: كلمات يجب أن تظهر. must_not_terms: كلمات تجعل النتيجة خاطئة. مثال: لـ"ربطة دفاتر" ضع must_not_terms=["سلك","نوتة","ملاحظات"] ما لم يطلبها الزبون صراحة. لـ"دفتر عادي" كذلك.
- افصل الأصناف المتعددة إلى requests منفصلة (عند "و"، "مع"، "كمان"، الفواصل).
- الطباعة (مثل "طباعة A4") اجعلها specific_item مع is_print=true.
- original_text: عبارة الزبون لهذا الطلب بلا حشو. transcript: النص المسموع كاملاً منظّفاً.

التوضيح (clarification_needed): املأه فقط إن كان النقص سيغيّر النتائج فعلاً (مثل "دفاتر" فقط: مدرسية عادية أم سلك أم نوتة؟ أو لعبة بلا عمر). سؤال واحد قصير بالعربية مع 2 إلى 4 خيارات قصيرة. إن كان الطلب واضحاً كفاية فلا تسأل.
''';

  static const _itemSchema = {
    'type': 'OBJECT',
    'properties': {
      'product_type': {'type': 'STRING'},
      'pack': {
        'type': 'STRING',
        'enum': ['single', 'pack'],
      },
      'quantity': {'type': 'INTEGER'},
      'size': {'type': 'STRING'},
      'pages': {'type': 'STRING'},
      'ruling': {'type': 'STRING'},
      'color': {'type': 'STRING'},
      'brand': {'type': 'STRING'},
      'grade': {'type': 'STRING'},
      'must_have_terms': {
        'type': 'ARRAY',
        'items': {'type': 'STRING'},
      },
      'must_not_terms': {
        'type': 'ARRAY',
        'items': {'type': 'STRING'},
      },
      'original_text': {'type': 'STRING'},
      'role': {'type': 'STRING'},
      'essential': {'type': 'BOOLEAN'},
      'is_print': {'type': 'BOOLEAN'},
    },
    'required': ['product_type', 'pack', 'quantity'],
  };

  static const _schema = {
    'type': 'OBJECT',
    'properties': {
      'transcript': {'type': 'STRING'},
      'unclear': {'type': 'BOOLEAN'},
      'requests': {
        'type': 'ARRAY',
        'items': {
          'type': 'OBJECT',
          'properties': {
            'kind': {
              'type': 'STRING',
              'enum': ['specific_item', 'bundle_for_purpose', 'gift_or_toy_for_purpose', 'question', 'unclear'],
            },
            'original_text': {'type': 'STRING'},
            'item': _itemSchema,
            'purpose': {'type': 'STRING'},
            'audience': {'type': 'STRING'},
            'age': {'type': 'INTEGER'},
            'budget': {'type': 'INTEGER'},
            'needed_items': {'type': 'ARRAY', 'items': _itemSchema},
            'recipient': {'type': 'STRING'},
            'occasion': {'type': 'STRING'},
            'interests': {
              'type': 'ARRAY',
              'items': {'type': 'STRING'},
            },
            'desired_traits': {
              'type': 'ARRAY',
              'items': {'type': 'STRING'},
            },
            'search_intents': {'type': 'ARRAY', 'items': _itemSchema},
          },
          'required': ['kind', 'original_text'],
        },
      },
      'clarification_needed': {
        'type': 'OBJECT',
        'properties': {
          'question': {'type': 'STRING'},
          'options': {
            'type': 'ARRAY',
            'items': {'type': 'STRING'},
          },
        },
      },
    },
    'required': ['transcript', 'unclear', 'requests'],
  };

  @override
  Future<ExtractionModel> fromText(String text) => _generate([
    {'text': text},
  ]);

  @override
  Future<ExtractionModel> fromAudio(Uint8List bytes, String mimeType) =>
      _generate([
        {'text': 'استخرج طلب الزبون من هذا التسجيل الصوتي.'},
        {
          'inlineData': {'mimeType': mimeType, 'data': base64Encode(bytes)},
        },
      ]);

  Future<ExtractionModel> _generate(List<Map<String, dynamic>> parts) async {
    if (!_hasKey) throw const AiUnavailableFailure();

    final body = {
      'systemInstruction': {
        'parts': [
          {'text': _systemPrompt},
        ],
      },
      'contents': [
        {'role': 'user', 'parts': parts},
      ],
      'generationConfig': {
        'temperature': 0,
        'responseMimeType': 'application/json',
        'responseSchema': _schema,
      },
    };

    Failure? lastFailure;
    for (final model in AiConfig.geminiModels) {
      try {
        return await _callModel(model, body);
      } on DioException catch (e) {
        lastFailure = _mapError(e);
        // أخطاء المفتاح أو الطلب نفسها بتتكرر مع كل الموديلات: لا فايدة من الانتقال.
        if (!_shouldTryNextModel(e)) throw lastFailure;
      }
    }
    throw lastFailure ?? const AiUnavailableFailure();
  }

  /// نداء واحد لموديل واحد، مع إعادة محاولة واحدة عند خطأ عابر.
  Future<ExtractionModel> _callModel(
      String model,
      Map<String, dynamic> body,
      ) async {
    for (var attempt = 1;; attempt++) {
      try {
        final response = await _dio.post<dynamic>(
          '/v1beta/models/$model:generateContent',
          data: body,
        );
        return _parse(response.data);
      } on DioException catch (e) {
        if (attempt < 2 && _isTransient(e)) continue;
        rethrow;
      }
    }
  }

  ExtractionModel _parse(dynamic data) {
    try {
      final map = Map<String, dynamic>.from(data as Map);
      final candidates = map['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        return const ExtractionModel.unclear();
      }
      final content = (candidates.first as Map)['content'] as Map?;
      final parts = (content?['parts'] as List<dynamic>?) ?? const [];
      final text = parts.map((p) => (p as Map)['text'] ?? '').join();
      if (text.trim().isEmpty) return const ExtractionModel.unclear();
      return ExtractionModel.fromJson(
        Map<String, dynamic>.from(jsonDecode(text) as Map),
      );
    } catch (_) {
      throw const AiUnavailableFailure();
    }
  }

  bool _isTimeout(DioException e) =>
      e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout;

  bool _isTransient(DioException e) {
    final status = e.response?.statusCode;
    return _isTimeout(e) ||
        e.type == DioExceptionType.connectionError ||
        (status != null && status >= 500);
  }

  /// الموديل غير موجود (404)، الحصة خلصت (429)، مشغول (5xx)، أو انتهت المهلة.
  bool _shouldTryNextModel(DioException e) {
    final status = e.response?.statusCode;
    return status == 404 ||
        status == 429 ||
        (status != null && status >= 500) ||
        _isTimeout(e);
  }

  Failure _mapError(DioException e) {
    final status = e.response?.statusCode;
    if (status == 429) return const AiQuotaFailure();
    if (_isTimeout(e)) return const TimeoutFailure();
    if (e.type == DioExceptionType.connectionError) {
      return const NetworkFailure();
    }
    return const AiUnavailableFailure();
  }
}