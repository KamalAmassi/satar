import 'package:dartz/dartz.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/utils/usecase.dart';
import 'package:project/welcome/domain/repositories/welcome_repository.dart';

class CompleteOnboardingUseCase implements UseCase<Unit, NoParams> {
  const CompleteOnboardingUseCase(this._repository);

  final WelcomeRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(NoParams params) =>
      _repository.completeOnboarding();
}