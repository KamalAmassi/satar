import 'package:get/get.dart';
import 'package:project/core/network/api_client.dart';
import 'package:project/core/storage/session_store.dart';
import 'package:project/core/uploads/upload_repository.dart';
import 'package:project/customer/features/cart/data/datasources/cart_local_datasource.dart';
import 'package:project/customer/features/cart/data/datasources/product_remote_datasource.dart';
import 'package:project/customer/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:project/customer/features/cart/presentation/controllers/cart_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// السلة خدمة دائمة: تُسجَّل مرة واحدة ويستخدمها الكتالوج والطباعة والدفع.
class CartBinding extends Bindings {
  @override
  void dependencies() => ensureCart();

  static CartController ensureCart() {
    if (Get.isRegistered<CartController>()) return Get.find<CartController>();
    return Get.put(
      CartController(
        CartRepositoryImpl(
          CartLocalDataSourceImpl(Get.find<SharedPreferences>()),
          ProductRemoteDataSourceImpl(Get.find<ApiClient>()),
        ),
        Get.find<UploadRepository>(),
        Get.find<SessionStore>(),
      ),
      permanent: true,
    );
  }
}
