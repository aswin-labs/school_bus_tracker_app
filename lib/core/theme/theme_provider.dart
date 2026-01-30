import 'package:flutter/material.dart';
import 'package:school_bus_tracker/core/storage/storage_services.dart';

class ThemeProvider extends ChangeNotifier {
  final _storage = StorageService.instance;

  ThemeMode _mode = ThemeMode.light;
  ThemeMode get mode => _mode;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final saved = await _storage.getThemeMode();
    if (saved == 'dark') {
      _mode = ThemeMode.dark;
    } else {
      _mode = ThemeMode.light;
    }
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _mode =
        _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;

    await _storage.saveThemeMode(
      _mode == ThemeMode.dark ? 'dark' : 'light',
    );

    notifyListeners();
  }
}
