import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/data/models.dart';
import 'package:project/driver/features/auth/presentation/driver_settings_page.dart';

DriverModel _driver({bool online = false}) => DriverModel.fromJson({
      'id': 3,
      'name': 'سائق',
      'phone': '+970599000000',
      'is_online': online,
      'zone_id': 9,
      'cash_on_hand': {'amount': 900},
      'max_cash': {'amount': 1000},
    });

void main() {
  late List<String> calls;
  late bool online;
  late Either<Failure, void> logoutResult;
  late bool throwOnOffline;

  DriverSignOutUseCase useCase() => DriverSignOutUseCase(
        isOnline: () => online,
        goOffline: () async {
          calls.add('offline');
          if (throwOnOffline) throw Exception('net');
        },
        stopTracking: () => calls.add('stop'),
        unregisterPush: () async => calls.add('unregister'),
        remoteLogout: () async {
          calls.add('logout');
          return logoutResult;
        },
        clearSession: () async => calls.add('clear'),
      );

  setUp(() {
    Get.testMode = true;
    calls = [];
    online = false;
    throwOnOffline = false;
    logoutResult = const Right(null);
  });

  group('DriverSignOutUseCase', () {
    test('online driver: stop → offline → unregister push → logout → clear', () async {
      online = true;
      await useCase()();
      expect(calls, ['stop', 'offline', 'unregister', 'logout', 'clear']);
    });

    test('offline driver skips the status call', () async {
      await useCase()();
      expect(calls, ['stop', 'unregister', 'logout', 'clear']);
    });

    test('clears the session even when logout fails (401/network)', () async {
      logoutResult = const Left(UnauthorizedFailure());
      await useCase()();
      expect(calls.last, 'clear');
    });

    test('clears the session even when going offline throws', () async {
      online = true;
      throwOnOffline = true;
      await useCase()();
      expect(calls, ['stop', 'offline', 'unregister', 'logout', 'clear']);
    });
  });

  group('DriverSettingsController', () {
    DriverSettingsController ctl(Future<Either<Failure, DriverModel>> Function() fetch, {void Function(DriverModel)? onLoaded}) =>
        DriverSettingsController(fetchMe: fetch, signOutUseCase: useCase(), onLoaded: onLoaded);

    test('load success sets driver, clears failure, syncs home', () async {
      DriverModel? synced;
      final c = ctl(() async => Right(_driver()), onLoaded: (m) => synced = m);
      await c.load();
      expect(c.me.value?.id, 3);
      expect(c.me.value?.zoneId, 9);
      expect(c.failure.value, isNull);
      expect(c.loading.value, isFalse);
      expect(synced?.id, 3);
    });

    test('load failure keeps previous data and exposes failure', () async {
      var ok = true;
      final c = ctl(() async => ok ? Right(_driver()) : const Left(NetworkFailure()));
      await c.load();
      ok = false;
      await c.load();
      expect(c.me.value?.id, 3);
      expect(c.failure.value, isA<NetworkFailure>());
      expect(c.loading.value, isFalse);
    });

    test('signOut ignores a double tap while running', () async {
      final c = ctl(() async => Right(_driver()));
      await Future.wait([c.signOut(), c.signOut()]);
      expect(calls.where((e) => e == 'clear').length, 1);
      expect(c.signingOut.value, isFalse);
    });
  });
}
