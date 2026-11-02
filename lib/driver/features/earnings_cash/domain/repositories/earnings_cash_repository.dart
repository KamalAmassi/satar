import 'package:dartz/dartz.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/driver/shared/driver_models.dart';

abstract class EarningsCashRepository {
  Future<Either<Failure, Earnings>> getEarnings(String period);
  Future<Either<Failure, Cash>> getCash();
}
