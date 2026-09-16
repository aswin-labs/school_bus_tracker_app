import 'package:dio/dio.dart';
import 'package:school_bus_tracker/core/network/api_client.dart';
import 'package:school_bus_tracker/core/network/api_endpoints.dart';

class SettingsServices {
  // GET transport staff profile and school details
  Future<Response> fetchProfileAndSchoolDetails() async {
    return await ApiClient.get(ApiEndpoints.getMyProfileAndSchoolDetails);
  }

  // PUT update own profile details for transport staff
  Future<Response> updateOwnProfile({
    required String name,
    required String phone,
    required String email,
  }) async {
    return await ApiClient.put(ApiEndpoints.updateOwnProfileForDriver, {
      "name": name,
      "phone": phone,
      "email": email,
    });
  }

  // POST update profile picture (dp) via FormData
  Future<Response> updateDp({required String filePath}) async {
    final fileName = filePath.split(RegExp(r'[/\\]')).last;
    final formData = FormData.fromMap({
      'dp': await MultipartFile.fromFile(filePath, filename: fileName),
    });
    return await ApiClient.put(ApiEndpoints.updateDp, formData);
  }
}
