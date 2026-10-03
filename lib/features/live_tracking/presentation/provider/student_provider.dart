import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:school_bus_tracker/core/utils/api_error_utils.dart';
import 'package:school_bus_tracker/features/live_tracking/data/models/student_model.dart';
import 'package:school_bus_tracker/features/live_tracking/data/models/transport_invoice_model.dart';
import 'package:school_bus_tracker/features/live_tracking/data/services/student_services.dart';

class StudentProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  int _currentPage = 1;
  int get currentPage => _currentPage;

  int _totalPages = 1;
  int get totalPages => _totalPages;

  int _totalContent = 0;
  int get totalContent => _totalContent;

  bool get hasMore => _currentPage < _totalPages;

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

  StudentModel? _studentDetails;
  StudentModel? get studentDetails => _studentDetails;

  bool _isLoadingDetails = false;
  bool get isLoadingDetails => _isLoadingDetails;

  List<TransportInvoiceModel> _invoices = [];
  List<TransportInvoiceModel> get invoices => _invoices;

  bool _isLoadingInvoices = false;
  bool get isLoadingInvoices => _isLoadingInvoices;

  void clearStudentDetails() {
    _studentDetails = null;
    _isLoadingDetails = false;
    _invoices = [];
    _isLoadingInvoices = false;
    notifyListeners();
  }

  void clearInvoices() {
    _invoices = [];
    _isLoadingInvoices = false;
    notifyListeners();
  }

  // fetch transport invoices by student id
  Future<String?> fetchTransportInvoicesByStudentId(int studentId) async {
    _isLoadingInvoices = true;
    _invoices = [];
    notifyListeners();

    try {
      final response = await StudentServices().fetchTransportInvoicesByStudentId(
        studentId: studentId,
      );
      log("Fetch student invoices ($studentId) response: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final rawData = response.data['data'] ?? response.data;
        if (rawData is List) {
          _invoices = rawData
              .map<TransportInvoiceModel>(
                (json) => TransportInvoiceModel.fromJson(json),
              )
              .toList();
          return null;
        }
        return 'No invoice details found';
      }

      return ApiErrorUtils.getErrorMessage(
        data: response.data,
        defaultMessage: "Failed to load transport invoices",
        statusCode: response.statusCode,
      );
    } catch (e, stackTrace) {
      log("Fetch transport invoices error: $e", stackTrace: stackTrace);
      return ApiErrorUtils.getExceptionErrorMessage(e);
    } finally {
      _isLoadingInvoices = false;
      notifyListeners();
    }
  }

  // fetch single student details by id
  Future<String?> fetchStudentDetailsById(int studentId) async {
    _isLoadingDetails = true;
    _studentDetails = null;
    notifyListeners();

    try {
      final response = await StudentServices().fetchStudentDetailsById(
        studentId: studentId,
      );
      log("Fetch student details ($studentId) response: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final rawData = response.data['data'] ?? response.data;
        if (rawData is Map<String, dynamic>) {
          _studentDetails = StudentModel.fromJson(rawData);
          return null;
        }
        return 'No student details found';
      }

      return ApiErrorUtils.getErrorMessage(
        data: response.data,
        defaultMessage: "Failed to load student details",
        statusCode: response.statusCode,
      );
    } catch (e, stackTrace) {
      log("Fetch student details error: $e", stackTrace: stackTrace);
      return ApiErrorUtils.getExceptionErrorMessage(e);
    } finally {
      _isLoadingDetails = false;
      notifyListeners();
    }
  }

  // fetch students (unassigned stops)
  Future<String?> fetchStudentsByRouteId({
    required int routeId,
    int page = 1,
    bool isRefresh = false,
  }) async {
    if (page == 1 || isRefresh) {
      _isLoading = true;
      if (!isRefresh) {
        _students = [];
        _selectedStudentIds.clear();
      }
      _currentPage = 1;
      _totalPages = 1;
      _totalContent = 0;
      notifyListeners();
    } else {
      if (_isLoadingMore || _isLoading) return null;
      _isLoadingMore = true;
      notifyListeners();
    }

    try {
      final response = await StudentServices().fetchStudentsByRouteId(
        routeId: routeId,
        page: page,
      );
      log("Fetch students by routeId response: ${response.data} ");

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final parsed = PaginatedStudentsResponse.fromJson(
            data,
            preferredKey: 'data',
          );

          _currentPage = parsed.currentPage;
          _totalPages = parsed.totalPages;
          _totalContent = parsed.totalContent > 0
              ? parsed.totalContent
              : parsed.students.length;

          if (page == 1 || isRefresh) {
            _students = parsed.students;
          } else {
            final existingIds = _students.map((s) => s.id).toSet();
            for (final s in parsed.students) {
              if (!existingIds.contains(s.id)) {
                _students.add(s);
                existingIds.add(s.id);
              }
            }
          }
        } else if (data is List) {
          final list = data
              .map((result) => StudentModel.fromJson(result))
              .toList();
          _students = list;
          _currentPage = 1;
          _totalPages = 1;
          _totalContent = list.length;
        }

        notifyListeners();
        log('Fetched unassigned students: ${_students.length} (total: $_totalContent, page: $_currentPage/$_totalPages)');
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
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Load next page of students
  Future<String?> loadMoreStudents({required int routeId}) async {
    if (!hasMore || _isLoading || _isLoadingMore) return null;
    return await fetchStudentsByRouteId(
      routeId: routeId,
      page: _currentPage + 1,
    );
  }

  // Explicit alias for fetching unassigned stops
  Future<String?> fetchStudentsWithUnassignedStopsByRouteId({
    required int routeId,
    int page = 1,
    bool isRefresh = false,
  }) async {
    return fetchStudentsByRouteId(
      routeId: routeId,
      page: page,
      isRefresh: isRefresh,
    );
  }

  Future<String?> loadMoreStudentsWithUnassignedStops({required int routeId}) async {
    return loadMoreStudents(routeId: routeId);
  }

  void clearStudents() {
    _students = [];
    _selectedStudentIds.clear();
    _currentPage = 1;
    _totalPages = 1;
    _totalContent = 0;
    _isLoading = false;
    _isLoadingMore = false;
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
