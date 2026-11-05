import 'package:dartz/dartz.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/utils/usecase.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/voice_turn.dart';
import 'package:project/customer/features/ai_assistant/domain/repositories/voice_repository.dart';

class VoiceTurnParams {
  const VoiceTurnParams(this.text, this.tools);
  final String text;
  final VoiceTools tools;
}

class RunVoiceTurnUseCase implements UseCase<VoiceTurn, VoiceTurnParams> {
  const RunVoiceTurnUseCase(this._repo);
  final VoiceRepository _repo;

  @override
  Future<Either<Failure, VoiceTurn>> call(VoiceTurnParams params) => _repo.runTurn(params.text, params.tools);

  void reset() => _repo.reset();
}
