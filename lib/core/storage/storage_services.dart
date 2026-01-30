import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  static const _kToken = 'auth_token';
  static const _kTheme = 'theme_mode';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // *********** Save **************

  // save token
  Future<void> saveToken(String token) {
    return _storage.write(key: _kToken, value: token);
  }

  // save theme mode
  Future<void> saveThemeMode(String mode) {
    return _storage.write(key: _kTheme, value: mode);
  }

  // *********** Read **************

  // get token
  Future<String?> getToken() {
    return _storage.read(key: _kToken);
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
