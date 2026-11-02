import 'package:dartz/dartz.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/utils/usecase.dart';
import 'package:project/customer/features/checkout/domain/entities/checkout_address.dart';
import 'package:project/customer/features/checkout/domain/repositories/checkout_repository.dart';

class GetAddressesUseCase implements UseCase<List<CheckoutAddress>, NoParams> {
  const GetAddressesUseCase(this._repository);

  final CheckoutRepository _repository;

  @override
  Future<Either<Failure, List<CheckoutAddress>>> call(NoParams params) =>
      _repository.addresses();
}
