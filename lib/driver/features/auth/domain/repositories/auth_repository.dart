import 'package:dartz/dartz.dart';
import 'package:project/core/errors/failure.dart';

abstract class DriverAuthRepository {
  Future<Either<Failure, bool>> loginDriver({
    required String phone,
    required String password,
  });

  Future<Either<Failure, bool>> logoutDriver();
}
