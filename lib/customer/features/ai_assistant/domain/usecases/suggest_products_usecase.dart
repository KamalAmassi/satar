import 'package:dartz/dartz.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/utils/usecase.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/assistant_result.dart';
import 'package:project/customer/features/ai_assistant/domain/repositories/ai_assistant_repository.dart';

class SuggestProductsUseCase implements UseCase<AssistantResult, String> {
  const SuggestProductsUseCase(this._repository);

  final AiAssistantRepository _repository;

  @override
  Future<Either<Failure, AssistantResult>> call(String params) =>
      _repository.suggestFromText(params);
}