import 'package:dartz/dartz.dart';
import 'package:project/core/errors/failure.dart';

abstract class WelcomeRepository {
  Future<Either<Failure, bool>> isOnboardingSeen();
  Future<Either<Failure, Unit>> completeOnboarding();
}