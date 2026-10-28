import 'package:shared_preferences/shared_preferences.dart';

abstract class WelcomeLocalDataSource {
  bool isOnboardingSeen();
  Future<void> setOnboardingSeen();
}

class WelcomeLocalDataSourceImpl implements WelcomeLocalDataSource {
  WelcomeLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;

  static const _seenKey = 'onboarding_seen';

  @override
  bool isOnboardingSeen() => _prefs.getBool(_seenKey) ?? false;

  @override
  Future<void> setOnboardingSeen() async {
    await _prefs.setBool(_seenKey, true);
  }
}