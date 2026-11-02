import 'package:dio/dio.dart';
import 'package:project/core/network/api_client.dart';
import 'package:project/customer/features/checkout/domain/entities/placed_order.dart';

abstract class PaymentRemoteDataSource {
  Future<PlacedOrder> submitReceipt(int orderId, int uploadId, String key);
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  PaymentRemoteDataSourceImpl(this._api);

  final ApiClient _api;

  @override
  Future<PlacedOrder> submitReceipt(
      int orderId, int uploadId, String key) async {
    final res = await _api.dio.post<dynamic>(
      'v1/orders/$orderId/payment-receipt',
      data: {'upload_id': uploadId},
      options: Options(headers: {'Idempotency-Key': key}),
    );
    return PlacedOrder.fromJson(ApiClient.unwrapMap(res));
  }
}
