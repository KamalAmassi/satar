import 'package:project/core/network/api_client.dart';
import 'package:project/core/network/api_endpoints.dart';
import 'package:project/core/network/models/masar_models.dart';
import 'package:project/core/utils/json_utils.dart';

abstract class DriverHomeRemoteDataSource {
  Future<Driver> getProfile();
  Future<void> setOnline(bool online);
  Future<void> sendLocation(double lat, double lng, double? accuracy);
}

class DriverHomeRemoteDataSourceImpl implements DriverHomeRemoteDataSource {
  DriverHomeRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<Driver> getProfile() async {
    final data = await apiClient.getData(ApiEndpoints.driverMe);
    return Driver.fromJson(unwrapKey(data, 'driver'));
  }

  @override
  Future<void> setOnline(bool online) async {
    await apiClient.putData(ApiEndpoints.driverStatus, data: {'is_online': online});
  }

  @override
  Future<void> sendLocation(double lat, double lng, double? accuracy) async {
    await apiClient.postData(
      ApiEndpoints.driverLocation,
      data: {'lat': lat, 'lng': lng, if (accuracy != null) 'accuracy': accuracy},
    );
  }
}
