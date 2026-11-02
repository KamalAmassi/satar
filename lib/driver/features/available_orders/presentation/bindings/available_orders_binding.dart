import 'package:get/get.dart';
import 'package:project/driver/features/available_orders/data/datasources/available_orders_remote_datasource.dart';
import 'package:project/driver/features/available_orders/data/repositories/available_orders_repository_impl.dart';
import 'package:project/driver/features/available_orders/domain/repositories/available_orders_repository.dart';
import 'package:project/driver/features/available_orders/domain/usecases/accept_order_usecase.dart';
import 'package:project/driver/features/available_orders/domain/usecases/get_available_orders_usecase.dart';
import 'package:project/driver/features/available_orders/presentation/controllers/available_orders_controller.dart';

class DriverAvailableOrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverAvailableOrdersRemoteDataSource>(
      () => DriverAvailableOrdersRemoteDataSourceImpl(apiClient: Get.find()),
      fenix: true,
    );
    Get.lazyPut<DriverAvailableOrdersRepository>(
      () => DriverAvailableOrdersRepositoryImpl(remoteDataSource: Get.find()),
      fenix: true,
    );
    Get.lazyPut<GetAvailableOrdersUseCase>(
      () => GetAvailableOrdersUseCase(repository: Get.find()),
      fenix: true,
    );
    Get.lazyPut<AcceptOrderUseCase>(
      () => AcceptOrderUseCase(repository: Get.find()),
      fenix: true,
    );
    Get.lazyPut<DriverAvailableOrdersController>(
      () => DriverAvailableOrdersController(
        getAvailableOrdersUseCase: Get.find<GetAvailableOrdersUseCase>(),
      ),
    );
  }
}
