import 'package:flutter/foundation.dart';

enum OtpMode { twilio, mock, unavailable }

/// إعداد بوابة التحقق برمز SMS.
///
/// القيم تُمرَّر وقت البناء كبقية إعدادات المشروع (لا يقرأ التطبيق ملف .env):
///   flutter run --dart-define-from-file=config/dev.json
/// المفاتيح: OTP_ENABLED, OTP_MODE (twilio | mock), TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN,
/// TWILIO_VERIFY_SERVICE_SID, OTP_DEFAULT_COUNTRY_CODE, OTP_CODE_LENGTH.
///
/// ⚠️ للتطوير والتعلّم فقط: أي قيمة تُمرَّر بـ dart-define (أو تُضمَّن كملف) تصبح جزءًا من التطبيق
/// ويمكن استخراجها. في الإنتاج يجب نقل الإرسال والتحقق إلى الخادم، ولا يُشحن Twilio Auth Token أبدًا.
abstract final class OtpConfig {
  /// مفتاح الإيقاف الفوري: false ⇒ لا بوابة OTP إضافية (السلوك السابق تمامًا).
  static const bool enabled = bool.fromEnvironment('OTP_ENABLED');

  static const String requestedMode = String.fromEnvironment('OTP_MODE', defaultValue: 'mock');
  static const String _accountSid = String.fromEnvironment('TWILIO_ACCOUNT_SID');
  static const String _authToken = String.fromEnvironment('TWILIO_AUTH_TOKEN');
  static const String _serviceSid = String.fromEnvironment('TWILIO_VERIFY_SERVICE_SID');
  static const String defaultCountryCode = String.fromEnvironment('OTP_DEFAULT_COUNTRY_CODE', defaultValue: '+970');
  static const int _twilioCodeLength = int.fromEnvironment('OTP_CODE_LENGTH', defaultValue: 6);

  /// مهلة إعادة الإرسال (سياسة، ليست رمز حركة).
  static const Duration resendCooldown = Duration(seconds: 60);

  /// رمز البوابة التجريبية.
  static const String mockCode = '1234';

  static bool get hasTwilioKeys => _accountSid.isNotEmpty && _authToken.isNotEmpty && _serviceSid.isNotEmpty;

  static String get accountSid => _accountSid;
  static String get authToken => _authToken;
  static String get serviceSid => _serviceSid;

  /// الوضع الفعلي. Twilio بلا مفاتيح (أو على الويب حيث يمنع CORS الاستدعاء):
  /// وضع تجريبي في debug، وغير متاح في الإصدار — لا انهيار في الحالتين.
  static OtpMode get mode {
    if (requestedMode != 'twilio') return OtpMode.mock;
    if (hasTwilioKeys && !kIsWeb) return OtpMode.twilio;
    return kDebugMode ? OtpMode.mock : OtpMode.unavailable;
  }

  /// طُلب Twilio لكننا نعمل بالتجريبي (لرسالة للمطورين فقط).
  static bool get usingDevFallback => requestedMode == 'twilio' && mode == OtpMode.mock;

  static int get codeLength => mode == OtpMode.mock ? mockCode.length : _twilioCodeLength.clamp(4, 10);
}
