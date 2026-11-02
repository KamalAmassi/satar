import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/errors/api_error_codes.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/routes/app_routes.dart';
import 'package:project/core/utils/usecase.dart';
import 'package:project/core/utils/view_status.dart';
import 'package:project/driver/features/current_task/domain/usecases/get_current_task_usecase.dart';
import 'package:project/driver/features/current_task/domain/usecases/transition_order_usecase.dart';
import 'package:project/driver/features/order_details/presentation/order_details_args.dart';
import 'package:project/driver/shared/driver_models.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/driver/features/home/presentation/controllers/driver_session_controller.dart';
import 'package:project/driver/shell/driver_shell_controller.dart';
import 'package:url_launcher/url_launcher.dart';

/// حالة المهمة الحالية. تُستخدم من الخريطة والتسليم وتعذّر التسليم أيضاً.
class DriverCurrentTaskController extends GetxController {
  DriverCurrentTaskController(this._getCurrent, this._transition);

  final GetCurrentTaskUseCase _getCurrent;
  final TransitionOrderUseCase _transition;

  final task = Rxn<DriverOrder>();
  final status = ViewStatus.loading.obs;
  final failure = Rxn<Failure>();

  /// الحالة تغيّرت من طرف السيرفر (invalid_transition).
  final isStale = false.obs;
  final isTransitioning = false.obs;
  final transitionFailure = Rxn<Failure>();

  @override
  void onInit() {
    super.onInit();
    load();
    ever<int>(Get.find<DriverShellController>().currentIndex, (i) {
      if (i == 2) load(silent: true);
    });
  }

  Future<void> load({bool silent = false}) async {
    if (!silent || task.value == null) status.value = ViewStatus.loading;
    final result = await _getCurrent(const NoParams());
    result.fold(
          (f) {
        failure.value = f;
        if (!silent || task.value == null) status.value = ViewStatus.error;
      },
          (order) {
        failure.value = null;
        isStale.value = false;
        setTask(order);
      },
    );
  }

  void setTask(DriverOrder? order) {
    task.value = order;
    if (Get.isRegistered<DriverSessionController>()) {
      Get.find<DriverSessionController>().hasActiveTask.value = order != null;
    }
    status.value = order == null ? ViewStatus.empty : ViewStatus.success;
  }

  /// ينفّذ الانتقال ويرجع true عند النجاح.
  Future<bool> transitionTo(
      String to, {
        Map<String, dynamic> fields = const {},
        List<int> uploadIds = const [],
      }) async {
    final current = task.value;
    if (current == null || isTransitioning.value) return false;
    isTransitioning.value = true;
    transitionFailure.value = null;
    final result = await _transition(
      TransitionParams(
        orderId: current.id,
        to: to,
        fields: fields,
        uploadIds: uploadIds,
      ),
    );
    isTransitioning.value = false;
    return result.fold(
          (f) {
        transitionFailure.value = f;
        if (f.code == ApiErrorCodes.invalidTransition) isStale.value = true;
        return false;
      },
          (updated) {
        setTask(updated);
        return true;
      },
    );
  }

  void openDetails() {
    final t = task.value;
    if (t == null) return;
    Get.toNamed(
      DriverRoutes.taskDetails,
      arguments: OrderDetailsArgs(order: t, mode: OrderDetailsMode.task),
    );
  }

  void openMap() => Get.toNamed(DriverRoutes.mapNavigation);

  void goToOrders() => Get.find<DriverShellController>().goToTab(1);

  /// رسالة تأكيد اختيارية يحددها السيرفر (next_action.confirm).
  Future<bool> _confirm(String? message) async {
    if (message == null || message.isEmpty) return true;
    final ok = await Get.dialog<bool>(
      AlertDialog(
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: Text(Get.context!.l10n.cancel)),
          TextButton(onPressed: () => Get.back(result: true), child: Text(Get.context!.l10n.confirm)),
        ],
      ),
    );
    return ok == true;
  }

  /// يوجّه حسب الخطوة التالية من السيرفر.
  Future<void> advance() async {
    final next = task.value?.nextAction;
    if (next == null) return;
    if (!await _confirm(next.confirm)) return;
    switch (next.to) {
      case 'picked_up':
        Get.toNamed(DriverRoutes.pickupConfirmation);
      case 'delivered':
        Get.toNamed(DriverRoutes.deliveryConfirmation);
      case 'delivery_failed':
        Get.toNamed(DriverRoutes.deliveryFailure);
      case 'on_the_way':
        if (await transitionTo('on_the_way')) openMap();
      default:
        await transitionTo(next.to);
    }
  }

  void reportFailure() => Get.toNamed(DriverRoutes.deliveryFailure);

  Future<void> callCustomer() async {
    final o = task.value;
    final phone = o?.customerPhone;
    if (phone == null || phone.isEmpty) return;
    await launchUrl(Uri(scheme: 'tel', path: phone));
  }
}
