import 'package:dartz/dartz.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/driver/shared/driver_models.dart';

abstract class DeliveryRepository {
  Future<Either<Failure, DriverOrder>> deliver({
    required int orderId,
    required String otp,
    List<int> uploadIds = const [],
  });
}
