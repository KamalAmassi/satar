import 'package:shared_preferences/shared_preferences.dart';

/// جلسة المستخدم الحالية (التوكن ومعرّف المستخدم).
///
/// [generation] يزيد مع كل دخول أو خروج؛ أي ردّ وصل بعد تغيّر الجيل
/// يخص جلسة سابقة ويجب تجاهله (انظر [SessionGuard]).
class SessionStore {
  SessionStore(this._prefs);

  final SharedPreferences _prefs;

  static const _tokenKey = 'session_token';
  static const _userKey = 'session_user_id';

  int _generation = 0;
  int get generation => _generation;

  String? get token => _prefs.getString(_tokenKey);
  int? get userId => _prefs.getInt(_userKey);
  bool get isSignedIn => token != null && userId != null;

  Future<void> signIn({required String token, required int userId}) async {
    await _prefs.setString(_tokenKey, token);
    await _prefs.setInt(_userKey, userId);
    _generation++;
  }

  Future<void> signOut() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userKey);
    _generation++;
  }

  SessionGuard guard() => SessionGuard._(this, _generation, userId);
}

/// يُلتقط قبل الطلب ويُفحص عند وصول الرد.
class SessionGuard {
  SessionGuard._(this._store, this._generation, this.userId);

  final SessionStore _store;
  final int _generation;
  final int? userId;

  bool get isCurrent =>
      _store.generation == _generation && _store.userId == userId;
}
