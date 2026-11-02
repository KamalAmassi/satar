import 'package:get/get.dart';
import 'package:project/core/network/api_client.dart';
import 'package:project/driver/features/current_task/presentation/bindings/current_task_binding.dart';
import 'package:project/driver/features/delivery_confirmation/data/datasources/delivery_remote_datasource.dart';
import 'package:project/driver/features/delivery_confirmation/data/repositories/delivery_repository_impl.dart';
import 'package:project/driver/features/delivery_confirmation/domain/repositories/delivery_repository.dart';
import 'package:project/driver/features/delivery_confirmation/domain/usecases/deliver_order_usecase.dart';
import 'package:project/driver/features/delivery_confirmation/presentation/controllers/delivery_confirmation_controller.dart';

class DriverDeliveryBinding extends Bindings {
  static void registerCore() {
    DriverCurrentTaskBinding.registerCore();
    Get.lazyPut<DeliveryRemoteDataSource>(
          () => DeliveryRemoteDataSourceImpl(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<DeliveryRepository>(() => DeliveryRepositoryImpl(Get.find()), fenix: true);
    Get.lazyPut(() => DeliverOrderUseCase(Get.find()), fenix: true);
  }

  @override
  void dependencies() {
    registerCore();
    Get.lazyPut(() => DriverDeliveryConfirmationController(Get.find(), Get.find()));
  }
}
