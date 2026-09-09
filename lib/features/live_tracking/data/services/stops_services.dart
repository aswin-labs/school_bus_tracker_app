import 'package:dio/dio.dart';
import 'package:school_bus_tracker/core/network/api_endpoints.dart';

import '../../../../core/network/api_client.dart';

class StopServices {
  // GET stops by routeId
  Future<Response> fetchStops({required int routeId}) async {
    final response = await ApiClient.get("${ApiEndpoints.getStops}/$routeId");
    return response;
  }

  // GET single stop details
  Future<Response> fetchSingleStop({
    required int stopId,
    required int routeId,
  }) async {
    final response = await ApiClient.get(
      "${ApiEndpoints.getStopDetails}/$stopId?route_id=$routeId",
    );
    return response;
  }

  // PUT rearrange stop priorities
  Future<Response> rearrangeStopPriorities({
    required int routeId,
    required List<Map<String, int>> stopPriorities,
  }) async {
    final response = await ApiClient.put(
      "${ApiEndpoints.rearrangeStops}/$routeId",
      {"stops": stopPriorities},
    );
    return response;
  }

  // PUT update stop and student
  Future<Response> updateStopAndStudent({
    required int stopId,
    required List<int> studentIds,
    required double latitude,
    required double longitude,
    required int routeId,
  }) async {
    final response = await ApiClient.put(ApiEndpoints.updateStopAndStudent, {
      "stop_id": stopId,
      "student_ids": studentIds,
      "latitude": latitude,
      "longitude": longitude,
      "route_id": routeId,
    });
    return response;
  }

  // POST update route Inactive
  Future<Response> updateRouteInActive({
    required int routeId,
  }) async {
    final response = await ApiClient.post(ApiEndpoints.inActivateRoute, {
      "route_id": routeId,
    });
    return response;
  }

  // POST update live location
  Future<Response> updateLiveLocation({
    required int routeId,
    required double latitude,
    required double longitude,
  }) async {
    final response = await ApiClient.post(ApiEndpoints.updateLiveLocation, {
      "route_id": routeId,
      "latitude": latitude,
      "longitude": longitude,
    });
    return response;
  }
}

