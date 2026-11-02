import 'package:get_storage/get_storage.dart';

abstract class TokenStorage {
  Future<String?> readToken();
  Future<void> saveToken(String token);
  Future<void> clearToken();
}

/// تخزين دائم للتوكن باستخدام GetStorage.
/// يجب استدعاء GetStorage.init() قبل تشغيل التطبيق في main.dart.
class GetStorageTokenStorage implements TokenStorage {
  GetStorageTokenStorage({GetStorage? storage})
      : _storage = storage ?? GetStorage();

  final GetStorage _storage;
  static const String _tokenKey = 'access_token';

  @override
  Future<String?> readToken() async {
    final token = _storage.read<String>(_tokenKey);
    if (token == null || token.trim().isEmpty) return null;
    return token;
  }

  @override
  Future<void> saveToken(String token) async {
    final value = token.trim();
    if (value.isEmpty) {
      throw ArgumentError.value(token, 'token', 'Token cannot be empty.');
    }
    await _storage.write(_tokenKey, value);
  }

  @override
  Future<void> clearToken() async {
    await _storage.remove(_tokenKey);
  }
}
