import 'package:dartz/dartz.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/utils/usecase.dart';
import 'package:project/customer/features/cart/domain/repositories/cart_repository.dart';

class GetCartCountUseCase implements UseCase<int, NoParams> {
  const GetCartCountUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<Either<Failure, int>> call(NoParams params) => _repository.getCount();
}