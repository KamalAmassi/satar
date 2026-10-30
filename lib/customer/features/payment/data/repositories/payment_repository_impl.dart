import 'package:dartz/dartz.dart';
import 'package:project/core/errors/error_handler.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/customer/features/checkout/domain/entities/placed_order.dart';
import 'package:project/customer/features/payment/data/datasources/payment_remote_datasource.dart';
import 'package:project/customer/features/payment/domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl(this._remote);

  final PaymentRemoteDataSource _remote;

  @override
  Future<Either<Failure, PlacedOrder>> submitReceipt({
    required int orderId,
    required int uploadId,
    required String idempotencyKey,
  }) =>
      ErrorHandler.guard(
        () => _remote.submitReceipt(orderId, uploadId, idempotencyKey),
      );
}
