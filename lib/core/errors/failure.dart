import 'package:equatable/equatable.dart';
import 'package:project/core/errors/api_error_codes.dart';

/// الفشل الموحّد الذي تعيده طبقة data. الـ presentation لا تعرف Dio ولا JSON.
abstract class Failure extends Equatable {
  const Failure({this.message, this.code, this.statusCode});

  /// رسالة السيرفر (مترجمة حسب Accept-Language). null للأخطاء المحلية.
  final String? message;

  /// error.code القادم من السيرفر.
  final String? code;
  final int? statusCode;

  /// error.details كما وصلت (مثل reason و available و allowed).
  Map<String, dynamic>? get details => null;

  /// error.details.reason إن وُجد (مثل quote_payload_mismatch).
  String? get reason => details?['reason'] as String?;

  /// لم يصل أي رد من الخادم: نتيجة أي طلب كتابة غير مؤكدة.
  bool get hasNoResponse => statusCode == null;

  bool get isRetryable => false;
  bool get isBlocking => code != null && ApiErrorCodes.blocking.contains(code);

  @override
  List<Object?> get props => [message, code, statusCode];
}

class ServerFailure extends Failure {
  const ServerFailure({
    super.message,
    super.code,
    super.statusCode,
    this.requestId,
    Map<String, dynamic>? details,
  }) : _details = details;

  final String? requestId;
  final Map<String, dynamic>? _details;

  @override
  Map<String, dynamic>? get details => _details;

  /// details.retry_after (ثوانٍ) مع 429 too_many_requests.
  int? get retryAfterSeconds {
    final raw = _details?['retry_after'];
    return raw is int ? raw : int.tryParse('$raw');
  }

  @override
  bool get isRetryable =>
      (statusCode != null && statusCode! >= 500) ||
      code == ApiErrorCodes.tooManyRequests ||
      code == ApiErrorCodes.chaosInjected;

  @override
  List<Object?> get props => [...super.props, requestId, _details];
}

/// 422 validation_failed مع details.fields
class ValidationFailure extends Failure {
  const ValidationFailure({
    super.message,
    this.fieldErrors = const {},
    this.requestId,
    Map<String, dynamic>? details,
  })  : _details = details,
        super(code: ApiErrorCodes.validationFailed, statusCode: 422);

  /// اسم الحقل → رسالة الخطأ (مثل print_items.0.print_page_range).
  final Map<String, String> fieldErrors;
  final String? requestId;
  final Map<String, dynamic>? _details;

  @override
  Map<String, dynamic>? get details => _details;

  /// أخطاء الحقول التي تبدأ بمسار معيّن، مثل 'print_items.1.'.
  Map<String, String> fieldsUnder(String prefix) => {
        for (final e in fieldErrors.entries)
          if (e.key.startsWith(prefix)) e.key.substring(prefix.length): e.value,
      };

  @override
  List<Object?> get props => [...super.props, fieldErrors, requestId];
}

/// 401 — التوكن مفقود أو منتهي: يجب العودة لشاشة الدخول.
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.message})
      : super(code: ApiErrorCodes.unauthenticated, statusCode: 401);
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message});

  @override
  bool get isRetryable => true;
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({super.message});

  @override
  bool get isRetryable => true;
}

/// أُلغي الطلب من التطبيق (مثل إلغاء رفع ملف).
class CancelledFailure extends Failure {
  const CancelledFailure();
}

class CacheFailure extends Failure {
  const CacheFailure({super.message});
}

class UnknownFailure extends Failure {
  const UnknownFailure({super.message});
}
