import 'package:dio/dio.dart';
import 'package:school_bus_tracker/core/network/api_client.dart';
import 'package:school_bus_tracker/core/network/api_endpoints.dart';

class RouteServices {
  // GET driver routes
  Future<Response> fetchDriverRoutes() async {
    return await ApiClient.get(ApiEndpoints.routes);
  }

  // POST driver route active
  Future<Response> activateRoute(int routeId) async {
    return await ApiClient.post(ApiEndpoints.activateRoute, {
      "route_id": routeId,
    });
  }
}
