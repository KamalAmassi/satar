import 'package:get/get.dart';
import 'package:project/core/config/remote_config_repository.dart';
import 'package:project/core/storage/session_store.dart';
import 'package:project/core/uploads/picked_file.dart';
import 'package:project/customer/features/cart/presentation/bindings/cart_binding.dart';
import 'package:project/customer/features/printing/presentation/controllers/printing_controller.dart';

class PrintingBinding extends Bindings {
  @override
  void dependencies() {
    final cart = CartBinding.ensureCart();
    Get.lazyPut(
      () => PrintingController(
        cart: cart,
        config: Get.find<RemoteConfigRepository>(),
        session: Get.find<SessionStore>(),
        files: Get.find<FileSource>(),
      ),
      fenix: true,
    );
  }
}
