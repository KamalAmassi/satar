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
import 'package:project/core/storage/user_data_reset.dart';
import 'package:project/customer/features/account/presentation/account_page.dart' show AccountController;
import 'package:project/customer/features/ai_assistant/presentation/assistant_page.dart' show AssistantController;
import 'package:project/customer/features/cart/presentation/controllers/cart_controller.dart';
import 'package:project/customer/features/orders/presentation/orders_page.dart' show NotificationsController, OrdersController;
import 'package:shared_preferences/shared_preferences.dart';

class AppBinding extends Bindings {
  static bool _resetWired = false;

  /// خطّافات تنظيف حالة المستخدم عند الخروج/تبدّل الحساب (دون لمس Dio والخدمات الدائمة).
  static void _wireUserDataReset(SharedPreferences prefs) {
    if (_resetWired) return;
    _resetWired = true;
    UserDataReset.register(() {
      if (Get.isRegistered<CartController>()) Get.find<CartController>().resetForSignOut();
    });
    UserDataReset.register(() async {
      if (Get.isRegistered<DriverController>()) Get.delete<DriverController>(force: true);
      if (Get.isRegistered<AccountController>()) Get.delete<AccountController>(force: true);
      if (Get.isRegistered<AssistantController>()) Get.delete<AssistantController>(force: true);
      if (Get.isRegistered<OrdersController>()) Get.delete<OrdersController>(force: true);
      for (final tag in const ['c', 'd']) {
        if (Get.isRegistered<NotificationsController>(tag: tag)) Get.delete<NotificationsController>(tag: tag, force: true);
      }
      await prefs.remove('recent_searches');
    });
  }

  @override
  void dependencies() {
    final prefs = Get.find<SharedPreferences>();
    _wireUserDataReset(prefs);
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
