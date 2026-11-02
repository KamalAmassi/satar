import 'package:dartz/dartz.dart';
import 'package:project/core/errors/error_handler.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/driver/features/delivery_confirmation/data/datasources/delivery_remote_datasource.dart';
import 'package:project/driver/features/delivery_confirmation/domain/repositories/delivery_repository.dart';
import 'package:project/driver/shared/driver_models.dart';

class DeliveryRepositoryImpl implements DeliveryRepository {
  const DeliveryRepositoryImpl(this._remote);

  final DeliveryRemoteDataSource _remote;

  @override
  Future<Either<Failure, DriverOrder>> deliver({
    required int orderId,
    required String otp,
    List<int> uploadIds = const [],
  }) =>
      ErrorHandler.guard<DriverOrder>(
            () => _remote.deliver(orderId, otp, uploadIds),
      );
}
