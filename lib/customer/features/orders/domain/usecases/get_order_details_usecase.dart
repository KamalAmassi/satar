import 'package:project/customer/features/orders/domain/entities/order_entity.dart';
import 'package:project/customer/features/orders/domain/repositories/orders_repository.dart';

class GetOrderDetailsUseCase {
  final OrdersRepository repository;

  GetOrderDetailsUseCase(this.repository);

  Future<OrderEntity> call(String orderId) {
    return repository.getOrderDetails(orderId);
  }
}
