import 'package:get/get.dart';
import 'package:project/core/config/remote_config_repository.dart';
import 'package:project/core/network/api_client.dart';
import 'package:project/core/storage/session_store.dart';
import 'package:project/customer/features/cart/presentation/bindings/cart_binding.dart';
import 'package:project/customer/features/checkout/data/datasources/checkout_remote_datasource.dart';
import 'package:project/customer/features/checkout/data/repositories/checkout_repository_impl.dart';
import 'package:project/customer/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:project/customer/features/checkout/domain/usecases/get_addresses_usecase.dart';
import 'package:project/customer/features/checkout/domain/usecases/get_order_usecase.dart';
import 'package:project/customer/features/checkout/domain/usecases/place_order_usecase.dart';
import 'package:project/customer/features/checkout/domain/usecases/request_quote_usecase.dart';
import 'package:project/customer/features/checkout/presentation/controllers/checkout_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// مشتركة بين صفحات التوصيل وطريقة الدفع والمراجعة.
class CheckoutBinding extends Bindings {
  @override
  void dependencies() {
    ensureRepository();
    if (Get.isRegistered<CheckoutController>()) return;
    final repository = Get.find<CheckoutRepository>();
    Get.put(
      CheckoutController(
        cart: CartBinding.ensureCart(),
        config: Get.find<RemoteConfigRepository>(),
        session: Get.find<SessionStore>(),
        repository: repository,
        getAddresses: GetAddressesUseCase(repository),
        requestQuote: RequestQuoteUseCase(repository),
        placeOrder: PlaceOrderUseCase(repository),
      ),
    );
  }

  static CheckoutRepository ensureRepository() {
    if (!Get.isRegistered<CheckoutRepository>()) {
      Get.put<CheckoutRepository>(
        CheckoutRepositoryImpl(
          CheckoutRemoteDataSourceImpl(Get.find<ApiClient>()),
          Get.find<SharedPreferences>(),
        ),
        permanent: true,
      );
    }
    return Get.find<CheckoutRepository>();
  }

  static GetOrderUseCase getOrder() => GetOrderUseCase(ensureRepository());
}
