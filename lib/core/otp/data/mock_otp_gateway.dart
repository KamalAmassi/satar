import 'package:dartz/dartz.dart';
import 'package:project/core/config/otp_config.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/otp/domain/otp_failures.dart';
import 'package:project/core/otp/domain/otp_gateway.dart';

/// بوابة تجريبية بلا شبكة: تقبل الرمز 1234 (للعرض والاختبارات والويب).
class MockOtpGateway implements OtpGateway {
  const MockOtpGateway();

  @override
  Future<Either<Failure, Unit>> send(String e164) async => const Right(unit);

  @override
  Future<Either<Failure, Unit>> verify(String e164, String code) async =>
      code == OtpConfig.mockCode ? const Right(unit) : const Left(OtpInvalidCode());
}

/// تُستخدم حين يُطلب Twilio في إصدار بلا مفاتيح: لا انهيار، رسالة "غير متاح".
class UnavailableOtpGateway implements OtpGateway {
  const UnavailableOtpGateway();

  @override
  Future<Either<Failure, Unit>> send(String e164) async => const Left(OtpUnavailable());

  @override
  Future<Either<Failure, Unit>> verify(String e164, String code) async => const Left(OtpUnavailable());
}
