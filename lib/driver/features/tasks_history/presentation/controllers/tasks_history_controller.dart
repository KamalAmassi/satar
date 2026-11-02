import 'package:get/get.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/routes/app_routes.dart';
import 'package:project/core/utils/usecase.dart';
import 'package:project/core/utils/view_status.dart';
import 'package:project/driver/features/order_details/presentation/order_details_args.dart';
import 'package:project/driver/features/tasks_history/domain/usecases/get_tasks_history_usecase.dart';
import 'package:project/driver/shared/driver_models.dart';

class DriverTasksHistoryController extends GetxController {
  DriverTasksHistoryController(this._getHistory);

  final GetTasksHistoryUseCase _getHistory;

  final tasks = <DriverOrder>[].obs;
  final status = ViewStatus.loading.obs;
  final failure = Rxn<Failure>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load({bool silent = false}) async {
    if (!silent || tasks.isEmpty) status.value = ViewStatus.loading;
    final result = await _getHistory(const NoParams());
    result.fold(
          (f) {
        failure.value = f;
        if (!silent || tasks.isEmpty) status.value = ViewStatus.error;
      },
          (list) {
        failure.value = null;
        tasks.assignAll(list);
        status.value = list.isEmpty ? ViewStatus.empty : ViewStatus.success;
      },
    );
  }

  void open(DriverOrder order) => Get.toNamed(
    DriverRoutes.taskDetails,
    arguments: OrderDetailsArgs(order: order, mode: OrderDetailsMode.history),
  );
}
