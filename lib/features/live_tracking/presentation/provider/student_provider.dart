import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:school_bus_tracker/core/utils/api_error_utils.dart';
import 'package:school_bus_tracker/features/live_tracking/data/models/student_model.dart';
import 'package:school_bus_tracker/features/live_tracking/data/services/student_services.dart';

class StudentProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<StudentModel> _students = [];
  List<StudentModel> get students => _students;

  final Set<int> _selectedStudentIds = {};
  bool _isSubmitting = false;

  Set<int> get selectedStudentIds => _selectedStudentIds;
  bool get isSubmitting => _isSubmitting;

  bool _isDeleting = false;
  bool get isDeleting => _isDeleting;

  int? _deletingStudentId;
  int? get deletingStudentId => _deletingStudentId;

  // fetch students
  Future<String?> fetchStudentsByRouteId({required int routeId}) async {
    _students = [];
    _isLoading = true;
    notifyListeners();
    try {
      final response = await StudentServices().fetchStudentsByRouteId(
        routeId: routeId,
      );
      log("Fetch students by routeId response: ${response.data} ");
      if (response.statusCode == 200) {
        _students = (response.data['data'] as List<dynamic>)
            .map((result) => StudentModel.fromJson(result))
            .toList();
        return null;
      }
      return ApiErrorUtils.getErrorMessage(
        data: response.data,
        defaultMessage: "Failed to load students",
        statusCode: response.statusCode,
      );
    } catch (e, stackTrace) {
      log("Fetch students error: $e", stackTrace: stackTrace);
      return ApiErrorUtils.getExceptionErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearStudents() {
    _students = [];
    _selectedStudentIds.clear();
    notifyListeners();
  }

  void toggleStudentSelection(int studentId) {
    if (_selectedStudentIds.contains(studentId)) {
      _selectedStudentIds.remove(studentId);
    } else {
      _selectedStudentIds.add(studentId);
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedStudentIds.clear();
    notifyListeners();
  }

  Future<String?> addSelectedStudentsToStop(int stopId) async {
    if (_selectedStudentIds.isEmpty) return 'No students selected';

    _isSubmitting = true;
    notifyListeners();

    try {
      final response = await StudentServices().addStudentsToStop(
        studentIds: _selectedStudentIds.toList(),
        stopId: stopId,
      );
      log("Selected student IDs: ${_selectedStudentIds.toList()}");
      log("Add students to stop response: ${response.data} ");

      if (response.statusCode == 200 || response.statusCode == 201) {
        _selectedStudentIds.clear();
        return null;
      }
      return ApiErrorUtils.getErrorMessage(
        data: response.data,
        defaultMessage: "Failed to add students to stop",
        statusCode: response.statusCode,
      );
    } catch (e, stackTrace) {
      log("Add students to stop error: $e", stackTrace: stackTrace);
      return ApiErrorUtils.getExceptionErrorMessage(e);
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // edit student stop status
  Future<bool> editStudentStopStatus({
    required int studentStopId,
    required String studentId,
    required String status,
  }) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      final response = await StudentServices().editStudentsStopStatus(
        studentStopId: studentStopId,
        studentId: studentId,
        status: status,
      );

      if (response.statusCode == 200) {
        log("Student stop status updated successfully.");
        return true;
      }
      return false;
    } catch (e) {
      log(e.toString());
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // delete student from stop
  Future<String?> deleteStudentFromStop({
    required int stopId,
    required int studentId,
  }) async {
    _isDeleting = true;
    _deletingStudentId = studentId;
    notifyListeners();

    try {
      final response = await StudentServices().deleteStudentFromStop(
        stopId: stopId,
        studentId: studentId,
      );

      log("Delete student from stop response: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        return null;
      }
      return ApiErrorUtils.getErrorMessage(
        data: response.data,
        defaultMessage: "Failed to remove student from stop",
        statusCode: response.statusCode,
      );
    } catch (e, stackTrace) {
      log("Delete student from stop error: $e", stackTrace: stackTrace);
      return ApiErrorUtils.getExceptionErrorMessage(e);
    } finally {
      _isDeleting = false;
      _deletingStudentId = null;
      notifyListeners();
    }
  }
}
