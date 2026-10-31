import 'package:dartz/dartz.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/assistant_result.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/audio_clip.dart';

abstract class AiAssistantRepository {
  Future<Either<Failure, AssistantResult>> suggestFromText(String text);

  Future<Either<Failure, AssistantResult>> suggestFromAudio(AudioClip clip);
}