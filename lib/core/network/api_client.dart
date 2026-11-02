import 'dart:math';

import 'package:dio/dio.dart';

import 'api_exception.dart';
import 'api_response.dart';
import 'token_storage.dart';

class ApiClient {
  ApiClient({
    required String baseUrl,
    required String projectKey,
    required TokenStorage tokenStorage,
    String locale = 'ar',
    String devMember = 'postman',
    Duration connectTimeout = const Duration(seconds: 20),
    Duration receiveTimeout = const Duration(seconds: 20),
    Duration sendTimeout = const Duration(seconds: 30),
    this.onUnauthorized,
  })  : _projectKey = projectKey,
        _tokenStorage = tokenStorage,
        _locale = locale {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
        headers: {
          'Accept': 'application/json',
          'X-Project-Key': projectKey,
          'X-Dev-Member': devMember,
          'Accept-Language': locale,
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          options.headers['Accept-Language'] = _locale;
          final isPublic = options.extra['publicRequest'] == true;

          if (isPublic) {
            // الطلب العام لا يحتاج توكن، لكنه ما زال يحتاج Project Key.
            options.headers.remove('Authorization');
            options.headers['X-Project-Key'] = _projectKey;
          } else {
            options.headers['X-Project-Key'] = _projectKey;
            final token = await _tokenStorage.readToken();
            if (token != null && token.trim().isNotEmpty) {
              options.headers['Authorization'] = 'Bearer ${token.trim()}';
            } else {
              options.headers.remove('Authorization');
            }
          }

          handler.next(options);
        },
      ),
    );
  }

  late final Dio dio;

  /// يُستدعى عند 401 على طلب يحتاج توكن (التوكن منتهي): نمسحه ونرجّع المستخدم لشاشة الدخول.
  final Future<void> Function()? onUnauthorized;
  final String _projectKey;
  final TokenStorage _tokenStorage;
  String _locale;

  String get locale => _locale;
  String get projectKey => _projectKey;

  void setLocale(String locale) {
    if (locale != 'ar' && locale != 'en') {
      throw ArgumentError.value(locale, 'locale', 'Supported locales: ar, en');
    }
    _locale = locale;
  }

  Future<ApiResponse<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool publicRequest = false,
  }) {
    return _request(
      () => dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: _withPublicHeader(options, publicRequest),
      ),
    );
  }

  Future<ApiResponse<dynamic>> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool publicRequest = false,
  }) {
    return _request(
      () => dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _withPublicHeader(options, publicRequest),
      ),
    );
  }

  Future<ApiResponse<dynamic>> put(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _request(
      () => dio.put<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  Future<ApiResponse<dynamic>> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _request(
      () => dio.delete<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  /// يرجع محتوى data مباشرة، ويرمي ApiException لو success=false.
  Future<dynamic> getData(String path, {Map<String, dynamic>? queryParameters}) async =>
      _unwrap(await get(path, queryParameters: queryParameters));

  /// idempotent: يضيف Idempotency-Key جديد (يمنع تكرار التنفيذ عند إعادة الإرسال).
  Future<dynamic> postData(
    String path, {
    Object? data,
    bool idempotent = false,
    bool publicRequest = false,
  }) async =>
      _unwrap(
        await post(
          path,
          data: data ?? const <String, dynamic>{},
          publicRequest: publicRequest,
          options: idempotent
              ? Options(headers: {'Idempotency-Key': _newKey()})
              : null,
        ),
      );

  Future<dynamic> putData(String path, {Object? data}) async =>
      _unwrap(await put(path, data: data ?? const <String, dynamic>{}));

  dynamic _unwrap(ApiResponse<dynamic> response) {
    if (!response.success) {
      throw ApiException(
        message: response.message.isNotEmpty
            ? response.message
            : 'حدث خطأ أثناء تنفيذ الطلب.',
      );
    }
    return response.data;
  }

  static String _newKey() {
    final r = Random.secure();
    String hex(int n) =>
        List.generate(n, (_) => r.nextInt(16).toRadixString(16)).join();
    return '${hex(8)}-${hex(4)}-4${hex(3)}-a${hex(3)}-${hex(12)}';
  }

  Options _withPublicHeader(Options? options, bool publicRequest) {
    final merged = options ?? Options();
    if (!publicRequest) return merged;
    return merged.copyWith(
      extra: {...?merged.extra, 'publicRequest': true},
    );
  }

  Future<ApiResponse<dynamic>> _request(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      final response = await request();
      final body = response.data;

      if (body is Map) {
        return ApiResponse<dynamic>.fromJson(
          Map<String, dynamic>.from(body),
        );
      }

      throw ApiException(
        message: 'استجابة الخادم ليست بصيغة JSON المتوقعة.',
        statusCode: response.statusCode,
        cause: body,
      );
    } on DioException catch (error) {
      final body = error.response?.data;
      final map = body is Map
          ? Map<String, dynamic>.from(body)
          : <String, dynamic>{};
      final errorObject = map['error'];
      final errorMap = errorObject is Map
          ? Map<String, dynamic>.from(errorObject)
          : <String, dynamic>{};
      final details = errorMap['details'] is Map
          ? Map<String, dynamic>.from(errorMap['details'] as Map)
          : (map['details'] is Map
              ? Map<String, dynamic>.from(map['details'] as Map)
              : <String, dynamic>{});
      final fields = details['fields'] is Map
          ? Map<String, dynamic>.from(details['fields'] as Map)
          : <String, dynamic>{};

      final code = errorMap['code']?.toString();

      // 401 على طلب محمي = توكن منتهي/مفقود.
      if (error.response?.statusCode == 401 &&
          error.requestOptions.extra['publicRequest'] != true) {
        await _tokenStorage.clearToken();
        await onUnauthorized?.call();
      }

      String message;
      if (map['message'] is String &&
          (map['message'] as String).isNotEmpty) {
        message = map['message'] as String;
      } else if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        message = 'انتهت مهلة الاتصال. حاول مرة أخرى.';
      } else if (error.type == DioExceptionType.connectionError) {
        message = 'تعذر الاتصال بالخادم. تحقق من الإنترنت.';
      } else {
        message = 'حدث خطأ أثناء تنفيذ الطلب.';
      }

      throw ApiException(
        message: message,
        statusCode: error.response?.statusCode,
        requestId: map['request_id']?.toString() ??
            error.response?.headers.value('X-Request-Id'),
        code: code,
        fields: fields,
        cause: error,
      );
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException(
        message: 'حدث خطأ غير متوقع أثناء الاتصال بالخادم.',
        cause: error,
      );
    }
  }
}
