import 'package:project/core/network/api_client.dart';
import 'package:project/core/network/api_endpoints.dart';
import 'package:project/core/network/models/masar_models.dart';
import 'package:project/core/utils/json_utils.dart';

abstract class DriverAvailableOrdersRemoteDataSource {
  Future<List<DriverOrder>> getAvailableOrders();
  Future<DriverOrder> acceptOrder({required String orderId});
}

class DriverAvailableOrdersRemoteDataSourceImpl
    implements DriverAvailableOrdersRemoteDataSource {
  DriverAvailableOrdersRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<List<DriverOrder>> getAvailableOrders() async {
    final data = await apiClient.getData(ApiEndpoints.availableDriverOrders);
    // يدعم القائمة المباشرة أو شكل pagination (items/data/orders).
    return extractList(data).map(DriverOrder.fromJson).toList();
  }

  @override
  Future<DriverOrder> acceptOrder({required String orderId}) async {
    final data = await apiClient.postData(
      ApiEndpoints.acceptDriverOrder(orderId),
      idempotent: true,
    );
    return DriverOrder.fromJson(unwrapKey(data, 'order'));
  }
}
