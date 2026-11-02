import 'package:dartz/dartz.dart';
import 'package:project/core/errors/error_handler.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/driver/features/earnings_cash/data/datasources/earnings_cash_remote_datasource.dart';
import 'package:project/driver/shared/driver_models.dart';
import 'package:project/driver/features/earnings_cash/domain/repositories/earnings_cash_repository.dart';

class EarningsCashRepositoryImpl implements EarningsCashRepository {
  const EarningsCashRepositoryImpl(this._remote);

  final EarningsCashRemoteDataSource _remote;

  @override
  Future<Either<Failure, Earnings>> getEarnings(String period) =>
      ErrorHandler.guard<Earnings>(() => _remote.earnings(period));

  @override
  Future<Either<Failure, Cash>> getCash() =>
      ErrorHandler.guard<Cash>(() => _remote.cash());
}
