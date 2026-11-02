import 'package:dartz/dartz.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/driver/shared/driver_models.dart';

abstract class CurrentTaskRepository {
  /// null = ما في مهمة حالية.
  Future<Either<Failure, DriverOrder?>> getCurrent();

  Future<Either<Failure, DriverOrder>> transition({
    required int orderId,
    required String to,
    Map<String, dynamic> fields = const {},
    List<int> uploadIds = const [],
  });

  Future<Either<Failure, int>> uploadProofPhoto(String path);
}
