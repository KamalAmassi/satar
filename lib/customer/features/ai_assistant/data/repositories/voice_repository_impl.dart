import 'package:dartz/dartz.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/customer/features/ai_assistant/data/datasources/gemini_voice_datasource.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/voice_turn.dart';
import 'package:project/customer/features/ai_assistant/domain/failures/ai_failures.dart';
import 'package:project/customer/features/ai_assistant/domain/repositories/voice_repository.dart';

class VoiceRepositoryImpl implements VoiceRepository {
  VoiceRepositoryImpl(this._ds);
  final GeminiVoiceDataSource _ds;

  @override
  Future<Either<Failure, VoiceTurn>> runTurn(String userText, VoiceTools tools) async {
    try {
      final reply = await _ds.turn(userText, tools);
      return Right(VoiceTurn(userText: userText, reply: reply));
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return const Left(AiUnavailableFailure());
    }
  }

  @override
  void reset() => _ds.reset();
}
