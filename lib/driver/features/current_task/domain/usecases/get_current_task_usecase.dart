import 'package:dartz/dartz.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/utils/usecase.dart';
import 'package:project/driver/features/current_task/domain/repositories/current_task_repository.dart';
import 'package:project/driver/shared/driver_models.dart';

class GetCurrentTaskUseCase implements UseCase<DriverOrder?, NoParams> {
  const GetCurrentTaskUseCase(this._repository);

  final CurrentTaskRepository _repository;

  @override
  Future<Either<Failure, DriverOrder?>> call(NoParams params) =>
      _repository.getCurrent();
}
