import 'package:project/core/network/api_client.dart';
import 'package:project/core/network/api_endpoints.dart';
import 'package:project/core/utils/json_utils.dart';
import 'package:project/driver/shared/driver_models.dart';

abstract class NotificationsRemoteDataSource {
  Future<List<AppNotification>> list();
}

class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  const NotificationsRemoteDataSourceImpl(this._api);

  final ApiClient _api;

  @override
  Future<List<AppNotification>> list() async {
    final data = await _api.getData(ApiEndpoints.driverNotifications);
    return extractList(data).map(AppNotification.fromJson).toList();
  }
}
