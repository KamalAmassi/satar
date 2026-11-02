import 'package:get/get.dart';
import 'package:project/driver/features/auth/presentation/bindings/auth_binding.dart';
import 'package:project/driver/features/available_orders/presentation/bindings/available_orders_binding.dart';
import 'package:project/driver/features/current_task/presentation/bindings/current_task_binding.dart';
import 'package:project/driver/features/earnings_cash/presentation/bindings/earnings_cash_binding.dart';
import 'package:project/driver/features/home/presentation/bindings/home_binding.dart';
import 'package:project/driver/features/profile/presentation/bindings/profile_binding.dart';
import 'package:project/driver/shell/driver_shell_controller.dart';

/// يسجّل كل ما تحتاجه التابات الأربعة، والشاشات المفتوحة من فوقها (تفاصيل، تسليم ...).
class DriverShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverShellController>(() => DriverShellController());

    DriverAuthBinding().dependencies(); // نحتاج LogoutDriverUseCase في تاب "حسابي"
    DriverHomeBinding().dependencies(); // DriverSessionController
    DriverAvailableOrdersBinding().dependencies();
    DriverCurrentTaskBinding().dependencies();
    DriverEarningsCashBinding().dependencies();
    DriverProfileBinding().dependencies();
  }
}
