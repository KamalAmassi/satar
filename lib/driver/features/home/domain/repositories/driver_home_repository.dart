import 'package:dartz/dartz.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/network/models/masar_models.dart';

abstract class DriverHomeRepository {
  Future<Either<Failure, Driver>> getProfile();
  Future<Either<Failure, bool>> setOnline({required bool online});
  Future<Either<Failure, bool>> sendLocation({
    required double lat,
    required double lng,
    double? accuracy,
  });
}
