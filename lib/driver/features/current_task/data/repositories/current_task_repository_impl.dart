import 'package:dartz/dartz.dart';
import 'package:project/core/errors/error_handler.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/driver/features/current_task/data/datasources/current_task_remote_datasource.dart';
import 'package:project/driver/features/current_task/domain/repositories/current_task_repository.dart';
import 'package:project/driver/shared/driver_models.dart';

class CurrentTaskRepositoryImpl implements CurrentTaskRepository {
  const CurrentTaskRepositoryImpl(this._remote);

  final CurrentTaskRemoteDataSource _remote;

  @override
  Future<Either<Failure, DriverOrder?>> getCurrent() =>
      ErrorHandler.guard<DriverOrder?>(() => _remote.current());

  @override
  Future<Either<Failure, DriverOrder>> transition({
    required int orderId,
    required String to,
    Map<String, dynamic> fields = const {},
    List<int> uploadIds = const [],
  }) =>
      ErrorHandler.guard<DriverOrder>(
            () => _remote.transition(orderId, to, fields, uploadIds),
      );

  @override
  Future<Either<Failure, int>> uploadProofPhoto(String path) =>
      ErrorHandler.guard<int>(() => _remote.uploadProofPhoto(path));
}
