import 'package:dartz/dartz.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/utils/usecase.dart';
import 'package:project/customer/features/cart/domain/entities/cart_item.dart';
import 'package:project/customer/features/cart/domain/repositories/cart_repository.dart';

class AddToCartUseCase implements UseCase<int, List<CartItem>> {
  const AddToCartUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<Either<Failure, int>> call(List<CartItem> params) =>
      _repository.addItems(params);
}