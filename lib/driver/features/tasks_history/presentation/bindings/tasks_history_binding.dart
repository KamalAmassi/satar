import 'package:get/get.dart';
import 'package:project/core/network/api_client.dart';
import 'package:project/driver/features/tasks_history/data/datasources/tasks_history_remote_datasource.dart';
import 'package:project/driver/features/tasks_history/data/repositories/tasks_history_repository_impl.dart';
import 'package:project/driver/features/tasks_history/domain/repositories/tasks_history_repository.dart';
import 'package:project/driver/features/tasks_history/domain/usecases/get_tasks_history_usecase.dart';
import 'package:project/driver/features/tasks_history/presentation/controllers/tasks_history_controller.dart';

class DriverTasksHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TasksHistoryRemoteDataSource>(
          () => TasksHistoryRemoteDataSourceImpl(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<TasksHistoryRepository>(
          () => TasksHistoryRepositoryImpl(Get.find()),
      fenix: true,
    );
    Get.lazyPut(() => GetTasksHistoryUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => DriverTasksHistoryController(Get.find()));
  }
}
