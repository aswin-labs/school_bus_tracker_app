import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:school_bus_tracker/core/storage/storage_services.dart';
import 'package:school_bus_tracker/features/auth/data/auth_services.dart';

class AuthProvider extends ChangeNotifier {
  final AuthServices _authService = AuthServices();
  final StorageService _storageService = StorageService.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  
  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  /// Login
  Future<String?> login({
    required String username,
    required String password,
  }) async {
    if (_isLoading) return null;

    _setLoading(true);

    try {
      final response = await _authService.login(
        username: username,
        password: password,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final token = data['accessToken'] as String?;

        if (token == null) {
          return "Invalid server response";
        }

        await _storageService.saveToken(token);
        log("Login Success");
        return null; // null = success
      }

      // Server returned an error
      final errorMsg =
          response.data['message'] ??
          "Login failed with status ${response.statusCode}";
      return errorMsg;
    } catch (e) {
      log("Login error: $e");
      return "Something went wrong. Please try again.";
    } finally {
      _setLoading(false);
    }
  }

  /// Logout
  Future<String?> logout() async {
    if (_isLoading) return "Already logging out";
    _setLoading(true);
    try {
      await _storageService.clearAll();
      return null;
    } catch (e) {
      return "Failed to logout. Try again.";
    } finally {
      _setLoading(false);
    }
  }
}
