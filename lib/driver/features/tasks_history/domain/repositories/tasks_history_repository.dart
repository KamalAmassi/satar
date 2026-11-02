import 'package:dartz/dartz.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/driver/shared/driver_models.dart';

abstract class TasksHistoryRepository {
  Future<Either<Failure, List<DriverOrder>>> getHistory();
}
