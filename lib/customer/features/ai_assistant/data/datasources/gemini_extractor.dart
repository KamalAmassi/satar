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
  GeminiRestExtractor(this._dio);

  /// Dio منفصل عن الـ Dio الخاص بالسيرفر (لا نرسل X-Project-Key لـ Google).
  final Dio _dio;

  static const _systemPrompt = r'''
أنت محرّك استخراج طلبات لمتجر "سطر" (قرطاسية، كتب، ألعاب، هدايا، طباعة) في فلسطين.
المدخل: كلام أو نص بالعربية (غالباً لهجة شامية/فلسطينية) فيه أصناف يريد الزبون شراءها.
مهمتك: استخراج الأصناف والكميات فقط، وإرجاع JSON حسب المخطط دون أي نص آخر.
القواعد:
- لا تخترع أصنافاً ولا تضف شيئاً لم يُذكر. لا أسعار ولا توصيات.
- افصل الأصناف عند: "و"، "مع"، "كمان"، الفواصل، الأرقام.
- الكمية: أرقام أو كلمات (ثلاث، خمسة...) أو المثنى (دفترين = 2). الافتراضي 1.
- "ربطة/علبة/باكيت" جزء من اسم الصنف، لا تحوّلها لكمية.
- احتفظ بتفاصيل الصنف (اللون، الحجم، اسم الكتاب بين علامتي تنصيص إن وُجد) داخل name.
- search_terms: من 3 إلى 6 صيغ بحث (مفرد، جمع، مرادف، إملاء بديل) لتسهيل المطابقة مع كتالوج المنتجات.
- الطباعة (مثل "طباعة A4") kind="print"، وما عداها "product".
- transcript: النص المسموع منظّفاً من الحشو، بالعربية.
- إذا الصوت غير مفهوم أو لا علاقة له بالتسوق: items فارغة و unclear=true.
- quantity رقم صحيح دائماً.
''';

  static const _schema = {
    'type': 'OBJECT',
    'properties': {
      'transcript': {'type': 'STRING'},
      'unclear': {'type': 'BOOLEAN'},
      'items': {
        'type': 'ARRAY',
        'items': {
          'type': 'OBJECT',
          'properties': {
            'name': {'type': 'STRING'},
            'quantity': {'type': 'INTEGER'},
            'kind': {
              'type': 'STRING',
              'enum': ['product', 'print'],
            },
            'search_terms': {
              'type': 'ARRAY',
              'items': {'type': 'STRING'},
            },
          },
          'required': ['name', 'quantity', 'kind', 'search_terms'],
        },
      },
    },
    'required': ['transcript', 'unclear', 'items'],
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
    if (!AiConfig.hasGeminiKey) throw const AiUnavailableFailure();

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