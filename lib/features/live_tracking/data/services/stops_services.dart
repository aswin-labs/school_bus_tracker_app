import 'package:dio/dio.dart';
import 'package:school_bus_tracker/core/network/api_endpoints.dart';

import '../../../../core/network/api_client.dart';

class StopServices {
  // POST creating single stop
  Future<Response> createStop({
    required int routeId,
    required String stopName,
    required int priority,
    required double latitude,
    required double longitude,
    required bool both,
  }) async {
    final response = await ApiClient.post(ApiEndpoints.addStop, {
      "route_id": routeId,
      "stop_name": stopName,
      "priority": priority,
      "latitude": latitude,
      "longitude": longitude,
      "both": both,
    });
    return response;
  }

  // PUT update stop details
  Future<Response> updateStop({
    required int stopId,
    required String stopName,
    required double latitude,
    required double longitude,
  }) async {
    final response = await ApiClient.put("${ApiEndpoints.updateStop}/$stopId", {
      "stop_name": stopName,
      "latitude": latitude,
      "longitude": longitude,
    });
    return response;
  }

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
    List<int>? studentIds,
    required double latitude,
    required double longitude,
    required int routeId,
  }) async {
    final body = <String, dynamic>{
      "stop_id": stopId,
      "latitude": latitude,
      "longitude": longitude,
      "route_id": routeId,
    };
    if (studentIds != null) {
      body["student_ids"] = studentIds;
    }
    body["student_ids"] = [];
    final response = await ApiClient.put(
      ApiEndpoints.updateStopAndStudent,
      body,
    );
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

  // GET unassigned stops in pair route
  Future<Response> fetchUnassignedStopsInPairRoute({
    required int routeId,
  }) async {
    final response = await ApiClient.get(
      "${ApiEndpoints.getUnassignedStopsInPairRoute}/$routeId",
    );
    return response;
  }

  // POST assign stop ids from pair route
  Future<Response> assignStopIdsFromPairRoute({
    required int routeId,
    required List<Map<String, dynamic>> stops,
  }) async {
    final response = await ApiClient.post(
      "${ApiEndpoints.assignStopIdsFromPairRoute}/$routeId",
      stops,
    );
    return response;
  }

  // DELETE stop by id
  Future<Response> deleteStop({required int stopId}) async {
    final response = await ApiClient.delete(
      "${ApiEndpoints.deleteStop}/$stopId",
    );
    return response;
  }
}
