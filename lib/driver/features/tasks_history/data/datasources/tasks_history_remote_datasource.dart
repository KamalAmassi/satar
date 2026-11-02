import 'package:project/core/network/api_client.dart';
import 'package:project/core/network/api_endpoints.dart';
import 'package:project/core/utils/json_utils.dart';
import 'package:project/driver/shared/driver_models.dart';

abstract class TasksHistoryRemoteDataSource {
  Future<List<DriverOrder>> history();
}

class TasksHistoryRemoteDataSourceImpl implements TasksHistoryRemoteDataSource {
  const TasksHistoryRemoteDataSourceImpl(this._api);

  final ApiClient _api;

  @override
  Future<List<DriverOrder>> history() async {
    final data = await _api.getData(ApiEndpoints.driverHistory);
    return extractList(data).map(DriverOrder.fromJson).toList();
  }
}
