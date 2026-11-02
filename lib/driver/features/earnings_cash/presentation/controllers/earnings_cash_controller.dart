import 'package:get/get.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/utils/usecase.dart';
import 'package:project/core/utils/view_status.dart';
import 'package:project/driver/shared/driver_models.dart';
import 'package:project/driver/features/earnings_cash/domain/usecases/get_cash_usecase.dart';
import 'package:project/driver/features/earnings_cash/domain/usecases/get_earnings_usecase.dart';

class DriverEarningsCashController extends GetxController {
  DriverEarningsCashController(this._getEarnings, this._getCash);

  final GetEarningsUseCase _getEarnings;
  final GetCashUseCase _getCash;

  /// 0 = الأرباح، 1 = الرصيد النقدي
  final tab = 0.obs;

  final earnings = Rxn<Earnings>();
  final earningsStatus = ViewStatus.loading.obs;
  final earningsFailure = Rxn<Failure>();

  final cash = Rxn<Cash>();
  final cashStatus = ViewStatus.loading.obs;
  final cashFailure = Rxn<Failure>();

  @override
  void onInit() {
    super.onInit();
    loadEarnings();
    loadCash();
  }

  Future<void> loadEarnings({bool silent = false}) async {
    if (!silent || earnings.value == null) earningsStatus.value = ViewStatus.loading;
    final r = await _getEarnings('week');
    r.fold(
          (f) {
        earningsFailure.value = f;
        if (!silent || earnings.value == null) earningsStatus.value = ViewStatus.error;
      },
          (e) {
        earningsFailure.value = null;
        earnings.value = e;
        earningsStatus.value =
        (e.series.isEmpty && e.orders == 0 && e.earnings.amount <= 0)
            ? ViewStatus.empty
            : ViewStatus.success;
      },
    );
  }

  Future<void> loadCash({bool silent = false}) async {
    if (!silent || cash.value == null) cashStatus.value = ViewStatus.loading;
    final r = await _getCash(const NoParams());
    r.fold(
          (f) {
        cashFailure.value = f;
        if (!silent || cash.value == null) cashStatus.value = ViewStatus.error;
      },
          (c) {
        cashFailure.value = null;
        cash.value = c;
        cashStatus.value = ViewStatus.success;
      },
    );
  }
}
