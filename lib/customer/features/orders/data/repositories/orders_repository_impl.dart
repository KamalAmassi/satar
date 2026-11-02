import 'package:project/customer/features/orders/data/datasources/orders_remote_datasource.dart';
import 'package:project/customer/features/orders/domain/entities/order_entity.dart';
import 'package:project/customer/features/orders/domain/repositories/orders_repository.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDatasource remoteDatasource;

  OrdersRepositoryImpl({required this.remoteDatasource});

  @override
  Future<List<OrderEntity>> getOrders({required String tab, int page = 1}) {
    return remoteDatasource.getOrders(tab: tab, page: page);
  }

  @override
  Future<OrderEntity> getOrderDetails(String orderId) {
    return remoteDatasource.getOrderDetails(orderId);
  }
}
