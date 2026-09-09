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
    notifyListeners();
  }

  Future<String?> fetchStudentsByRouteId(int routeId) async {
    _isLoadingStudents = true;
    _routeStudents = [];
    notifyListeners();

    try {
      final response = await _routeServices.fetchStudentsByRouteId(routeId);

      log('Fetch route students response: ${response.data}');

      if (response.statusCode != 200) {
        return ApiErrorUtils.getErrorMessage(
          data: response.data,
          defaultMessage: 'Failed to fetch students',
          statusCode: response.statusCode,
        );
      }

      final rawData = response.data['data'] ?? response.data['students'] ?? response.data;

      if (rawData is! List) {
        _routeStudents = [];
        notifyListeners();
        return null;
      }

      _routeStudents = rawData
          .map<StudentModel>((json) => StudentModel.fromJson(json))
          .toList();

      notifyListeners();

      log('Fetched route students: ${_routeStudents.length}');

      return null;
    } catch (e, stackTrace) {
      log('Fetch route students error: $e', stackTrace: stackTrace);

      return ApiErrorUtils.getExceptionErrorMessage(e);
    } finally {
      _isLoadingStudents = false;
      notifyListeners();
    }
  }
}
