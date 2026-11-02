import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:project/core/config/remote_config.dart';
import 'package:project/core/errors/error_handler.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/network/api_client.dart';

/// يجلب أحدث إعداد للتطبيق ويخزّنه في الذاكرة لكل لغة.
/// لا يرسل X-Config-Version؛ config_version يُقرأ من الرد.
class RemoteConfigRepository {
  RemoteConfigRepository(this._api);

  final ApiClient _api;
  final Map<String, RemoteConfig> _cache = {};

  RemoteConfig? get current => _cache[_locale];

  String get _locale => Get.locale?.languageCode ?? 'ar';

  Future<Either<Failure, RemoteConfig>> load({bool refresh = false}) async {
    final cached = _cache[_locale];
    if (!refresh && cached != null) return Right(cached);
    final locale = _locale;
    final result = await ErrorHandler.guard(() async {
      final res = await _api.dio.get<dynamic>(
        'v1/app/config',
        queryParameters: {'app': 'user'},
        options: Options(extra: {'auth': false}),
      );
      return RemoteConfig.fromJson(ApiClient.unwrapMap(res));
    });
    result.fold((_) {}, (config) => _cache[locale] = config);
    return result;
  }
}
