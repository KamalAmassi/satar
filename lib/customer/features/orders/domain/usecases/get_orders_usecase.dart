import 'package:project/customer/features/orders/domain/entities/order_entity.dart';
import 'package:project/customer/features/orders/domain/repositories/orders_repository.dart';

class GetOrdersUseCase {
  final OrdersRepository repository;

  GetOrdersUseCase(this.repository);

  Future<List<OrderEntity>> call({required String tab, int page = 1}) {
    return repository.getOrders(tab: tab, page: page);
  }
}
