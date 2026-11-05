import 'package:project/core/errors/failure.dart';

/// إخفاقات التحقق برمز SMS (تمتد من Failure الخاص بالمشروع).
sealed class OtpFailure extends Failure {
  const OtpFailure({super.message, super.code, super.statusCode});
}

/// الرمز غير صحيح (Twilio: status = pending بعد التحقق).
class OtpInvalidCode extends OtpFailure {
  const OtpInvalidCode({super.statusCode}) : super(code: 'otp_invalid_code');
}

/// لا يوجد تحقق قائم: انتهى أو اكتمل (Twilio 404 / 20404).
class OtpExpired extends OtpFailure {
  const OtpExpired({super.statusCode}) : super(code: 'otp_expired');
}

/// محاولات كثيرة (429 / 60202 / 60203).
class OtpTooManyAttempts extends OtpFailure {
  const OtpTooManyAttempts({super.statusCode}) : super(code: 'otp_too_many_attempts');
}

/// لا يمكن الإرسال لهذا الرقم (رقم غير موثّق في الحساب التجريبي، صلاحيات جغرافية، رقم غير صالح).
class OtpPhoneNotAllowed extends OtpFailure {
  const OtpPhoneNotAllowed({super.statusCode}) : super(code: 'otp_phone_not_allowed');
}

/// لا اتصال أو انتهت المهلة.
class OtpNetwork extends OtpFailure {
  const OtpNetwork() : super(code: 'otp_network');
}

/// الخدمة غير متاحة (إعداد ناقص، مصادقة Twilio، خطأ خادم).
class OtpUnavailable extends OtpFailure {
  const OtpUnavailable({super.statusCode}) : super(code: 'otp_unavailable');
}
