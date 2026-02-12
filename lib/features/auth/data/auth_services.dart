import 'package:dio/dio.dart';
import 'package:school_bus_tracker/core/network/api_client.dart';
import 'package:school_bus_tracker/core/network/api_endpoints.dart';

class AuthServices {
  //Login
  Future<Response> login({
    required String username,
    required String password,
  }) async {
    return await ApiClient.post(ApiEndpoints.login, {
      'identifier': username,
      'password': password,
    });
  }
}
