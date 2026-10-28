import 'package:equatable/equatable.dart';
import 'package:project/core/errors/api_error_codes.dart';
import 'package:equatable/equatable.dart';

/// الفشل الموحّد الذي تعيده طبقة data. الـ presentation لا تعرف Dio ولا JSON.
abstract class Failure extends Equatable {
  const Failure({this.message, this.code, this.statusCode});

  /// رسالة السيرفر (مترجمة حسب Accept-Language). null للأخطاء المحلية.
  final String? message;

  /// error.code القادم من السيرفر.
  final String? code;
  final int? statusCode;

  bool get isRetryable => false;
  bool get isBlocking =>
      code != null && ApiErrorCodes.blocking.contains(code);

  @override
  List<Object?> get props => [message, code, statusCode];
}

class ServerFailure extends Failure {
  const ServerFailure({
    super.message,
    super.code,
    super.statusCode,
    this.requestId,
    this.details,
  });

  final String? requestId;
  final Map<String, dynamic>? details;

  @override
  bool get isRetryable =>
      (statusCode != null && statusCode! >= 500) ||
          code == ApiErrorCodes.tooManyRequests ||
          code == ApiErrorCodes.chaosInjected;

  @override
  List<Object?> get props => [...super.props, requestId, details];
}

/// 422 validation_failed مع details.fields
class ValidationFailure extends Failure {
  const ValidationFailure({
    super.message,
    this.fieldErrors = const {},
  }) : super(code: ApiErrorCodes.validationFailed, statusCode: 422);

  /// اسم الحقل → رسالة الخطأ
  final Map<String, String> fieldErrors;

  @override
  List<Object?> get props => [...super.props, fieldErrors];
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

class CacheFailure extends Failure {
  const CacheFailure({super.message});
}

class UnknownFailure extends Failure {
  const UnknownFailure({super.message});
}