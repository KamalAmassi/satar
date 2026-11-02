import 'package:get/get.dart';

import 'package:project/core/config/api_config.dart';
import 'package:project/core/network/api_client.dart';
import 'package:project/core/network/token_storage.dart';
import 'package:project/core/routes/app_routes.dart';
import 'package:project/core/services/app_config_service.dart';
import 'package:project/core/services/location_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // خدمة حفظ واسترجاع التوكن. GetStorage تتم تهيئته في main.dart.
    Get.put<TokenStorage>(
      GetStorageTokenStorage(),
      permanent: true,
    );

    // عميل API واحد مشترك بين جميع Features.
    Get.put<ApiClient>(
      ApiClient(
        baseUrl: ApiConfig.baseUrl,
        projectKey: ApiConfig.projectKey,
        tokenStorage: Get.find<TokenStorage>(),
        locale: ApiConfig.defaultLocale,
        devMember: ApiConfig.devMember,
        // توكن منتهي (401): نرجع لشاشة دخول السائق إذا كنا داخل تطبيق السائق.
        onUnauthorized: () async {
          if (Get.currentRoute.startsWith('/driver') &&
              Get.currentRoute != DriverRoutes.login) {
            Get.offAllNamed(DriverRoutes.login);
          }
        },
      ),
      permanent: true,
    );

    // خدمات مشتركة.
    Get.lazyPut<LocationService>(() => LocationService(), fenix: true);
    Get.lazyPut<AppConfigService>(
      () => AppConfigService(Get.find<ApiClient>()),
      fenix: true,
    );
  }
}
