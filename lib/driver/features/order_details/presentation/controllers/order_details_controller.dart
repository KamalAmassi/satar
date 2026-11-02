import 'package:get/get.dart';
import 'package:project/core/errors/api_error_codes.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/routes/app_routes.dart';
import 'package:project/driver/features/available_orders/domain/usecases/accept_order_usecase.dart';
import 'package:project/driver/features/available_orders/presentation/controllers/available_orders_controller.dart';
import 'package:project/driver/features/current_task/presentation/controllers/current_task_controller.dart';
import 'package:project/driver/features/home/presentation/controllers/driver_session_controller.dart';
import 'package:project/driver/shared/driver_models.dart';

enum OrderAcceptanceState {
  details, // D11 قبل القبول
  accepting, // D12 جاري القبول
  success, // D13 نجاح القبول
  alreadyTaken, // D14 سبقك سائق آخر
  offline, // D15 لازم تكون متصل
  busy, // D16 عندك مهمة نشطة
  cashLimit, // D17 حد التحصيل النقدي
  error, // D18 خطأ عام
}

class DriverOrderDetailsController extends GetxController {
  DriverOrderDetailsController({required this.acceptOrderUseCase});

  final AcceptOrderUseCase acceptOrderUseCase;

  final acceptanceState = OrderAcceptanceState.details.obs;
  final currentOrder = Rxn<DriverOrder>();
  final errorMessage = RxnString();

  DriverSessionController get _session => Get.find<DriverSessionController>();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is DriverOrder) currentOrder.value = args;
  }

  Future<void> acceptCurrentOrder() async {
    final order = currentOrder.value;
    if (order == null) return;

    // فحوصات محلية قبل ما نكلّم السيرفر.
    if (!_session.isOnline.value) {
      acceptanceState.value = OrderAcceptanceState.offline;
      return;
    }
    if (Get.isRegistered<DriverCurrentTaskController>() &&
        Get.find<DriverCurrentTaskController>().task.value != null) {
      acceptanceState.value = OrderAcceptanceState.busy;
      return;
    }

    acceptanceState.value = OrderAcceptanceState.accepting;
    errorMessage.value = null;

    final result = await acceptOrderUseCase.call(
      AcceptOrderParams(orderId: order.id.toString()),
    );

    result.fold(_onFailure, (accepted) {
      acceptanceState.value = OrderAcceptanceState.success;
      // المهمة الحالية صارت الطلب المقبول، ونحدّث قائمة المتاح بالخلفية.
      if (Get.isRegistered<DriverCurrentTaskController>()) {
        Get.find<DriverCurrentTaskController>().setTask(accepted);
      }
      _session.hasActiveTask.value = true;
      if (Get.isRegistered<DriverAvailableOrdersController>()) {
        Get.find<DriverAvailableOrdersController>().fetchAvailableOrders(silent: true);
      }
    });
  }

  /// نقرأ error.code من السيرفر (مو نص الرسالة) لتحديد الشاشة المناسبة.
  void _onFailure(Failure f) {
    errorMessage.value = f.message;
    if (f is NetworkFailure || f is TimeoutFailure) {
      acceptanceState.value = OrderAcceptanceState.error;
      return;
    }
    switch (f.code) {
      case ApiErrorCodes.alreadyTaken:
        acceptanceState.value = OrderAcceptanceState.alreadyTaken;
      case ApiErrorCodes.cashLimitReached:
        acceptanceState.value = OrderAcceptanceState.cashLimit;
      case ApiErrorCodes.conflict:
        acceptanceState.value = OrderAcceptanceState.busy;
      default:
        acceptanceState.value = OrderAcceptanceState.error;
    }
  }

  void resetToDetails() => acceptanceState.value = OrderAcceptanceState.details;

  /// يرجع لقائمة المتاح (التاب 1).
  void backToOrders() =>
      Get.offAllNamed(DriverRoutes.home, arguments: {'tab': 1});

  /// يفتح شاشة المهمة النشطة (التاب 2).
  void viewActiveTask() =>
      Get.offAllNamed(DriverRoutes.home, arguments: {'tab': 2});

  void openCash() => Get.offNamedUntil(
        DriverRoutes.earningsCash,
        (r) => r.settings.name == DriverRoutes.home,
      );

  Future<void> connectNow() async {
    await _session.toggleOnline();
    if (_session.isOnline.value) resetToDetails();
  }
}
