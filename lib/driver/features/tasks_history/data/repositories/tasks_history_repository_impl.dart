import 'package:dartz/dartz.dart';
import 'package:project/core/errors/error_handler.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/driver/features/tasks_history/data/datasources/tasks_history_remote_datasource.dart';
import 'package:project/driver/features/tasks_history/domain/repositories/tasks_history_repository.dart';
import 'package:project/driver/shared/driver_models.dart';

class TasksHistoryRepositoryImpl implements TasksHistoryRepository {
  const TasksHistoryRepositoryImpl(this._remote);

  final TasksHistoryRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<DriverOrder>>> getHistory() =>
      ErrorHandler.guard<List<DriverOrder>>(() => _remote.history());
}
