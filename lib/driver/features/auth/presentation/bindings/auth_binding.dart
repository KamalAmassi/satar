import 'package:get/get.dart';
import 'package:project/core/network/token_storage.dart';
import 'package:project/driver/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:project/driver/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:project/driver/features/auth/domain/repositories/auth_repository.dart';
import 'package:project/driver/features/auth/domain/usecases/login_driver_usecase.dart';
import 'package:project/driver/features/auth/domain/usecases/logout_driver_usecase.dart';
import 'package:project/driver/features/auth/presentation/controllers/auth_controller.dart';

class DriverAuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverAuthRemoteDataSource>(
      () => DriverAuthRemoteDataSourceImpl(apiClient: Get.find()),
    );

    Get.lazyPut<DriverAuthRepository>(
      () => DriverAuthRepositoryImpl(
        remoteDataSource: Get.find(),
        tokenStorage: Get.find<TokenStorage>(),
      ),
    );

    Get.lazyPut(() => LoginDriverUseCase(repository: Get.find()));
    Get.lazyPut(() => LogoutDriverUseCase(repository: Get.find()));

    Get.lazyPut(
      () => DriverAuthController(
        loginDriverUseCase: Get.find(),
        logoutDriverUseCase: Get.find(),
      ),
    );
  }
}
