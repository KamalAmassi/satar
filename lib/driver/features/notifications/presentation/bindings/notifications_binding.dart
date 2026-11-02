import 'package:get/get.dart';
import 'package:project/core/network/api_client.dart';
import 'package:project/driver/features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:project/driver/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:project/driver/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:project/driver/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:project/driver/features/notifications/presentation/controllers/notifications_controller.dart';

class DriverNotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationsRemoteDataSource>(
          () => NotificationsRemoteDataSourceImpl(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<NotificationsRepository>(
          () => NotificationsRepositoryImpl(Get.find()),
      fenix: true,
    );
    Get.lazyPut(() => GetNotificationsUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => DriverNotificationsController(Get.find()));
  }
}
