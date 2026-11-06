import 'package:dartz/dartz.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/intent.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/match_info.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/suggested_product.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/voice_turn.dart';

/// وسائط بحث الأداة: نوع المنتج وعبوة/مفرد وصفات ومرفوضات (يرتّب المحرك لا النموذج).
class VoiceSearchArgs {
  const VoiceSearchArgs({
    required this.productType,
    this.pack = PackMode.single,
    this.attributes = const {},
    this.mustNot = const [],
  });

  factory VoiceSearchArgs.fromJson(Map<String, dynamic> j) {
    final raw = j['attributes'];
    final attrs = <String, String>{
      if (raw is Map)
        for (final e in raw.entries)
          if ('${e.value}'.trim().isNotEmpty) '${e.key}': '${e.value}'.trim(),
    };
    final type = ('${j['product_type'] ?? ''}'.trim().isNotEmpty ? '${j['product_type']}' : '${j['query'] ?? ''}').trim();
    return VoiceSearchArgs(
      productType: type,
      pack: j['pack'] == 'pack' ? PackMode.pack : PackMode.single,
      attributes: attrs,
      mustNot: [for (final t in (j['must_not_terms'] as List? ?? const [])) '$t'],
    );
  }

  final String productType;
  final PackMode pack;
  final Map<String, String> attributes;
  final List<String> mustNot;
}

/// نتيجة محقَّقة من المحرك (الخطوتان B–C): ما يُنطق مصدره هذا فقط.
class VerifiedMatch {
  const VerifiedMatch({required this.product, required this.level, this.reason = ''});
  final SuggestedProduct product;
  final MatchLevel level;
  final String reason;
}

/// أدوات يستدعيها النموذج (Function Calling) وتُنفَّذ محليًا فقط.
abstract class VoiceTools {
  /// بحث محقَّق في الكتالوج الفعلي: exact (حتى 3) ثم close (حتى 2)، أو بدائل إن لم يوجد غيرها.
  Future<List<VerifiedMatch>> search(VoiceSearchArgs args);

  /// اقتراح صنف بعد موافقة المستخدم؛ يعيد false إن كان المعرّف غير صالح.
  bool propose(int productId, int quantity);
}

abstract class VoiceRepository {
  Future<Either<Failure, VoiceTurn>> runTurn(String userText, VoiceTools tools);
  void reset();
}
