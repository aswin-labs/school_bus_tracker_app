import 'package:dio/dio.dart';
import 'package:school_bus_tracker/core/network/api_client.dart';
import 'package:school_bus_tracker/core/network/api_endpoints.dart';

class StudentServices {
  // GET students by routeId (students with unassigned stops)
  Future<Response> fetchStudentsByRouteId({
    required int routeId,
    int page = 1,
    int? limit,
  }) async {
    final Map<String, dynamic> queryParams = {
      "page": page,
      if (limit != null) "limit": limit,
    };
    final response = await ApiClient.get(
      "${ApiEndpoints.getStudentsWithUnassignedStopsByRouteId}/$routeId",
      queryParameters: queryParams,
    );
    return response;
  }

  // GET students with unassigned stops by routeId (explicit endpoint name)
  Future<Response> fetchStudentsWithUnassignedStopsByRouteId({
    required int routeId,
    int page = 1,
    int? limit,
  }) async {
    return fetchStudentsByRouteId(
      routeId: routeId,
      page: page,
      limit: limit,
    );
  }

  // GET student details by id
  Future<Response> fetchStudentDetailsById({required int studentId}) async {
    final response = await ApiClient.get(
      "${ApiEndpoints.getStudentDetailsById}/$studentId",
    );
    return response;
  }

  // GET transport invoices by student id
  Future<Response> fetchTransportInvoicesByStudentId({
    required int studentId,
  }) async {
    final response = await ApiClient.get(
      "${ApiEndpoints.getTransportInvoiceByStudentId}/$studentId",
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

  // PUT edit students stop status
  Future<Response> editStudentsStopStatus({
    required int studentStopId,
    required String studentId,
    required String status,
  }) async {
    final response = await ApiClient.put(
      "${ApiEndpoints.editStudentsStopStatus}/$studentStopId",
      {"student_id": studentId, "status": status},
    );
    return response;
  }

  // delete student from stop
  Future<Response> deleteStudentFromStop({
    required int stopId,
    required int studentId,
  }) async {
    final response = await ApiClient.delete(
      "${ApiEndpoints.deleteStudentFromStop}/$stopId/$studentId",
    );
    return response;
  }
}
