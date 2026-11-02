import 'package:dartz/dartz.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/utils/usecase.dart';
import 'package:project/driver/features/auth/domain/repositories/auth_repository.dart';

/// كلاس مخصص لتنفيذ عملية تسجيل الدخول للسائق كـ UseCase منفصل ومحدد
class LoginDriverUseCase implements UseCase<bool, LoginDriverParams> {
  final DriverAuthRepository repository;

  LoginDriverUseCase({required this.repository});

  @override
  Future<Either<Failure, bool>> call(LoginDriverParams params) async {
    return await repository.loginDriver(
      phone: params.phone,
      password: params.password,
    );
  }
}

class LoginDriverParams {
  final String phone;
  final String password;

  LoginDriverParams({required this.phone, required this.password});
}
