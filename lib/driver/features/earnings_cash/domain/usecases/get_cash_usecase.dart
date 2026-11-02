import 'package:dartz/dartz.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/utils/usecase.dart';
import 'package:project/driver/shared/driver_models.dart';
import 'package:project/driver/features/earnings_cash/domain/repositories/earnings_cash_repository.dart';

class GetCashUseCase implements UseCase<Cash, NoParams> {
  const GetCashUseCase(this._repository);

  final EarningsCashRepository _repository;

  @override
  Future<Either<Failure, Cash>> call(NoParams params) =>
      _repository.getCash();
}
