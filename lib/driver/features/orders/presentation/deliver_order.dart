import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:project/core/errors/api_error_codes.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/data/models.dart';

class DeliveryCodeInvalid extends Failure {
  const DeliveryCodeInvalid({super.message, super.code}) : super(statusCode: 422);
}

class DeliveryTooManyAttempts extends Failure {
  const DeliveryTooManyAttempts({super.message, super.code, this.retryAfterSeconds}) : super(statusCode: 429);
  final int? retryAfterSeconds;
}

class DeliveryInvalidState extends Failure {
  const DeliveryInvalidState({super.message, super.code, super.statusCode});
}

typedef DeliverCall = Future<Either<Failure, DriverOrderModel?>> Function(int id, {String? otp, List<int>? uploadIds, required String key});
typedef CurrentCall = Future<Either<Failure, DriverOrderModel?>> Function();

const _doneStatuses = {'delivered', 'completed'};

bool isValidDeliveryCode(String otp) => RegExp(r'^\d{4,8}$').hasMatch(otp);

Failure mapDeliverFailure(Failure f) {
  if (f is NetworkFailure || f is TimeoutFailure || f is UnauthorizedFailure || f.code == ApiErrorCodes.unauthenticated) return f;
  final code = f.code ?? '';
  if (f.statusCode == 429 || code == ApiErrorCodes.tooManyRequests || code.contains('attempt')) {
    return DeliveryTooManyAttempts(message: f.message, code: f.code, retryAfterSeconds: f is ServerFailure ? f.retryAfterSeconds : null);
  }
  if (f.statusCode == 409 || f.statusCode == 404 || code == ApiErrorCodes.invalidTransition || code == ApiErrorCodes.conflict || code == ApiErrorCodes.notFound) {
    return DeliveryInvalidState(message: f.message, code: f.code, statusCode: f.statusCode);
  }
  if (f.statusCode == 422 || f is ValidationFailure || code == ApiErrorCodes.otpInvalid || code == ApiErrorCodes.otpExpired || code.contains('otp') || code.contains('code')) {
    return DeliveryCodeInvalid(message: f.message, code: f.code);
  }
  return f;
}

class DeliverOrderUseCase {
  DeliverOrderUseCase({required DeliverCall deliver, required CurrentCall current})
      : _deliver = deliver,
        _current = current;
  final DeliverCall _deliver;
  final CurrentCall _current;

  Future<Either<Failure, DriverOrderModel>> call({required DriverOrderModel order, required String otp, List<int> uploadIds = const [], required String key}) async {
    final byPhoto = uploadIds.isNotEmpty;
    if (!byPhoto && !isValidDeliveryCode(otp)) return const Left(DeliveryCodeInvalid());
    final r = await _deliver(order.id, otp: byPhoto ? null : otp, uploadIds: uploadIds, key: key);
    return r.fold<Future<Either<Failure, DriverOrderModel>>>((raw) async {
      final f = mapDeliverFailure(raw);
      if (kDebugMode) debugPrint('[deliver] failed status=${raw.statusCode} code=${raw.code} otpLen=${otp.length}');
      if (f is DeliveryInvalidState && await _alreadyDone(order.id)) return Right(order);
      return Left(f);
    }, (v) async => Right(v ?? order));
  }

  Future<bool> _alreadyDone(int id) async {
    final c = await _current();
    return c.fold((_) => false, (o) => o == null || o.id != id || _doneStatuses.contains(o.status.key));
  }
}
