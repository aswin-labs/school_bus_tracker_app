import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:school_bus_tracker/core/utils/api_error_utils.dart';
import 'package:school_bus_tracker/features/settings/data/models/school_model.dart';
import 'package:school_bus_tracker/features/settings/data/models/user_model.dart';
import 'package:school_bus_tracker/features/settings/data/services/settings_services.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsServices _settingsServices;

  SettingsProvider([SettingsServices? settingsServices])
      : _settingsServices = settingsServices ?? SettingsServices();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  UserModel? _user;
  UserModel? get user => _user;

  SchoolModel? _school;
  SchoolModel? get school => _school;

  Future<String?> fetchProfileAndSchoolDetails() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _settingsServices.fetchProfileAndSchoolDetails();
      log("Fetch profile and school response: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final rawData = response.data['data'] ?? response.data;

        if (rawData is Map<String, dynamic>) {
          if (rawData['user'] != null && rawData['user'] is Map<String, dynamic>) {
            _user = UserModel.fromJson(rawData['user']);
          }
          if (rawData['school'] != null && rawData['school'] is Map<String, dynamic>) {
            _school = SchoolModel.fromJson(rawData['school']);
          }
        }
        _errorMessage = null;
        return null;
      }

      final error = ApiErrorUtils.getErrorMessage(
        data: response.data,
        defaultMessage: "Failed to load profile details",
        statusCode: response.statusCode,
      );
      _errorMessage = error;
      return error;
    } catch (e, stackTrace) {
      log("Fetch profile error: $e", stackTrace: stackTrace);
      final error = ApiErrorUtils.getExceptionErrorMessage(e);
      _errorMessage = error;
      return error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _isUpdatingProfile = false;
  bool get isUpdatingProfile => _isUpdatingProfile;

  bool _isUpdatingDp = false;
  bool get isUpdatingDp => _isUpdatingDp;

  Future<String?> updateOwnProfile({
    required String name,
    required String phone,
    required String email,
  }) async {
    _isUpdatingProfile = true;
    notifyListeners();

    try {
      final response = await _settingsServices.updateOwnProfile(
        name: name,
        phone: phone,
        email: email,
      );
      log("Update profile response: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (_user != null) {
          _user = UserModel(
            id: _user!.id,
            name: name,
            phone: phone,
            email: email,
            dp: _user!.dp,
            role: _user!.role,
          );
        }
        await fetchProfileAndSchoolDetails();
        return null;
      }

      return ApiErrorUtils.getErrorMessage(
        data: response.data,
        defaultMessage: "Failed to update profile",
        statusCode: response.statusCode,
      );
    } catch (e, stackTrace) {
      log("Update profile error: $e", stackTrace: stackTrace);
      return ApiErrorUtils.getExceptionErrorMessage(e);
    } finally {
      _isUpdatingProfile = false;
      notifyListeners();
    }
  }

  Future<String?> updateDp({required String filePath}) async {
    _isUpdatingDp = true;
    notifyListeners();

    try {
      final response = await _settingsServices.updateDp(filePath: filePath);
      log("Update DP response: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchProfileAndSchoolDetails();
        return null;
      }

      return ApiErrorUtils.getErrorMessage(
        data: response.data,
        defaultMessage: "Failed to update profile picture",
        statusCode: response.statusCode,
      );
    } catch (e, stackTrace) {
      log("Update DP error: $e", stackTrace: stackTrace);
      return ApiErrorUtils.getExceptionErrorMessage(e);
    } finally {
      _isUpdatingDp = false;
      notifyListeners();
    }
  }

  void clearProfile() {
    _user = null;
    _school = null;
    _errorMessage = null;
    notifyListeners();
  }
}
