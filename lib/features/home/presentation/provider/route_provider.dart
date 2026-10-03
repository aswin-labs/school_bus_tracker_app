import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:school_bus_tracker/core/utils/api_error_utils.dart';
import 'package:school_bus_tracker/features/home/data/models/route_model.dart';
import 'package:school_bus_tracker/features/home/data/services/route_services.dart';
import 'package:school_bus_tracker/features/live_tracking/data/models/student_model.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/provider/stops_provider.dart';

class RouteProvider extends ChangeNotifier {
  final RouteServices _routeServices;
  StopsProvider _stopsProvider;

  RouteProvider(this._routeServices, this._stopsProvider);

  void updateStopsProvider(StopsProvider stopsProvider) {
    _stopsProvider = stopsProvider;
  }
  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isActivating = false;
  bool get isActivating => _isActivating;

  bool _isDeactivating = false;
  bool get isDeactivating => _isDeactivating;

  bool _isLoadingStudents = false;
  bool get isLoadingStudents => _isLoadingStudents;

  bool _isLoadingMoreStudents = false;
  bool get isLoadingMoreStudents => _isLoadingMoreStudents;

  int _routeStudentsCurrentPage = 1;
  int get routeStudentsCurrentPage => _routeStudentsCurrentPage;

  int _routeStudentsTotalPages = 1;
  int get routeStudentsTotalPages => _routeStudentsTotalPages;

  int _routeStudentsTotalContent = 0;
  int get routeStudentsTotalContent => _routeStudentsTotalContent;

  bool get hasMoreRouteStudents =>
      _routeStudentsCurrentPage < _routeStudentsTotalPages;

  List<RouteModel> _routes = [];
  List<RouteModel> get driverRoutes => _routes;

  List<StudentModel> _routeStudents = [];
  List<StudentModel> get routeStudents => _routeStudents;

  // ---------------------------------------------------------------------------
  // Loading helpers
  // ---------------------------------------------------------------------------

  void _setLoading(bool value) {
    if (_isLoading == value) return;

    _isLoading = value;
    notifyListeners();
  }

  void _setActivating(bool value) {
    if (_isActivating == value) return;

    _isActivating = value;
    notifyListeners();
  }

