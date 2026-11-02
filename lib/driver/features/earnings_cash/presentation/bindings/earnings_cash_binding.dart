import 'package:get/get.dart';
import 'package:project/core/network/api_client.dart';
import 'package:project/driver/features/earnings_cash/data/datasources/earnings_cash_remote_datasource.dart';
import 'package:project/driver/features/earnings_cash/data/repositories/earnings_cash_repository_impl.dart';
import 'package:project/driver/features/earnings_cash/domain/repositories/earnings_cash_repository.dart';
import 'package:project/driver/features/earnings_cash/domain/usecases/get_cash_usecase.dart';
import 'package:project/driver/features/earnings_cash/domain/usecases/get_earnings_usecase.dart';
import 'package:project/driver/features/earnings_cash/presentation/controllers/earnings_cash_controller.dart';

class DriverEarningsCashBinding extends Bindings {
  static void registerCore() {
    Get.lazyPut<EarningsCashRemoteDataSource>(
          () => EarningsCashRemoteDataSourceImpl(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<EarningsCashRepository>(
          () => EarningsCashRepositoryImpl(Get.find()),
      fenix: true,
    );
    Get.lazyPut(() => GetEarningsUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => GetCashUseCase(Get.find()), fenix: true);
  }

  @override
  void dependencies() {
    registerCore();
    Get.lazyPut(() => DriverEarningsCashController(Get.find(), Get.find()));
  }
}
