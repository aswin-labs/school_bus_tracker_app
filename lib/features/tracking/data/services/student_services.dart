import 'package:dio/dio.dart';
import 'package:school_bus_tracker/core/network/api_client.dart';
import 'package:school_bus_tracker/core/network/api_endpoints.dart';

class StudentServices {
  // GET students by routeId
  Future<Response> fetchStudentsByRouteId({required int routeId}) async {
    final response = await ApiClient.get(
      "${ApiEndpoints.getStudents}/$routeId",
    );
    return response;
  }

  // POST add students to stop
  Future<Response> addStudentsToStop({
    required List<int> studentIds,
    required int stopId,
  }) async {
    final response = await ApiClient.post(ApiEndpoints.addStudentsToStop, {
      "student_ids": studentIds,
      "stop_id": stopId,
    });
    return response;
  }
}
