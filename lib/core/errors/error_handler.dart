import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:project/core/errors/api_error_codes.dart';
import 'package:project/core/errors/failure.dart';

/// يحوّل أخطاء Dio إلى Failure. يُستخدم في RepositoryImpl فقط.
abstract final class ErrorHandler {
  /// غلاف جاهز: يُنفّذ العملية ويعيد Either.
  static Future<Either<Failure, T>> guard<T>(
    Future<T> Function() action,
  ) async {
    try {
      return Right(await action());
    } on DioException catch (e) {
      return Left(fromDio(e));
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  static Failure fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const TimeoutFailure();
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      case DioExceptionType.badResponse:
        return _fromResponse(e.response);
      case DioExceptionType.cancel:
        return const CancelledFailure();
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        if (e.error is Failure) return e.error as Failure;
        if (e.error is SocketException) return const NetworkFailure();
        return const UnknownFailure();
    }
  }

  static Failure _fromResponse(Response<dynamic>? response) {
    final status = response?.statusCode;
    final data = response?.data;

    String? message;
    String? code;
    String? requestId;
    Map<String, dynamic>? details;

    if (data is Map) {
      message = data['message'] as String?;
      requestId = data['request_id'] as String?;
      final error = data['error'];
      if (error is Map) {
        code = error['code'] as String?;
        if (error['details'] is Map) {
          details = Map<String, dynamic>.from(error['details'] as Map);
        }
      }
    }

    if (status == 401) return UnauthorizedFailure(message: message);

    // 422 وحدها لا تعني خطأ نموذج: out_of_stock و out_of_zone و
    // invalid_transition تصل أيضًا بـ 422 ويجب أن تحتفظ برمزها.
    if (code == ApiErrorCodes.validationFailed ||
        (status == 422 && code == null)) {
      return ValidationFailure(
        message: message,
        fieldErrors: _parseFields(details?['fields']),
        requestId: requestId,
        details: details,
      );
    }

    return ServerFailure(
      message: message,
      code: code,
      statusCode: status,
      requestId: requestId,
      details: details,
    );
  }

  static Map<String, String> _parseFields(Object? raw) {
    if (raw is! Map) return const {};
    return raw.map((key, value) {
      final text = value is List && value.isNotEmpty
          ? value.first.toString()
          : value.toString();
      return MapEntry(key.toString(), text);
    });
  }
}
