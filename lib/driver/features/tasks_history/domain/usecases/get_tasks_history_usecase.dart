import 'package:dartz/dartz.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/utils/usecase.dart';
import 'package:project/driver/features/tasks_history/domain/repositories/tasks_history_repository.dart';
import 'package:project/driver/shared/driver_models.dart';

class GetTasksHistoryUseCase implements UseCase<List<DriverOrder>, NoParams> {
  const GetTasksHistoryUseCase(this._repository);

  final TasksHistoryRepository _repository;

  @override
  Future<Either<Failure, List<DriverOrder>>> call(NoParams params) =>
      _repository.getHistory();
}
