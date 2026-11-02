import 'package:dartz/dartz.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/utils/usecase.dart';
import 'package:project/driver/shared/driver_models.dart';
import 'package:project/driver/features/earnings_cash/domain/repositories/earnings_cash_repository.dart';

/// period: 'week' (مؤكد بالكولكشن) — 'today' يُستخدم لملخص الرئيسية وقد لا يكون مدعوماً.
class GetEarningsUseCase implements UseCase<Earnings, String> {
  const GetEarningsUseCase(this._repository);

  final EarningsCashRepository _repository;

  @override
  Future<Either<Failure, Earnings>> call(String period) =>
      _repository.getEarnings(period);
}
