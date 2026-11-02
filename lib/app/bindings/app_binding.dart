import 'package:get/get.dart';
import 'package:project/core/config/remote_config_repository.dart';
import 'package:project/core/network/api_client.dart';
import 'package:project/core/storage/session_store.dart';
import 'package:project/core/uploads/picked_file.dart';
import 'package:project/core/uploads/upload_repository.dart';
import 'package:project/customer/features/cart/presentation/bindings/cart_binding.dart';
import 'package:project/data/backend.dart';
import 'package:project/features/driver/driver.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// خدمات مشتركة دائمة لكل التطبيق (شبكة، جلسة، إعدادات، رفع ملفات، سلة، موقع السائق).
class AppBinding extends Bindings {
  @override
  void dependencies() {
    final prefs = Get.find<SharedPreferences>();
    final session = Get.put(SessionStore(prefs), permanent: true);
    final api = Get.put(ApiClient(session), permanent: true);
    Get.put(Backend(api), permanent: true);
    Get.put(RemoteConfigRepository(api), permanent: true);
    Get.put(UploadRepository(api), permanent: true);
    Get.put<FileSource>(const FilePickerSource(), permanent: true);
    Get.put(DriverLocationService(), permanent: true);
    CartBinding.ensureCart();
  }
}
