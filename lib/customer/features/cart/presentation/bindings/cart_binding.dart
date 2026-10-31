import 'package:get/get.dart';
import 'package:project/customer/features/cart/data/datasources/cart_local_datasource.dart';
import 'package:project/customer/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:project/customer/features/cart/domain/repositories/cart_repository.dart';
import 'package:project/customer/features/cart/domain/usecases/add_to_cart_usecase.dart';
import 'package:project/customer/features/cart/domain/usecases/get_cart_count_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CartLocalDataSource>(
          () => CartLocalDataSourceImpl(Get.find<SharedPreferences>()),
      fenix: true,
    );
    Get.lazyPut<CartRepository>(() => CartRepositoryImpl(Get.find()), fenix: true);
    Get.lazyPut(() => AddToCartUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => GetCartCountUseCase(Get.find()), fenix: true);
  }
}