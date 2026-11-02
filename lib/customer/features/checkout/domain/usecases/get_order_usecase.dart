import 'package:dartz/dartz.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/utils/usecase.dart';
import 'package:project/customer/features/checkout/domain/entities/placed_order.dart';
import 'package:project/customer/features/checkout/domain/repositories/checkout_repository.dart';

class GetOrderUseCase implements UseCase<PlacedOrder, int> {
  const GetOrderUseCase(this._repository);

  final CheckoutRepository _repository;

  @override
  Future<Either<Failure, PlacedOrder>> call(int orderId) =>
      _repository.order(orderId);
}
