import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile, Response;
import 'package:project/core/config/app_env.dart';
import 'package:project/core/errors/api_error_codes.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/storage/session_store.dart';

/// عميل Dio واحد مشترك لكل الميزات.
///
/// - X-Project-Key من [AppEnv] فقط، ولا يُرسل فارغًا أبدًا.
/// - لا يرسل X-Config-Version: يُطلب أحدث إعداد دائمًا ما لم يُثبَّت إصدار
///   منشور ومؤكد عمدًا.
/// - لا إعادة محاولة تلقائية لأي طلب.
class ApiClient {
  ApiClient(this._session, {Dio? dio}) : dio = dio ?? Dio() {
    this.dio.options
      ..baseUrl = '${AppEnv.apiBaseUrl}/'
      ..connectTimeout = const Duration(seconds: 15)
      ..sendTimeout = const Duration(seconds: 60)
      ..receiveTimeout = const Duration(seconds: 30)
      ..responseType = ResponseType.json;
    this.dio.interceptors.add(
          InterceptorsWrapper(onRequest: _attachHeaders),
        );
  }

  final SessionStore _session;
  final Dio dio;

  void _attachHeaders(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (!AppEnv.hasProjectKey) {
      return handler.reject(
        DioException(
          requestOptions: options,
          error: const ServerFailure(code: ApiErrorCodes.missingProjectKey),
        ),
      );
    }
    options.headers['Accept'] = 'application/json';
    options.headers['X-Project-Key'] = AppEnv.projectKey;
    options.headers['Accept-Language'] = Get.locale?.languageCode ?? 'ar';
    if (AppEnv.devMember.isNotEmpty) {
      options.headers['X-Dev-Member'] = AppEnv.devMember;
    }
    final token = _session.token;
    if (token != null && options.extra['auth'] != false) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  /// يستخرج data من غلاف { success, message, data, request_id }.
  static T unwrap<T>(Response<dynamic> response) {
    final body = response.data;
    if (body is Map && body.containsKey('data')) return body['data'] as T;
    throw const UnknownFailure();
  }

  static Map<String, dynamic> unwrapMap(Response<dynamic> response) =>
      Map<String, dynamic>.from(unwrap<Map>(response));
}
