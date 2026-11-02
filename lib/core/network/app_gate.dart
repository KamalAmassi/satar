import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:project/core/errors/api_error_codes.dart';

/// بوابة الأخطاء الشاملة: أخطاء تمنع التطبيق كله تفتح شاشاتها (الحالات والأذونات).
///
/// لا تعالج هنا أخطاء الميزات (مثل out_of_stock): تبقى عند المتحكم.
abstract final class AppGate {
  static String? _showing;

  static void onError(DioException e, {required bool hadToken}) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    String? code;
    if (data is Map && data['error'] is Map) code = (data['error'] as Map)['code'] as String?;

    String? route;
    if (status == 401 && hadToken) {
      route = '/session-expired';
    } else if (status == 426 || code == ApiErrorCodes.appUpdateRequired) {
      route = '/update-required';
    } else if (code == ApiErrorCodes.maintenance) {
      route = '/maintenance';
    } else if (code == ApiErrorCodes.projectFrozen || code == ApiErrorCodes.projectInactive) {
      route = '/service-paused';
    } else if (code == ApiErrorCodes.userBlocked) {
      route = '/blocked';
    }
    if (route == null || _showing == route) return;
    _showing = route;
    // يؤجَّل حتى لا يُفتح أثناء بناء الإطار.
    Future.microtask(() {
      Get.offAllNamed(route!);
      Future.delayed(const Duration(seconds: 1), () => _showing = null);
    });
  }
}
