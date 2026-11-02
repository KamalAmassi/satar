import 'package:dartz/dartz.dart';
import 'package:project/core/errors/error_handler.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/network/api_exception.dart';
import 'package:project/core/network/token_storage.dart';
import 'package:project/driver/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:project/driver/features/auth/domain/repositories/auth_repository.dart';

class DriverAuthRepositoryImpl implements DriverAuthRepository {
  DriverAuthRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
  });

  final DriverAuthRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;

  @override
  Future<Either<Failure, bool>> loginDriver({
    required String phone,
    required String password,
  }) {
    return ErrorHandler.guard(() async {
      final responseData = await remoteDataSource.loginDriver(
        phone: phone,
        password: password,
      );

      // Postman collection يؤكد أن التوكن موجود داخل data.token.
      final token = responseData['token']?.toString();
      if (token == null || token.trim().isEmpty) {
        throw const ApiException(
          message: 'تم تسجيل الدخول لكن الخادم لم يُرجع رمز الدخول.',
        );
      }

      await tokenStorage.saveToken(token);
      return true;
    });
  }

  @override
  Future<Either<Failure, bool>> logoutDriver() async {
    try {
      await remoteDataSource.logoutDriver();
      await tokenStorage.clearToken();
      return const Right(true);
    } catch (error) {
      // نمسح التوكن محلياً حتى لو فشل طلب تسجيل الخروج بسبب انقطاع الإنترنت.
      await tokenStorage.clearToken();
      return Left(error is ApiException
          ? ErrorHandler.fromApiException(error)
          : ServerFailure(message: error.toString()));
    }
  }
}
