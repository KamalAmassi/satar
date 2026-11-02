import 'package:dartz/dartz.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/network/models/masar_models.dart';
import 'package:project/core/utils/usecase.dart';
import 'package:project/driver/features/available_orders/domain/repositories/available_orders_repository.dart';


class GetAvailableOrdersUseCase implements UseCase<List<DriverOrder>, NoParams> {
  final DriverAvailableOrdersRepository repository;

  GetAvailableOrdersUseCase({required this.repository});

  @override
  Future<Either<Failure, List<DriverOrder>>> call(NoParams params) async {
    return await repository.getAvailableOrders();
  }
}
