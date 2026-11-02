import 'package:dartz/dartz.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/utils/usecase.dart';
import 'package:project/driver/features/delivery_confirmation/domain/repositories/delivery_repository.dart';
import 'package:project/driver/shared/driver_models.dart';

class DeliverParams {
  const DeliverParams({
    required this.orderId,
    required this.otp,
    this.uploadIds = const [],
  });

  final int orderId;
  final String otp;
  final List<int> uploadIds;
}

class DeliverOrderUseCase implements UseCase<DriverOrder, DeliverParams> {
  const DeliverOrderUseCase(this._repository);

  final DeliveryRepository _repository;

  @override
  Future<Either<Failure, DriverOrder>> call(DeliverParams p) => _repository.deliver(
    orderId: p.orderId,
    otp: p.otp,
    uploadIds: p.uploadIds,
  );
}
