import 'package:dartz/dartz.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/utils/usecase.dart';
import 'package:project/driver/features/current_task/domain/repositories/current_task_repository.dart';
import 'package:project/driver/shared/driver_models.dart';

class TransitionParams {
  const TransitionParams({
    required this.orderId,
    required this.to,
    this.fields = const {},
    this.uploadIds = const [],
  });

  final int orderId;
  final String to;
  final Map<String, dynamic> fields;
  final List<int> uploadIds;
}

/// الانتقال لحالة جديدة — دائماً حسب next_action القادم من السيرفر.
class TransitionOrderUseCase implements UseCase<DriverOrder, TransitionParams> {
  const TransitionOrderUseCase(this._repository);

  final CurrentTaskRepository _repository;

  @override
  Future<Either<Failure, DriverOrder>> call(TransitionParams p) =>
      _repository.transition(
        orderId: p.orderId,
        to: p.to,
        fields: p.fields,
        uploadIds: p.uploadIds,
      );
}
