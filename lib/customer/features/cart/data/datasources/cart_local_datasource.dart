import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

abstract class CartLocalDataSource {
  Map<String, dynamic>? read(int userId);
  Future<void> write(int userId, Map<String, dynamic> json);
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  CartLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;

  /// مفتاح لكل مستخدم حتى لا تظهر سلة حساب في حساب آخر.
  static String _key(int userId) => 'customer_cart_v1_$userId';

  @override
  Map<String, dynamic>? read(int userId) {
    final raw = _prefs.getString(_key(userId));
    if (raw == null) return null;
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  @override
  Future<void> write(int userId, Map<String, dynamic> json) =>
      _prefs.setString(_key(userId), jsonEncode(json));
}
