import 'package:dartz/dartz.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/utils/usecase.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/assistant_result.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/audio_clip.dart';
import 'package:project/customer/features/ai_assistant/domain/repositories/ai_assistant_repository.dart';

class SuggestFromAudioUseCase implements UseCase<AssistantResult, AudioClip> {
  const SuggestFromAudioUseCase(this._repository);

  final AiAssistantRepository _repository;

  @override
  Future<Either<Failure, AssistantResult>> call(AudioClip params) =>
      _repository.suggestFromAudio(params);
}