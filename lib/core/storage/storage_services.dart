import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  static const _kToken = 'auth_token';
  static const _kRefreshToken = 'refresh_token';
  static const _kTheme = 'theme_mode';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // *********** Save **************

  // save token (access token)
  Future<void> saveToken(String token) {
    return _storage.write(key: _kToken, value: token);
  }

  // save refresh token
  Future<void> saveRefreshToken(String refreshToken) {
    return _storage.write(key: _kRefreshToken, value: refreshToken);
  }

  // save both access and refresh tokens
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _kToken, value: accessToken);
    await _storage.write(key: _kRefreshToken, value: refreshToken);
  }

  // save theme mode
  Future<void> saveThemeMode(String mode) {
    return _storage.write(key: _kTheme, value: mode);
  }

  // *********** Read **************

  // get token (access token)
  Future<String?> getToken() {
    return _storage.read(key: _kToken);
  }

  // get refresh token
  Future<String?> getRefreshToken() {
    return _storage.read(key: _kRefreshToken);
  }

  // get theme mode
  Future<String?> getThemeMode() {
    return _storage.read(key: _kTheme);
  }

  // ********** Clear **************
  Future<void> clearAll() {
    return _storage.deleteAll();
  }
}
