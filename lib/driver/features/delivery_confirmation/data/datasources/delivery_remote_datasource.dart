import 'package:project/core/network/api_client.dart';
import 'package:project/core/network/api_endpoints.dart';
import 'package:project/core/utils/json_utils.dart';
import 'package:project/driver/shared/driver_models.dart';

abstract class DeliveryRemoteDataSource {
  Future<DriverOrder> deliver(int orderId, String otp, List<int> uploadIds);
}

class DeliveryRemoteDataSourceImpl implements DeliveryRemoteDataSource {
  const DeliveryRemoteDataSourceImpl(this._api);

  final ApiClient _api;

  @override
  Future<DriverOrder> deliver(int orderId, String otp, List<int> uploadIds) async {
    final data = await _api.postData(
      ApiEndpoints.deliverDriverOrder(orderId),
      idempotent: true,
      data: {'otp': otp, if (uploadIds.isNotEmpty) 'upload_ids': uploadIds},
    );
    return DriverOrder.fromJson(unwrapKey(data, 'order'));
  }
}
