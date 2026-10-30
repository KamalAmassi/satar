import 'package:dartz/dartz.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/customer/features/checkout/domain/entities/placed_order.dart';

abstract class PaymentRepository {
  /// يربط إشعارًا مرفوعًا بطلب تحويل في حالة awaiting_payment.
  /// لا يعني اعتماد الدفع؛ المكتبة تراجع الإشعار.
  Future<Either<Failure, PlacedOrder>> submitReceipt({
    required int orderId,
    required int uploadId,
    required String idempotencyKey,
  });
}
