import 'package:dartz/dartz.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/network/models/masar_models.dart';
import 'package:project/core/utils/usecase.dart';
import 'package:project/driver/features/available_orders/domain/repositories/available_orders_repository.dart';

class AcceptOrderUseCase implements UseCase<DriverOrder, AcceptOrderParams> {
  final DriverAvailableOrdersRepository repository;

  AcceptOrderUseCase({required this.repository});

  @override
  Future<Either<Failure, DriverOrder>> call(AcceptOrderParams params) {
    return repository.acceptOrder(orderId: params.orderId);
  }
}

/// البارامترات الخاصة بقبول الطلب لضمان نظافة التمرير وعزل الكود
class AcceptOrderParams {
  final String orderId;

  AcceptOrderParams({required this.orderId});
}
