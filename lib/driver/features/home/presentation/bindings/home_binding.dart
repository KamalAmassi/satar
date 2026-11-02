import 'package:get/get.dart';
import 'package:project/core/services/location_service.dart';
import 'package:project/driver/features/home/data/datasources/home_remote_datasource.dart';
import 'package:project/driver/features/home/data/repositories/home_repository_impl.dart';
import 'package:project/driver/features/home/domain/repositories/driver_home_repository.dart';
import 'package:project/driver/features/home/domain/usecases/home_usecases.dart';
import 'package:project/driver/features/home/presentation/controllers/driver_session_controller.dart';

class DriverHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverHomeRemoteDataSource>(
      () => DriverHomeRemoteDataSourceImpl(apiClient: Get.find()),
      fenix: true,
    );
    Get.lazyPut<DriverHomeRepository>(
      () => DriverHomeRepositoryImpl(remoteDataSource: Get.find()),
      fenix: true,
    );
    Get.lazyPut(() => GetDriverProfileUseCase(repository: Get.find()), fenix: true);
    Get.lazyPut(() => SetOnlineStatusUseCase(repository: Get.find()), fenix: true);
    Get.lazyPut(() => SendLocationUseCase(repository: Get.find()), fenix: true);
    Get.lazyPut(
      () => DriverSessionController(
        getProfileUseCase: Get.find(),
        setOnlineUseCase: Get.find(),
        sendLocationUseCase: Get.find(),
        location: Get.find<LocationService>(),
      ),
      fenix: true,
    );
  }
}