  void _setDeactivating(bool value) {
    if (_isDeactivating == value) return;

    _isDeactivating = value;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Fetch routes
  // ---------------------------------------------------------------------------

  Future<String?> fetchDriverRoutes() async {
    _setLoading(true);

    try {
      final response = await _routeServices.fetchDriverRoutes();

      log('Fetch driver routes response: ${response.data}');

      if (response.statusCode != 200) {
        return ApiErrorUtils.getErrorMessage(
          data: response.data,
          defaultMessage: 'Failed to fetch routes',
          statusCode: response.statusCode,
        );
      }

      final data = response.data['data'];

      if (data is! List) {
        _routes = [];
        notifyListeners();
        return 'No routes found';
      }

      _routes = data
          .map<RouteModel>((json) => RouteModel.fromJson(json))
          .toList();

      notifyListeners();

      log('Fetched routes: $_routes');

      return null;
    } catch (e, stackTrace) {
      log('Fetch driver routes error: $e', stackTrace: stackTrace);

      return ApiErrorUtils.getExceptionErrorMessage(e);
    } finally {
      _setLoading(false);
    }
  }

  // ---------------------------------------------------------------------------
  // Activate route
  // ---------------------------------------------------------------------------

  Future<String?> activateRoute(int routeId) async {
    _setActivating(true);

    try {
      final response = await _routeServices.activateRoute(routeId);

      if (response.statusCode != 200) {
        return ApiErrorUtils.getErrorMessage(
          data: response.data,
          defaultMessage: 'Failed to Activate route',
          statusCode: response.statusCode,
        );
      }

      await _stopsProvider.startLiveLocationSharing(routeId);
      // await fetchDriverRoutes();

      log('Route $routeId is live');

      return null;
    } catch (e, stackTrace) {
      log('Activate route error: $e', stackTrace: stackTrace);

      return ApiErrorUtils.getExceptionErrorMessage(e);
    } finally {
      _setActivating(false);
    }
  }

  // ---------------------------------------------------------------------------
  // Deactivate route
  // ---------------------------------------------------------------------------

  Future<String?> inactivateRoute(int routeId) async {
    _setDeactivating(true);

    try {
      final response = await _routeServices.inactivateRoute(routeId);

      if (response.statusCode != 200) {
        return ApiErrorUtils.getErrorMessage(
          data: response.data,
          defaultMessage: 'Failed to deactivate route',
          statusCode: response.statusCode,
        );
      }
      _stopsProvider.stopLiveLocationSharing();
      _stopsProvider.reset();
      await fetchDriverRoutes();

      log('Route $routeId is inactive');

      return null;
    } catch (e, stackTrace) {
      log('Deactivate route error: $e', stackTrace: stackTrace);

      return ApiErrorUtils.getExceptionErrorMessage(e);
    } finally {
      _setDeactivating(false);
    }
  }

  // ---------------------------------------------------------------------------
  // Students by Route
  // ---------------------------------------------------------------------------

  void clearRouteStudents() {
    _routeStudents = [];
    _routeStudentsCurrentPage = 1;
    _routeStudentsTotalPages = 1;
    _routeStudentsTotalContent = 0;
    _isLoadingStudents = false;
    _isLoadingMoreStudents = false;
    notifyListeners();
  }

  Future<String?> fetchStudentsByRouteId(
    int routeId, {
    int page = 1,
    bool isRefresh = false,
  }) async {
    if (page == 1 || isRefresh) {
      _isLoadingStudents = true;
      if (!isRefresh) {
        _routeStudents = [];
      }
      _routeStudentsCurrentPage = 1;
      _routeStudentsTotalPages = 1;
      _routeStudentsTotalContent = 0;
      notifyListeners();
    } else {
      if (_isLoadingMoreStudents || _isLoadingStudents) return null;
      _isLoadingMoreStudents = true;
      notifyListeners();
    }

    try {
      final response = await _routeServices.fetchStudentsByRouteId(
        routeId,
        page: page,
      );

      log('Fetch route students response: ${response.data}');

      if (response.statusCode != 200) {
        return ApiErrorUtils.getErrorMessage(
          data: response.data,
          defaultMessage: 'Failed to fetch students',
          statusCode: response.statusCode,
        );
      }

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final parsed = PaginatedStudentsResponse.fromJson(
          data,
          preferredKey: 'students',
        );

        _routeStudentsCurrentPage = parsed.currentPage;
        _routeStudentsTotalPages = parsed.totalPages;
        _routeStudentsTotalContent = parsed.totalContent > 0
            ? parsed.totalContent
            : parsed.students.length;

        if (page == 1 || isRefresh) {
          _routeStudents = parsed.students;
        } else {
          final existingIds = _routeStudents.map((s) => s.id).toSet();
          for (final s in parsed.students) {
            if (!existingIds.contains(s.id)) {
              _routeStudents.add(s);
              existingIds.add(s.id);
            }
          }
        }
      } else if (data is List) {
        final list = data
            .map<StudentModel>((json) => StudentModel.fromJson(json))
            .toList();
        _routeStudents = list;
        _routeStudentsCurrentPage = 1;
        _routeStudentsTotalPages = 1;
        _routeStudentsTotalContent = list.length;
      }

      notifyListeners();
      log('Fetched route students: ${_routeStudents.length} (total: $_routeStudentsTotalContent, page: $_routeStudentsCurrentPage/$_routeStudentsTotalPages)');

      return null;
    } catch (e, stackTrace) {
      log('Fetch route students error: $e', stackTrace: stackTrace);

      return ApiErrorUtils.getExceptionErrorMessage(e);
    } finally {
      _isLoadingStudents = false;
      _isLoadingMoreStudents = false;
      notifyListeners();
    }
  }

  Future<String?> loadMoreRouteStudents(int routeId) async {
    if (!hasMoreRouteStudents || _isLoadingStudents || _isLoadingMoreStudents) {
      return null;
    }
    return await fetchStudentsByRouteId(
      routeId,
      page: _routeStudentsCurrentPage + 1,
    );
  }
}
