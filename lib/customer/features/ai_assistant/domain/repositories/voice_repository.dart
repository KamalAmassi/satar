import 'package:dartz/dartz.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/suggested_product.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/voice_turn.dart';

/// أدوات يستدعيها النموذج (Function Calling) وتُنفَّذ محليًا فقط.
abstract class VoiceTools {
  /// بحث في الكتالوج الحقيقي (حتى 5 نتائج).
  Future<List<SuggestedProduct>> search(String query);

  /// اقتراح صنف بعد موافقة المستخدم؛ يعيد false إن كان المعرّف غير صالح.
  bool propose(int productId, int quantity);
}

abstract class VoiceRepository {
  Future<Either<Failure, VoiceTurn>> runTurn(String userText, VoiceTools tools);
  void reset();
}
