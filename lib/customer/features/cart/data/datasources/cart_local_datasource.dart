import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

abstract class CartLocalDataSource {
  Map<String, dynamic>? read(int userId);
  Future<void> write(int userId, Map<String, dynamic> json);
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  CartLocalDataSourceImpl(this._prefs, {String Function()? role}) : _role = role ?? (() => 'customer');

  final SharedPreferences _prefs;
  final String Function() _role;

  /// مفتاح لكل (دور، مستخدم) حتى لا تظهر سلة حساب في حساب آخر.
  String _key(int userId) => 'cart_${_role()}_$userId';

  /// المفتاح القديم قبل إضافة الدور؛ يُرحَّل مرة واحدة عند أول قراءة.
  static String _legacyKey(int userId) => 'customer_cart_v1_$userId';

  @override
  Map<String, dynamic>? read(int userId) {
    var raw = _prefs.getString(_key(userId));
    if (raw == null) {
      final old = _prefs.getString(_legacyKey(userId));
      if (old == null) return null;
      raw = old;
      _prefs.setString(_key(userId), old);
      _prefs.remove(_legacyKey(userId));
    }
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  @override
  Future<void> write(int userId, Map<String, dynamic> json) =>
      _prefs.setString(_key(userId), jsonEncode(json));
}
