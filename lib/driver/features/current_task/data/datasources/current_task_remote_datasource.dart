import 'package:project/core/network/api_client.dart';
import 'package:project/core/network/api_endpoints.dart';
import 'package:project/core/services/upload_service.dart';
import 'package:project/core/utils/json_utils.dart';
import 'package:project/driver/shared/driver_models.dart';

abstract class CurrentTaskRemoteDataSource {
  Future<DriverOrder?> current();
  Future<DriverOrder> transition(
    int orderId,
    String to,
    Map<String, dynamic> fields,
    List<int> uploadIds,
  );
  Future<int> uploadProofPhoto(String path);
}

class CurrentTaskRemoteDataSourceImpl implements CurrentTaskRemoteDataSource {
  const CurrentTaskRemoteDataSourceImpl(this._api, this._upload);

  final ApiClient _api;
  final UploadService _upload;

  @override
  Future<DriverOrder?> current() async {
    final data = await _api.getData(ApiEndpoints.currentDriverOrder);
    final order = unwrapKey(data, 'order');
    // الرد الفاضي (null أو {} أو {order: null}) = ما في مهمة حالية.
    if (order['id'] == null) return null;
    return DriverOrder.fromJson(order);
  }

  @override
  Future<DriverOrder> transition(
    int orderId,
    String to,
    Map<String, dynamic> fields,
    List<int> uploadIds,
  ) async {
    final data = await _api.postData(
      ApiEndpoints.transitionDriverOrder(orderId),
      idempotent: true,
      data: {
        'to': to,
        'fields': fields,
        if (uploadIds.isNotEmpty) 'upload_ids': uploadIds,
      },
    );
    return DriverOrder.fromJson(unwrapKey(data, 'order'));
  }

  @override
  Future<int> uploadProofPhoto(String path) => _upload.uploadProofPhoto(path);
}
