import 'package:dartz/dartz.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/utils/usecase.dart';
import 'package:project/welcome/domain/repositories/welcome_repository.dart';

class IsOnboardingSeenUseCase implements UseCase<bool, NoParams> {
  const IsOnboardingSeenUseCase(this._repository);

  final WelcomeRepository _repository;

  @override
  Future<Either<Failure, bool>> call(NoParams params) =>
      _repository.isOnboardingSeen();
}