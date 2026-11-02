import 'package:dartz/dartz.dart';
import 'package:project/core/errors/error_handler.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/network/models/masar_models.dart';
import 'package:project/driver/features/home/data/datasources/home_remote_datasource.dart';
import 'package:project/driver/features/home/domain/repositories/driver_home_repository.dart';

class DriverHomeRepositoryImpl implements DriverHomeRepository {
  DriverHomeRepositoryImpl({required this.remoteDataSource});

  final DriverHomeRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, Driver>> getProfile() =>
      ErrorHandler.guard<Driver>(() => remoteDataSource.getProfile());

  @override
  Future<Either<Failure, bool>> setOnline({required bool online}) =>
      ErrorHandler.guard<bool>(() async {
        await remoteDataSource.setOnline(online);
        return true;
      });

  @override
  Future<Either<Failure, bool>> sendLocation({
    required double lat,
    required double lng,
    double? accuracy,
  }) =>
      ErrorHandler.guard<bool>(() async {
        await remoteDataSource.sendLocation(lat, lng, accuracy);
        return true;
      });
}
