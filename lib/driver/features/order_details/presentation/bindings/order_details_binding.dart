import 'package:get/get.dart';
import 'package:project/driver/features/available_orders/domain/usecases/accept_order_usecase.dart';
import 'package:project/driver/features/order_details/presentation/controllers/order_details_controller.dart';
import 'package:project/driver/features/order_details/presentation/controllers/task_details_controller.dart';

class DriverOrderDetailsBinding extends Bindings {
  @override
  void dependencies() {
    // AcceptOrderUseCase مسجّل مسبقاً من DriverAvailableOrdersBinding (داخل الـ shell).
    Get.lazyPut<DriverOrderDetailsController>(
      () => DriverOrderDetailsController(
        acceptOrderUseCase: Get.find<AcceptOrderUseCase>(),
      ),
    );
  }
}

class DriverTaskDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DriverTaskDetailsController());
  }
}
