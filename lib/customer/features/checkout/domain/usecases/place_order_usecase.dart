import 'package:project/customer/features/checkout/domain/entities/order_submission.dart';
import 'package:project/customer/features/checkout/domain/repositories/checkout_repository.dart';

/// يرسل المحاولة كما هي (نفس المفتاح ونفس الجسم). لا إعادة تلقائية.
class PlaceOrderUseCase {
  const PlaceOrderUseCase(this._repository);

  final CheckoutRepository _repository;

  Future<SubmitOutcome> call(OrderSubmission submission) =>
      _repository.placeOrder(submission);
}
