import 'package:dartz/dartz.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/utils/usecase.dart';
import 'package:project/customer/features/checkout/domain/entities/quote.dart';
import 'package:project/customer/features/checkout/domain/entities/quote_draft.dart';
import 'package:project/customer/features/checkout/domain/repositories/checkout_repository.dart';

class RequestQuoteUseCase implements UseCase<Quote, QuoteDraft> {
  const RequestQuoteUseCase(this._repository);

  final CheckoutRepository _repository;

  @override
  Future<Either<Failure, Quote>> call(QuoteDraft draft) =>
      _repository.quote(draft);
}
