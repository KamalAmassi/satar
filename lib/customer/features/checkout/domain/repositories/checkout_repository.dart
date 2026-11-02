import 'package:dartz/dartz.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/customer/features/checkout/domain/entities/checkout_address.dart';
import 'package:project/customer/features/checkout/domain/entities/order_submission.dart';
import 'package:project/customer/features/checkout/domain/entities/placed_order.dart';
import 'package:project/customer/features/checkout/domain/entities/quote.dart';
import 'package:project/customer/features/checkout/domain/entities/quote_draft.dart';

abstract class CheckoutRepository {
  Future<Either<Failure, List<CheckoutAddress>>> addresses();
  Future<Either<Failure, Quote>> quote(QuoteDraft draft);

  /// لا يعيد المحاولة تلقائيًا أبدًا.
  Future<SubmitOutcome> placeOrder(OrderSubmission submission);
  Future<Either<Failure, PlacedOrder>> order(int orderId);

  /// المحاولة غير المؤكدة الأخيرة لهذا المستخدم (تبقى بعد إعادة التشغيل).
  OrderSubmission? pendingSubmission(int userId);
  Future<void> savePendingSubmission(int userId, OrderSubmission? submission);
}
