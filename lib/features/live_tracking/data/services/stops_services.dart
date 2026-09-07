import 'package:dio/dio.dart';
import 'package:school_bus_tracker/core/network/api_endpoints.dart';

import '../../../../core/network/api_client.dart';

class StopServices {
  // GET stops by routeId
  Future<Response> fetchStops({required int routeId}) async {
    final response = await ApiClient.get("${ApiEndpoints.getStops}/$routeId");
    return response;
  }
}
