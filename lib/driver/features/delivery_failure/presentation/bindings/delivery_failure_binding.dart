import 'package:get/get.dart';
import 'package:project/driver/features/current_task/presentation/bindings/current_task_binding.dart';
import 'package:project/driver/features/delivery_failure/presentation/controllers/delivery_failure_controller.dart';

class DriverDeliveryFailureBinding extends Bindings {
  @override
  void dependencies() {
    DriverCurrentTaskBinding.registerCore();
    Get.lazyPut(() => DriverDeliveryFailureController());
  }
}
