import 'package:project/core/network/api_client.dart';
import 'package:project/core/network/api_endpoints.dart';
import 'package:project/core/utils/json_utils.dart';
import 'package:project/driver/shared/driver_models.dart';

abstract class EarningsCashRemoteDataSource {
  Future<Earnings> earnings(String period);
  Future<Cash> cash();
}

class EarningsCashRemoteDataSourceImpl implements EarningsCashRemoteDataSource {
  const EarningsCashRemoteDataSourceImpl(this._api);

  final ApiClient _api;

  @override
  Future<Earnings> earnings(String period) async => Earnings.fromJson(
        asMap(await _api.getData(
          ApiEndpoints.driverEarnings,
          queryParameters: {'period': period},
        )),
      );

  @override
  Future<Cash> cash() async =>
      Cash.fromJson(asMap(await _api.getData(ApiEndpoints.driverCash)));
}
