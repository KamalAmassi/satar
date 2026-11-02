import 'package:dartz/dartz.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/customer/features/checkout/domain/entities/placed_order.dart';
import 'package:project/customer/features/payment/domain/repositories/payment_repository.dart';

class SubmitReceiptUseCase {
  const SubmitReceiptUseCase(this._repository);

  final PaymentRepository _repository;

  Future<Either<Failure, PlacedOrder>> call({
    required int orderId,
    required int uploadId,
    required String idempotencyKey,
  }) =>
      _repository.submitReceipt(
        orderId: orderId,
        uploadId: uploadId,
        idempotencyKey: idempotencyKey,
      );
}
