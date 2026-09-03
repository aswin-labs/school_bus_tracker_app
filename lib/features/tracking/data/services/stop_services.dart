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
  Future<Response> fetchSingleStop({
    required int stopId,
    required int routeId,
  }) async {
    final response = await ApiClient.get(
      "${ApiEndpoints.getStopDetails}/$stopId?route_id=$routeId",
    );
    return response;
  }

  // POST creating single stop
  Future<Response> createStop({
    required StopModel stop,
    required bool both,
  }) async {
    final response = await ApiClient.post(ApiEndpoints.addStop, {
      "route_id": stop.routeId,
      "stop_name": stop.stopName,
      "priority": stop.priority,
      "latitude": stop.latitude,
      "longitude": stop.longitude,
      "both": both,
    });
    return response;
  }

  // POST creating bulk stops
  Future<Response> createBulkStops({
    required int routeId,
    required List<StopModel> stops,
  }) async {
    final response = await ApiClient.post(ApiEndpoints.addBulkStops, {
      "route_id": routeId,
      "stops": stops
          .map(
            (stop) => {
              "stop_name": stop.stopName,
              "priority": stop.priority,
              "latitude": stop.latitude,
              "longitude": stop.longitude,
            },
          )
          .toList(),
    });
    return response;
  }

  // POST update stop and student
  Future<Response> updateStopAndStudent({
    required List<int> studentIds,
    required int stopId,
    required double latitude,
    required double longitude,
  }) async {
    final response = await ApiClient.put(ApiEndpoints.updateStopAndStudent, {
      "stop_id": stopId,
      "student_ids": studentIds,
      "latitude": latitude,
      "longitude": longitude,
    });
    return response;
  }

  // POST update route Inactive
  Future<Response> updateRouteInActive({
    required int routeId,
    // required String studentStatus,
  }) async {
    final response = await ApiClient.post(ApiEndpoints.updateRouteInactive, {
      "route_id": routeId,
    });
    return response;
  }

  // Update live location
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
