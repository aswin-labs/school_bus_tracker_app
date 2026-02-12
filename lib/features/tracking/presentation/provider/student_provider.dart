import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:school_bus_tracker/features/tracking/data/models/student_model.dart';
import 'package:school_bus_tracker/features/tracking/data/services/student_services.dart';

class StudentProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<StudentModel> _students = [];
  List<StudentModel> get students => _students;

  final Set<int> _selectedStudentIds = {};
  bool _isSubmitting = false;

  Set<int> get selectedStudentIds => _selectedStudentIds;
  bool get isSubmitting => _isSubmitting;

  // fetch students
  Future<void> fetchStudentsByRouteId({required int routeId}) async {
    _isLoading = true;
    try {
      final response = await StudentServices().fetchStudentsByRouteId(
        routeId: routeId,
      );
      if (response.statusCode == 200) {
        _students = (response.data['data'] as List<dynamic>)
            .map((result) => StudentModel.fromJson(result))
            .toList();
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

  Future<bool> addSelectedStudentsToStop(int stopId) async {
    if (_selectedStudentIds.isEmpty) return false;

    _isSubmitting = true;
    notifyListeners();

    try {
      final response = await StudentServices().addStudentsToStop(
        studentIds: _selectedStudentIds.toList(),
        stopId: stopId,
      );

      if (response.statusCode == 200) {
        _selectedStudentIds.clear();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
