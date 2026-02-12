import 'package:dio/dio.dart';
import 'package:school_bus_tracker/core/network/api_client.dart';
import 'package:school_bus_tracker/core/network/api_endpoints.dart';
import 'package:school_bus_tracker/features/tracking/data/models/stop_model.dart';

class StopServices {
  // GET stops by routeId
  Future<Response> fetchStops({required int routeId}) async {
    final response = await ApiClient.get("${ApiEndpoints.getStops}/$routeId");
    return response;
  }

  // GET stop details
  Future<Response> fetchSingleStop({required int stopId}) async {
    final response = await ApiClient.get(
      "${ApiEndpoints.getStopDetails}/$stopId",
    );
    return response;
  }

  // POST adding stops
  Future<Response> sendStop({required StopModel stop}) async {
    final response = await ApiClient.post(ApiEndpoints.addStop, {
      "route_id": stop.routeId,
      "stop_name": stop.stopName,
      "priority": stop.priority,
      "latitude": stop.latitude,
      "longitude": stop.longitude,
    });
    return response;
  }
}
