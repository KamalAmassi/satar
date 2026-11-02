import 'package:project/core/network/api_client.dart';
import 'package:project/core/network/api_endpoints.dart';
import 'package:project/core/network/api_exception.dart';

abstract class DriverAuthRemoteDataSource {
  Future<Map<String, dynamic>> loginDriver({
    required String phone,
    required String password,
  });

  Future<void> logoutDriver();
}

class DriverAuthRemoteDataSourceImpl implements DriverAuthRemoteDataSource {
  DriverAuthRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<Map<String, dynamic>> loginDriver({
    required String phone,
    required String password,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.driverLogin,
      data: {
        'phone': phone.trim(),
        'password': password,
      },
      publicRequest: true,
    );

    if (!response.success) {
      throw ApiException(message: response.message.isNotEmpty
          ? response.message
          : 'تعذر تسجيل الدخول. تحقق من بياناتك.');
    }

    final data = response.data;
    if (data is! Map) {
      throw const ApiException(
        message: 'استجابة تسجيل الدخول غير مكتملة من الخادم.',
      );
    }

    return Map<String, dynamic>.from(data);
  }

  @override
  Future<void> logoutDriver() async {
    final response = await apiClient.post(
      ApiEndpoints.driverLogout,
      data: const <String, dynamic>{},
    );

    if (!response.success) {
      throw ApiException(
        message: response.message.isNotEmpty
            ? response.message
            : 'تعذر تسجيل الخروج من الخادم.',
      );
    }
  }
}
