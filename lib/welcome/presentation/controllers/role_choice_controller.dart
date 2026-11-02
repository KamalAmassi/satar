import 'package:get/get.dart';
import 'package:project/core/network/token_storage.dart';
import 'package:project/core/routes/app_routes.dart';

class RoleChoiceController extends GetxController {
  void continueAsCustomer() => Get.toNamed(CustomerRoutes.login);

  /// لو السائق مسجّل دخول مسبقاً نفتح التطبيق مباشرة (وإذا انتهى التوكن يرجع للدخول تلقائياً).
  Future<void> continueAsDriver() async {
    final token = await Get.find<TokenStorage>().readToken();
    Get.toNamed(token == null ? DriverRoutes.login : DriverRoutes.home);
  }
}
