import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/otp/domain/otp_failures.dart';
import 'package:project/core/otp/domain/otp_gateway.dart';

/// Twilio Verify من جهة العميل — بوابة تحقق مؤقتة للتطوير والتعلّم فقط.
///
/// ⚠️ الإنتاج: يجب أن ينتقل send/verify إلى الخادم (الخادم حاليًا لا يعرف Twilio).
/// Auth Token لا يُشحن أبدًا داخل تطبيق منشور. هذا الصنف لا يسجّل أي مفتاح أو رقم.
///
/// يستخدم Dio خاصًا به (وليس عميل الفريق الموثّق) كي لا تختلط الترويسات.
class TwilioVerifyGateway implements OtpGateway {
  TwilioVerifyGateway({
    required String accountSid,
    required String authToken,
    required String serviceSid,
    Dio? dio,
  }) : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'https://verify.twilio.com/v2/Services/$serviceSid',
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              contentType: Headers.formUrlEncodedContentType,
              // نقرأ كل الحالات بأنفسنا لتحويل أخطاء Twilio بدقة.
              validateStatus: (_) => true,
            )) {
    // المصادقة تُضبط دائمًا (حتى مع Dio مُمرَّر للاختبار).
    _dio.options.headers['Authorization'] = 'Basic ${base64Encode(utf8.encode('$accountSid:$authToken'))}';
  }

  final Dio _dio;

  @override
  Future<Either<Failure, Unit>> send(String e164) => _call(
        '/Verifications',
        {'To': e164, 'Channel': 'sms'},
        ok: (status, body) => status == 201 && body['status'] == 'pending',
      );

  @override
  Future<Either<Failure, Unit>> verify(String e164, String code) => _call(
        '/VerificationCheck',
        {'To': e164, 'Code': code},
        ok: (status, body) => status == 200 && body['status'] == 'approved',
        // 200 مع pending (أو غيرها) ⇒ الرمز خاطئ.
        soft: (status, body) => status == 200 ? const OtpInvalidCode(statusCode: 200) : null,
      );

  Future<Either<Failure, Unit>> _call(
    String path,
    Map<String, String> form, {
    required bool Function(int status, Map<String, dynamic> body) ok,
    OtpFailure? Function(int status, Map<String, dynamic> body)? soft,
  }) async {
    try {
      final res = await _dio.post<dynamic>(path, data: form);
      final status = res.statusCode ?? 0;
      final body = _asMap(res.data);
      if (ok(status, body)) return const Right(unit);
      return Left(soft?.call(status, body) ?? mapTwilioError(status, body));
    } on DioException catch (e) {
      return Left(switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.connectionError =>
          const OtpNetwork(),
        _ => const OtpUnavailable(),
      });
    } catch (_) {
      return const Left(OtpUnavailable());
    }
  }

  static Map<String, dynamic> _asMap(Object? data) {
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is String && data.isNotEmpty) {
      try {
        final d = jsonDecode(data);
        if (d is Map) return Map<String, dynamic>.from(d);
      } catch (_) {}
    }
    return const {};
  }

  /// أكواد Twilio الموثّقة → إخفاقات المشروع.
  static const _tooMany = {60202, 60203, 20429};
  static const _phoneNotAllowed = {21608, 21211, 21614, 60200, 60205, 60410, 60605};

  static OtpFailure mapTwilioError(int status, Map<String, dynamic> body) {
    final code = (body['code'] as num?)?.toInt();
    if (code == 20404 || status == 404) return OtpExpired(statusCode: status);
    if (_tooMany.contains(code) || status == 429) return OtpTooManyAttempts(statusCode: status);
    if (_phoneNotAllowed.contains(code)) return OtpPhoneNotAllowed(statusCode: status);
    return OtpUnavailable(statusCode: status);
  }
}
