import 'dart:async';

import 'package:get/get.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/routes/app_routes.dart';
import 'package:project/core/services/app_config_service.dart';
import 'package:project/core/services/location_service.dart';
import 'package:project/core/utils/usecase.dart';
import 'package:project/driver/features/earnings_cash/domain/usecases/get_earnings_usecase.dart';
import 'package:project/driver/features/home/domain/usecases/home_usecases.dart';
import 'package:project/driver/shared/driver_models.dart';

/// حالة السائق المشتركة بين كل الشاشات: متصل/غير متصل (متزامنة مع السيرفر)،
/// البروفايل، وإرسال الموقع الدوري. الباقي يقرأ منها فقط.
class DriverSessionController extends GetxController {
  DriverSessionController({
    required this.getProfileUseCase,
    required this.setOnlineUseCase,
    required this.sendLocationUseCase,
    required LocationService location,
  }) : _location = location;

  final GetDriverProfileUseCase getProfileUseCase;
  final SetOnlineStatusUseCase setOnlineUseCase;
  final SendLocationUseCase sendLocationUseCase;
  final LocationService _location;

  final profile = Rxn<Driver>();
  final isOnline = false.obs;
  final isToggling = false.obs;
  final isLoadingProfile = true.obs;
  final profileFailure = Rxn<Failure>();

  /// ملخص اليوم: عدد الطلبات المكتملة (من الأرباح) ووجود مهمة نشطة.
  final completedToday = RxnInt();
  final hasActiveTask = false.obs;
  final toggleFailure = Rxn<Failure>();

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    Get.find<AppConfigService>().load();
    refreshAll();
  }

  Future<void> refreshAll() async {
    await loadProfile();
    await loadTodaySummary();
  }

  /// period=today قد لا يكون مدعوماً؛ لو فشل نترك الشرطات بدون ما نكسر الشاشة.
  Future<void> loadTodaySummary() async {
    if (!Get.isRegistered<GetEarningsUseCase>()) return;
    final result = await Get.find<GetEarningsUseCase>().call('today');
    result.fold((_) => completedToday.value = null, (e) => completedToday.value = e.orders);
  }

  Future<void> loadProfile() async {
    isLoadingProfile.value = true;
    final result = await getProfileUseCase(const NoParams());
    isLoadingProfile.value = false;
    result.fold((f) => profileFailure.value = f, (p) {
      profileFailure.value = null;
      profile.value = p;
      isOnline.value = p.isOnline;
      p.isOnline ? _startLocationUpdates() : _stopLocationUpdates();
    });
  }

  /// يبدّل حالة الاتصال: عند الاتصال نتحقق من إذن الموقع ثم نرسل موقعنا ثم نفعّل الحالة.
  Future<void> toggleOnline() async {
    if (isToggling.value) return;
    toggleFailure.value = null;
    final goOnline = !isOnline.value;

    if (goOnline) {
      final issue = await _location.checkAndRequest();
      if (issue != LocationIssue.none) {
        Get.toNamed(DriverRoutes.locationRequired, arguments: issue);
        return;
      }
    }

    isToggling.value = true;
    if (goOnline) await _pushLocation(); // السيرفر يطلب موقعاً حديثاً قبل الاتصال
    final result = await setOnlineUseCase(SetOnlineStatusParams(online: goOnline));
    isToggling.value = false;

    result.fold((f) => toggleFailure.value = f, (_) {
      isOnline.value = goOnline;
      goOnline ? _startLocationUpdates() : _stopLocationUpdates();
    });
  }

  /// بعد ما السائق يعطي الإذن من شاشة "نحتاج موقعك".
  Future<bool> retryAfterLocationGranted() async {
    final issue = await _location.checkAndRequest();
    if (issue != LocationIssue.none) return false;
    Get.back<void>();
    await toggleOnline();
    return true;
  }

  void _startLocationUpdates() {
    _timer?.cancel();
    final seconds = Get.find<AppConfigService>().locationIntervalSeconds;
    _timer = Timer.periodic(Duration(seconds: seconds), (_) => _pushLocation());
  }

  void _stopLocationUpdates() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _pushLocation() async {
    final p = await _location.current();
    if (p == null) return;
    await sendLocationUseCase(
      SendLocationParams(lat: p.latitude, lng: p.longitude, accuracy: p.accuracy),
    );
  }

  @override
  void onClose() {
    _stopLocationUpdates();
    super.onClose();
  }
}
