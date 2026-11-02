import 'package:dartz/dartz.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/driver/features/auth/domain/repositories/auth_repository.dart';

class LogoutDriverUseCase {
  LogoutDriverUseCase({required this.repository});

  final DriverAuthRepository repository;

  Future<Either<Failure, bool>> call() {
    return repository.logoutDriver();
  }
}
