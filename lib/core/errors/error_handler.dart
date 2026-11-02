import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/network/api_exception.dart';

/// يحوّل أخطاء طبقة الشبكة إلى Failure حتى لا تتعامل بقية الطبقات مع Dio.
abstract final class ErrorHandler {
  static Future<Either<Failure, T>> guard<T>(
    Future<T> Function() action,
  ) async {
    try {
      return Right(await action());
    } on ApiException catch (error) {
      return Left(fromApiException(error));
    } on DioException catch (error) {
      return Left(fromDio(error));
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return const Left(UnknownFailure(message: 'حدث خطأ غير متوقع.'));
    }
  }

  static Failure fromApiException(ApiException error) {
    if (error.statusCode == 401) {
      return UnauthorizedFailure(message: error.message);
    }

    if (error.statusCode == 422) {
      return ValidationFailure(
        message: error.message,
        fieldErrors: _parseFields(error.fields),
      );
    }

    if (error.statusCode == null) {
      return UnknownFailure(message: error.message);
    }

    return ServerFailure(
      message: error.message,
      code: error.code,
      statusCode: error.statusCode,
      requestId: error.requestId,
      details: error.fields,
    );
  }

  static Failure fromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const TimeoutFailure(message: 'انتهت مهلة الاتصال. حاول مرة أخرى.');
      case DioExceptionType.connectionError:
        return const NetworkFailure(message: 'تعذر الاتصال بالخادم. تحقق من الإنترنت.');
      case DioExceptionType.badResponse:
        return _fromResponse(error.response);
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        if (error.error is SocketException) return const NetworkFailure();
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
      message = data['message']?.toString();
      requestId = data['request_id']?.toString();
      final error = data['error'];
      if (error is Map) {
        code = error['code']?.toString();
        if (error['details'] is Map) {
          details = Map<String, dynamic>.from(error['details'] as Map);
        }
      }
    }

    if (status == 401) return UnauthorizedFailure(message: message);

    if (status == 422 || code == 'validation_failed') {
      return ValidationFailure(
        message: message,
        fieldErrors: _parseFields(details?['fields']),
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
