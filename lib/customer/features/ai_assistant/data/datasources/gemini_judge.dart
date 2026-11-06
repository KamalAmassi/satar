import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:project/core/config/ai_config.dart';
import 'package:project/customer/features/ai_assistant/data/matching/product_scorer.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/intent.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/match_info.dart';

/// طلب حكم واحد: الطلب المفهوم + مرشّحوه (حتى 40).
class JudgeRequest {
  const JudgeRequest({required this.index, required this.spec, required this.candidates});
  final int index;
  final ItemSpec spec;
  final List<ScoredMatch> candidates;
}

class JudgeVerdict {
  const JudgeVerdict({required this.request, required this.id, required this.level, required this.reason});
  final int request;
  final int id;
  final MatchLevel level;
  final String reason;
}

/// نداء حكم واحد لكل طلب مستخدم (يغطي كل الأصناف الملتبسة معًا). الفشل = تجاهل صامت.
abstract class GeminiJudge {
  Future<List<JudgeVerdict>> judge(List<JudgeRequest> requests);
}

class GeminiRestJudge implements GeminiJudge {
  GeminiRestJudge(this._dio, {bool? hasKey}) : _hasKey = hasKey ?? AiConfig.hasGeminiKey;

  final Dio _dio;
  final bool _hasKey;

  static const maxCandidates = 40;

  static const _systemPrompt = r'''
أنت حَكَم دقّة لمتجر "سطر". لكل طلب: نوع المنتج المطلوب وشروطه ثم قائمة منتجات بصيغة id|الاسم|الفئة|السعر|المخزون.
اختر من القائمة فقط، ولا تخترع معرّفات. أرجع لكل منتج تراه صالحاً level:
exact = يطابق النوع وكل الشروط الصريحة؛ close = النوع صحيح وصفة واحدة مختلفة أو غير مؤكدة؛ alternative = نفس الاستخدام لكن نوع مختلف؛ reject = خاطئ.
reason: سبب عربي من 6 كلمات كحد أقصى إن لم يكن exact.
"ربطة" = عبوة عدة وحدات. "دفتر سلك" نوع مختلف عن الدفتر العادي. "نوتة" ليست دفتراً مدرسياً. لا تضع منتجاً في exact إن خالف شرطاً صريحاً.
''';

  static const _schema = {
    'type': 'OBJECT',
    'properties': {
      'selected': {
        'type': 'ARRAY',
        'items': {
          'type': 'OBJECT',
          'properties': {
            'request': {'type': 'INTEGER'},
            'id': {'type': 'INTEGER'},
            'level': {
              'type': 'STRING',
              'enum': ['exact', 'close', 'alternative', 'reject'],
            },
            'reason': {'type': 'STRING'},
          },
          'required': ['request', 'id', 'level'],
        },
      },
    },
    'required': ['selected'],
  };

  static String describe(JudgeRequest r) {
    final s = r.spec;
    final b = StringBuffer('طلب ${r.index}: النوع=${s.productType}، ${s.pack == PackMode.pack ? 'عبوة' : 'مفرد'}');
    if (s.attributes.isNotEmpty) b.write('، الصفات=${s.attributes.entries.map((e) => '${e.key}:${e.value}').join(',')}');
    if (s.mustHave.isNotEmpty) b.write('، يجب=${s.mustHave.join(',')}');
    if (s.mustNot.isNotEmpty) b.write('، ممنوع=${s.mustNot.join(',')}');
    b.writeln();
    for (final m in r.candidates.take(maxCandidates)) {
      final e = m.entry;
      b.writeln('${e.id}|${e.product.name}|${e.categoryName}|${e.product.price.formatted}|${e.available ? 'متوفر' : 'نفد'}');
    }
    return b.toString();
  }

  @override
  Future<List<JudgeVerdict>> judge(List<JudgeRequest> requests) async {
    if (!_hasKey || requests.isEmpty) return const [];
    final body = {
      'systemInstruction': {
        'parts': [
          {'text': _systemPrompt},
        ],
      },
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': requests.map(describe).join('\n')},
          ],
        },
      ],
      'generationConfig': {'temperature': 0, 'responseMimeType': 'application/json', 'responseSchema': _schema},
    };
    for (final model in AiConfig.geminiModels) {
      try {
        final r = await _dio.post<dynamic>('/v1beta/models/$model:generateContent', data: body);
        return _parse(r.data);
      } on DioException catch (e) {
        final code = e.response?.statusCode;
        if (code == 400 || code == 401 || code == 403) return const [];
      } catch (_) {
        return const [];
      }
    }
    return const [];
  }

  List<JudgeVerdict> _parse(dynamic data) {
    try {
      final cands = (Map<String, dynamic>.from(data as Map)['candidates'] as List?) ?? const [];
      if (cands.isEmpty) return const [];
      final parts = (((cands.first as Map)['content'] as Map?)?['parts'] as List?) ?? const [];
      final text = parts.map((p) => (p as Map)['text'] ?? '').join();
      final json = Map<String, dynamic>.from(jsonDecode(text) as Map);
      return [
        for (final e in (json['selected'] as List? ?? const []))
          if (e is Map && e['request'] is num && e['id'] is num)
            JudgeVerdict(
              request: (e['request'] as num).toInt(),
              id: (e['id'] as num).toInt(),
              level: _level(e['level']),
              reason: ('${e['reason'] ?? ''}').trim(),
            ),
      ];
    } catch (_) {
      return const [];
    }
  }

  static MatchLevel _level(Object? v) => switch (v) {
        'exact' => MatchLevel.exact,
        'close' => MatchLevel.close,
        'alternative' => MatchLevel.alternative,
        _ => MatchLevel.reject,
      };
}

/// دمج الحكم مع النتيجة الحتمية: لا ترقية أبدًا؛ فقط تثبيت أو تخفيض.
/// exact غير مختار = close (يبقى ظاهرًا لكن غير مُحدَّد مسبقًا). reject = يُحذف.
/// الأصناف خارج القائمة المرسلة لا تتغير، ومعرّفات غير موجودة تُتجاهل.
List<ScoredMatch> applyJudge(List<ScoredMatch> scored, List<JudgeVerdict> verdicts, {int maxCandidates = GeminiRestJudge.maxCandidates}) {
  if (verdicts.isEmpty) return scored;
  final sent = scored.take(maxCandidates).map((m) => m.entry.id).toSet();
  final byId = <int, JudgeVerdict>{for (final v in verdicts) if (sent.contains(v.id)) v.id: v};
  if (byId.isEmpty) return scored;

  final out = <ScoredMatch>[];
  for (final m in scored) {
    if (!sent.contains(m.entry.id)) {
      out.add(m);
      continue;
    }
    final v = byId[m.entry.id];
    var level = m.level;
    if (v == null) {
      if (level == MatchLevel.exact) level = MatchLevel.close;
      out.add(level == m.level ? m : m.withLevel(level));
      continue;
    }
    if (v.level == MatchLevel.reject) continue;
    if (v.level.index > level.index) level = v.level;
    if (level == m.level) {
      out.add(m);
    } else {
      out.add(m.withLevel(level, MatchNote(NoteCode.judged, v.reason)));
    }
  }
  out.sort((a, b) {
    final byLevel = a.level.index.compareTo(b.level.index);
    return byLevel != 0 ? byLevel : b.score.compareTo(a.score);
  });
  return out;
}
