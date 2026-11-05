import 'package:dartz/dartz.dart';
import 'package:project/core/errors/failure.dart';

/// بوابة التحقق برمز SMS. الأرقام بصيغة E.164 دائمًا (+970599123456).
abstract class OtpGateway {
  Future<Either<Failure, Unit>> send(String e164);
  Future<Either<Failure, Unit>> verify(String e164, String code);
}
