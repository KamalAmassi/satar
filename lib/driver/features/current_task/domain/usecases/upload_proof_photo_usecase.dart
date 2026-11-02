import 'package:dartz/dartz.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/utils/usecase.dart';
import 'package:project/driver/features/current_task/domain/repositories/current_task_repository.dart';

class UploadProofPhotoUseCase implements UseCase<int, String> {
  const UploadProofPhotoUseCase(this._repository);

  final CurrentTaskRepository _repository;

  @override
  Future<Either<Failure, int>> call(String path) =>
      _repository.uploadProofPhoto(path);
}
