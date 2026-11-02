import 'package:project/customer/features/orders/domain/entities/order_entity.dart';

abstract class OrdersRepository {
  Future<List<OrderEntity>> getOrders({required String tab, int page = 1});
  Future<OrderEntity> getOrderDetails(String orderId);
}
