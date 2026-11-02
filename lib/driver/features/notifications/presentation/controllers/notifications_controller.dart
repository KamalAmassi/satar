import 'package:get/get.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/utils/usecase.dart';
import 'package:project/core/utils/view_status.dart';
import 'package:project/driver/shared/driver_models.dart';
import 'package:project/driver/features/notifications/domain/usecases/get_notifications_usecase.dart';

class DriverNotificationsController extends GetxController {
  DriverNotificationsController(this._get);

  final GetNotificationsUseCase _get;

  final items = <AppNotification>[].obs;
  final status = ViewStatus.loading.obs;
  final failure = Rxn<Failure>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    status.value = ViewStatus.loading;
    final r = await _get(const NoParams());
    r.fold(
          (f) {
        failure.value = f;
        status.value = ViewStatus.error;
      },
          (list) {
        failure.value = null;
        items.assignAll(list);
        status.value = list.isEmpty ? ViewStatus.empty : ViewStatus.success;
      },
    );
  }
}
