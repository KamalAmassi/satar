import 'package:dartz/dartz.dart';
import 'package:project/core/errors/error_handler.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/network/models/masar_models.dart';
import 'package:project/driver/features/available_orders/data/datasources/available_orders_remote_datasource.dart';
import 'package:project/driver/features/available_orders/domain/repositories/available_orders_repository.dart';

class DriverAvailableOrdersRepositoryImpl
    implements DriverAvailableOrdersRepository {
  DriverAvailableOrdersRepositoryImpl({required this.remoteDataSource});

  final DriverAvailableOrdersRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, List<DriverOrder>>> getAvailableOrders() {
    return ErrorHandler.guard(() => remoteDataSource.getAvailableOrders());
  }

  @override
  Future<Either<Failure, DriverOrder>> acceptOrder({required String orderId}) {
    return ErrorHandler.guard(
      () => remoteDataSource.acceptOrder(orderId: orderId),
    );
  }
}
