import 'package:dartz/dartz.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/welcome/data/datasources/welcome_local_datasource.dart';
import 'package:project/welcome/domain/repositories/welcome_repository.dart';

class WelcomeRepositoryImpl implements WelcomeRepository {
  const WelcomeRepositoryImpl(this._local);

  final WelcomeLocalDataSource _local;

  @override
  Future<Either<Failure, bool>> isOnboardingSeen() async {
    try {
      return Right(_local.isOnboardingSeen());
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> completeOnboarding() async {
    try {
      await _local.setOnboardingSeen();
      return const Right(unit);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }
}