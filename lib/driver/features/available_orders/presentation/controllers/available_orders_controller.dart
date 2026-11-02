import 'dart:async';

import 'package:get/get.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/network/models/masar_models.dart';
import 'package:project/core/routes/app_routes.dart';
import 'package:project/core/utils/usecase.dart';
import 'package:project/driver/features/available_orders/domain/usecases/get_available_orders_usecase.dart';
import 'package:project/driver/features/home/presentation/controllers/driver_session_controller.dart';
import 'package:project/driver/shell/driver_shell_controller.dart';

class DriverAvailableOrdersController extends GetxController {
  DriverAvailableOrdersController({required this.getAvailableOrdersUseCase});

  final GetAvailableOrdersUseCase getAvailableOrdersUseCase;

  static const _refreshEvery = Duration(seconds: 20);

  /// قائمة تفاعلية للطلبات المتاحة القادمة من السيرفر.
  final availableOrders = <DriverOrder>[].obs;

  final isFetchLoading = false.obs;
  final hasFetchError = false.obs;
  final fetchFailure = Rxn<Failure>();

  Timer? _timer;

  DriverSessionController get _session => Get.find<DriverSessionController>();

  /// حالة الاتصال مصدرها الجلسة (متزامنة مع السيرفر).
  RxBool get isConnected => _session.isOnline;
  RxBool get isConnecting => _session.isToggling;

  @override
  void onInit() {
    super.onInit();
    // عند الاتصال نجلب الطلبات، وعند الانقطاع نفرّغ القائمة.
    ever<bool>(_session.isOnline, (online) {
      if (online) {
        fetchAvailableOrders();
      } else {
        availableOrders.clear();
      }
    });
    // تحديث تلقائي هادئ بينما التاب مفتوح.
    _timer = Timer.periodic(_refreshEvery, (_) {
      final shell = Get.isRegistered<DriverShellController>()
          ? Get.find<DriverShellController>()
          : null;
      final visible = shell == null || shell.currentIndex.value == 1;
      if (visible && isConnected.value) fetchAvailableOrders(silent: true);
    });
    if (isConnected.value) fetchAvailableOrders();
  }

  /// اتصل الآن / إيقاف الاتصال.
  Future<void> toggleConnection() => _session.toggleOnline();

  /// جلب الطلبات المتاحة. silent = تحديث بالخلفية بدون شاشة تحميل.
  Future<void> fetchAvailableOrders({bool silent = false}) async {
    if (!isConnected.value) return;
    if (!silent || availableOrders.isEmpty) isFetchLoading.value = true;
    hasFetchError.value = false;

    final result = await getAvailableOrdersUseCase.call(const NoParams());

    isFetchLoading.value = false;
    result.fold(
      (failure) {
        fetchFailure.value = failure;
        if (!silent || availableOrders.isEmpty) {
          hasFetchError.value = true;
          availableOrders.clear();
        }
      },
      (ordersList) => availableOrders.assignAll(ordersList),
    );
  }

  /// الانتقال لشاشة تفاصيل الطلب (نمرّر الطلب كاملاً بدل id فقط).
  void goToOrderDetails(DriverOrder order) {
    Get.toNamed(DriverRoutes.orderDetails, arguments: order);
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
