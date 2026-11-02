import 'package:get/get.dart';
import 'package:project/core/network/api_client.dart';
import 'package:project/core/services/upload_service.dart';
import 'package:project/driver/features/current_task/data/datasources/current_task_remote_datasource.dart';
import 'package:project/driver/features/current_task/data/repositories/current_task_repository_impl.dart';
import 'package:project/driver/features/current_task/domain/repositories/current_task_repository.dart';
import 'package:project/driver/features/current_task/domain/usecases/get_current_task_usecase.dart';
import 'package:project/driver/features/current_task/domain/usecases/transition_order_usecase.dart';
import 'package:project/driver/features/current_task/domain/usecases/upload_proof_photo_usecase.dart';
import 'package:project/driver/features/current_task/presentation/controllers/current_task_controller.dart';
import 'package:project/driver/features/current_task/presentation/controllers/pickup_confirmation_controller.dart';

class DriverCurrentTaskBinding extends Bindings {
  static void registerCore() {
    Get.lazyPut(() => UploadService(Get.find<ApiClient>()), fenix: true);
    Get.lazyPut<CurrentTaskRemoteDataSource>(
          () => CurrentTaskRemoteDataSourceImpl(Get.find<ApiClient>(), Get.find()),
      fenix: true,
    );
    Get.lazyPut<CurrentTaskRepository>(
          () => CurrentTaskRepositoryImpl(Get.find()),
      fenix: true,
    );
    Get.lazyPut(() => GetCurrentTaskUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => TransitionOrderUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => UploadProofPhotoUseCase(Get.find()), fenix: true);
  }

  @override
  void dependencies() {
    registerCore();
    Get.lazyPut(() => DriverCurrentTaskController(Get.find(), Get.find()));
  }
}

/// route مستقل لشاشة تأكيد الاستلام.
class DriverPickupConfirmationBinding extends Bindings {
  @override
  void dependencies() {
    DriverCurrentTaskBinding.registerCore();
    Get.lazyPut(() => DriverPickupConfirmationController(Get.find()));
  }
}
