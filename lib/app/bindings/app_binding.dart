import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:project/core/config/remote_config_repository.dart';
import 'package:project/core/network/api_client.dart';
import 'package:project/core/otp/domain/otp_gateway.dart';
import 'package:project/core/otp/otp_module.dart';
import 'package:project/core/services/push/local_notifications_service.dart';
import 'package:project/core/services/push/notification_router.dart';
import 'package:project/core/services/push/push_messaging.dart';
import 'package:project/core/services/push/push_service.dart';
import 'package:project/core/storage/session_store.dart';
import 'package:project/core/uploads/picked_file.dart';
import 'package:project/core/uploads/upload_repository.dart';
import 'package:project/customer/features/cart/presentation/bindings/cart_binding.dart';
import 'package:project/core/data/backend.dart';
import 'package:project/core/data/push_registrars.dart';
import 'package:project/driver/features/orders/presentation/driver_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    final prefs = Get.find<SharedPreferences>();
    final session = Get.put(SessionStore(prefs), permanent: true);
    final api = Get.put(ApiClient(session), permanent: true);
    final backend = Get.put(Backend(api), permanent: true);
    Get.put(RemoteConfigRepository(api), permanent: true);
    Get.put(UploadRepository(api), permanent: true);
    Get.put<FileSource>(const FilePickerSource(), permanent: true);
    Get.put(DriverLocationService(), permanent: true);
    Get.put<OtpGateway>(createOtpGateway(), permanent: true);
    CartBinding.ensureCart();
    Get.put(
      PushService(
        messaging: const FirebasePushMessaging(),
        prefs: prefs,
        supported: pushPlatformSupported && Firebase.apps.isNotEmpty,
        presenter: LocalNotificationsService.instance,
        registrar: () => session.isSignedIn ? BackendPushRegistrar(backend, driver: session.isDriver) : null,
        onTap: (data) => NotificationRouter.route(data, role: session.isSignedIn ? (session.isDriver ? 'driver' : 'customer') : null),
      ),
      permanent: true,
    );
  }
}
