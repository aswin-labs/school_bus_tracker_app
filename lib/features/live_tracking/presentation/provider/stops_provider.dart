import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:school_bus_tracker/core/utils/api_error_utils.dart';
import 'package:school_bus_tracker/features/home/data/models/route_model.dart';
import 'package:school_bus_tracker/features/live_tracking/data/models/stop_model.dart';
import 'package:school_bus_tracker/features/live_tracking/data/models/student_model.dart';
import 'package:school_bus_tracker/features/live_tracking/data/services/stops_services.dart';

class StopsProvider extends ChangeNotifier {
  final StopServices _stopServices;

  StopsProvider(this._stopServices);

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isDetailsLoading = false;
  bool get isDetailsLoading => _isDetailsLoading;

  bool _isRearranging = false;
  bool get isRearranging => _isRearranging;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  bool _isCreatingStop = false;
  bool get isCreatingStop => _isCreatingStop;

  bool _isUpdatingStop = false;
  bool get isUpdatingStop => _isUpdatingStop;

  bool _isDeletingStop = false;
  bool get isDeletingStop => _isDeletingStop;

  int? _deletingStopId;
  int? get deletingStopId => _deletingStopId;

  LatLng? _selectedLocation;
  LatLng? get selectedLocation => _selectedLocation;

  List<StopModel> _stops = [];
  List<StopModel> get stops => _stops;

  List<StopModel> _unassignedPairStops = [];
  List<StopModel> get unassignedPairStops => _unassignedPairStops;

  bool _isLoadingPairStops = false;
  bool get isLoadingPairStops => _isLoadingPairStops;

  bool _isAssigningPairStops = false;
  bool get isAssigningPairStops => _isAssigningPairStops;

  RouteModel? _route;
  RouteModel? get route => _route;

  int? _currentRouteId;
  int? get currentRouteId => _currentRouteId;

  StopModel? _singleStop;
  StopModel? get singleStop => _singleStop;

  List<StudentModel> _students = [];
  List<StudentModel> get students => _students;

  final Set<int> _selectedStudentIds = {};
  Set<int> get selectedStudentIds => _selectedStudentIds;

  Timer? _locationTimer;
  bool _isSharingLocation = false;
  bool get isSharingLocation => _isSharingLocation;

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  /// Next Stop: First stop in priority order where LiveLocations is empty/null
  StopModel? get nextStop {
    try {
      return _stops.firstWhere(
        (stop) =>
            stop.stopLiveStatuses == null || stop.stopLiveStatuses!.isEmpty,
      );
    } catch (_) {
      return null;
    }
  }

  bool get hasNextStop => nextStop != null;

  /// Upcoming Stops: All stops not yet reached (LiveLocations is empty)
  List<StopModel> get upcomingStops => _stops
      .where(
        (stop) =>
            stop.stopLiveStatuses == null || stop.stopLiveStatuses!.isEmpty,
      )
      .toList();

  /// Completed Stops: All stops already arrived (LiveLocations is not empty)
  List<StopModel> get completedStops => _stops
      .where(
        (stop) =>
            stop.stopLiveStatuses != null && stop.stopLiveStatuses!.isNotEmpty,
      )
      .toList();

  bool get isPickup => _route?.type == 'PICKUP';

  // ---------------------------------------------------------------------------
  // Loading helpers
  // ---------------------------------------------------------------------------

  void _setLoading(bool value) {
    if (_isLoading == value) return;

    _isLoading = value;
    notifyListeners();
  }

  void _setDetailsLoading(bool value) {
    if (_isDetailsLoading == value) return;

    _isDetailsLoading = value;
    notifyListeners();
  }

  void _setRearranging(bool value) {
    if (_isRearranging == value) return;

    _isRearranging = value;
    notifyListeners();
  }

  void _setCreatingStop(bool value) {
    if (_isCreatingStop == value) return;

    _isCreatingStop = value;
    notifyListeners();
  }

  void _setUpdatingStop(bool value) {
    if (_isUpdatingStop == value) return;

    _isUpdatingStop = value;
    notifyListeners();
  }

  void _setLoadingPairStops(bool value) {
    if (_isLoadingPairStops == value) return;

    _isLoadingPairStops = value;
    notifyListeners();
  }

  void _setAssigningPairStops(bool value) {
    if (_isAssigningPairStops == value) return;

    _isAssigningPairStops = value;
    notifyListeners();
  }

  void _setDeletingStop(bool value, [int? stopId]) {
    _isDeletingStop = value;
    _deletingStopId = value ? stopId : null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Location Management
  // ---------------------------------------------------------------------------

  void setSelectedLocation(LatLng location) {
    _selectedLocation = location;
    notifyListeners();
  }

  void useCurrentLocation(LatLng location) {
    _selectedLocation = location;
    notifyListeners();
  }

  void clearSelectedLocation() {
    _selectedLocation = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Student Selection
  // ---------------------------------------------------------------------------

  void toggleStudentSelection(int studentId) {
    if (_selectedStudentIds.contains(studentId)) {
      _selectedStudentIds.remove(studentId);
    } else {
      _selectedStudentIds.add(studentId);
    }
    notifyListeners();
  }

  void selectAllStudents(List<int> studentIds) {
    _selectedStudentIds.addAll(studentIds);
    notifyListeners();
  }

  void clearSelection() {
    _selectedStudentIds.clear();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Fetch stops
  // ---------------------------------------------------------------------------

  Future<String?> fetchStopsByRouteId(int routeId) async {
    _currentRouteId = routeId;
    _setLoading(true);

    try {
      final response = await _stopServices.fetchStops(routeId: routeId);

      log('Fetch driver stops response: ${response.data}');

      if (response.statusCode != 200) {
        return ApiErrorUtils.getErrorMessage(
          data: response.data,
          defaultMessage: 'Failed to fetch stops',
          statusCode: response.statusCode,
        );
      }

      final data = response.data['data'];

      if (data is! List) {
        _stops = [];
        notifyListeners();
        return 'No stops found';
      }

      if (response.data['route'] != null) {
        _route = RouteModel.fromJson(response.data['route']);
      }

      // sort stops based on priority
      _stops = data.map<StopModel>((json) => StopModel.fromJson(json)).toList()
        ..sort(
          (a, b) =>
              (a.stopPriority?.isNotEmpty == true
                      ? a.stopPriority!.first.priority ?? 0
                      : a.priority ?? 0)
                  .compareTo(
                    b.stopPriority?.isNotEmpty == true
                        ? b.stopPriority!.first.priority ?? 0
                        : b.priority ?? 0,
                  ),
        );
      notifyListeners();
      log('Fetched stops: ${_stops.length}');

      return null;
    } catch (e, stackTrace) {
      log('Fetch driver stops error: $e', stackTrace: stackTrace);

      return ApiErrorUtils.getExceptionErrorMessage(e);
    } finally {
      _setLoading(false);
    }
  }

  // ---------------------------------------------------------------------------
  // Fetch single stop
  // ---------------------------------------------------------------------------

  void clearSingleStop() {
    _singleStop = null;
    _students = [];
    notifyListeners();
  }

  Future<String?> fetchSingleStop({
    required int stopId,
    required int routeId,
  }) async {
    _singleStop = null;
    _students = [];
    _setDetailsLoading(true);

    try {
      final response = await _stopServices.fetchSingleStop(
        stopId: stopId,
        routeId: routeId,
      );

      log('Fetch single stop response: ${response.data}');

      if (response.statusCode != 200) {
        return ApiErrorUtils.getErrorMessage(
          data: response.data,
          defaultMessage: 'Failed to fetch stop details',
          statusCode: response.statusCode,
        );
      }

      final data = response.data['data'];

      if (data is! Map<String, dynamic>) {
        _students = [];
        notifyListeners();
        return 'No stop details found';
      }

      _singleStop = StopModel.fromJson(data);

      final students = data['students'];

      if (students is List) {
        _students = students
            .map<StudentModel>((json) => StudentModel.fromJson(json))
            .toList();
      } else {
        _students = [];
      }

      notifyListeners();

      log('Fetched single stop: ${_singleStop?.stopName}');

      return null;
    } catch (e, stackTrace) {
      log('Fetch single stop error: $e', stackTrace: stackTrace);

      return ApiErrorUtils.getExceptionErrorMessage(e);
    } finally {
      _setDetailsLoading(false);
    }
  }

  // ---------------------------------------------------------------------------
  // Create Stop
  // ---------------------------------------------------------------------------

  Future<String?> createStop({
    required String stopName,
    required int priority,
    required int routeId,
    required bool isEnabled,
  }) async {
    if (_isCreatingStop) return null;

    if (_selectedLocation == null) {
      return 'Location not selected';
    }

    _setCreatingStop(true);

    try {
      final response = await _stopServices.createStop(
        routeId: routeId,
        stopName: stopName,
        priority: priority,
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
        both: isEnabled,
      );

      log('Create stop response: ${response.data}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        return ApiErrorUtils.getErrorMessage(
          data: response.data,
          defaultMessage: 'Failed to add stop',
          statusCode: response.statusCode,
        );
      }

      _selectedLocation = null;
      await fetchStopsByRouteId(routeId);

      log('Stop created successfully');

      return null;
    } catch (e, stackTrace) {
      log('Create stop error: $e', stackTrace: stackTrace);

      return ApiErrorUtils.getExceptionErrorMessage(e);
    } finally {
      _setCreatingStop(false);
    }
  }

  // ---------------------------------------------------------------------------
  // Update Stop
  // ---------------------------------------------------------------------------

  Future<String?> updateStop({
    required int stopId,
    required String stopName,
    required double latitude,
    required double longitude,
    required int routeId,
  }) async {
    if (_isUpdatingStop) return null;

    _setUpdatingStop(true);

    try {
      final response = await _stopServices.updateStop(
        stopId: stopId,
        stopName: stopName,
        latitude: latitude,
        longitude: longitude,
      );

      log('Update stop response: ${response.data}');

      if (response.statusCode != 200) {
        return ApiErrorUtils.getErrorMessage(
          data: response.data,
          defaultMessage: 'Failed to update stop',
          statusCode: response.statusCode,
        );
      }

      await fetchSingleStop(stopId: stopId, routeId: routeId);
      await fetchStopsByRouteId(routeId);

      log('Stop updated successfully');

      return null;
    } catch (e, stackTrace) {
      log('Update stop error: $e', stackTrace: stackTrace);

      return ApiErrorUtils.getExceptionErrorMessage(e);
    } finally {
      _setUpdatingStop(false);
    }
  }

  // ---------------------------------------------------------------------------
  // Delete Stop
  // ---------------------------------------------------------------------------

  Future<String?> deleteStop({
    required int stopId,
    required int routeId,
  }) async {
    if (_isDeletingStop) return null;

    _setDeletingStop(true, stopId);

    try {
      final response = await _stopServices.deleteStop(stopId: stopId);

      log('Delete stop response: ${response.data}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        return ApiErrorUtils.getErrorMessage(
          data: response.data,
          defaultMessage: 'Failed to delete stop',
          statusCode: response.statusCode,
        );
      }

      await fetchStopsByRouteId(routeId);
      fetchUnassignedStopsInPairRoute(routeId);

      log('Stop deleted successfully');

      return null;
    } catch (e, stackTrace) {
      log('Delete stop error: $e', stackTrace: stackTrace);

      return ApiErrorUtils.getExceptionErrorMessage(e);
    } finally {
      _setDeletingStop(false);
    }
  }

  // ---------------------------------------------------------------------------
  // Rearrange stop priorities
  // ---------------------------------------------------------------------------

  Future<String?> rearrangeStopPriorities({
    required int routeId,
    required List<Map<String, int>> stopPriorities,
  }) async {
    _setRearranging(true);

    try {
      final response = await _stopServices.rearrangeStopPriorities(
        routeId: routeId,
        stopPriorities: stopPriorities,
      );

      log('Rearrange stops response: ${response.data}');

      if (response.statusCode != 200) {
        return ApiErrorUtils.getErrorMessage(
          data: response.data,
          defaultMessage: 'Failed to rearrange stops',
          statusCode: response.statusCode,
        );
      }

      notifyListeners();

      log('Stop priorities updated successfully');

      return null;
    } catch (e, stackTrace) {
      log('Rearrange stop priorities error: $e', stackTrace: stackTrace);

      return ApiErrorUtils.getExceptionErrorMessage(e);
    } finally {
      _setRearranging(false);
    }
  }

  // ---------------------------------------------------------------------------
  // Fetch unassigned stops in pair route
  // ---------------------------------------------------------------------------

  Future<String?> fetchUnassignedStopsInPairRoute(int routeId) async {
    _setLoadingPairStops(true);

    try {
      final response = await _stopServices.fetchUnassignedStopsInPairRoute(
        routeId: routeId,
      );

      log('Fetch unassigned pair stops response: ${response.data}');

      if (response.statusCode != 200) {
        _unassignedPairStops = [];
        notifyListeners();
        return ApiErrorUtils.getErrorMessage(
          data: response.data,
          defaultMessage: 'Failed to fetch unassigned pair stops',
          statusCode: response.statusCode,
        );
      }

      final data = response.data['data'];

      if (data is! List) {
        _unassignedPairStops = [];
        notifyListeners();
        return null;
      }

      _unassignedPairStops = data
          .map<StopModel>((json) => StopModel.fromJson(json))
          .toList();

      notifyListeners();
      log('Fetched unassigned pair stops: ${_unassignedPairStops.length}');

      return null;
    } catch (e, stackTrace) {
      log('Fetch unassigned pair stops error: $e', stackTrace: stackTrace);
      _unassignedPairStops = [];
      notifyListeners();
      return ApiErrorUtils.getExceptionErrorMessage(e);
    } finally {
      _setLoadingPairStops(false);
    }
  }

  // ---------------------------------------------------------------------------
  // Assign stop IDs from pair route
  // ---------------------------------------------------------------------------

  Future<String?> assignStopsFromPairRoute({
    required int routeId,
    required List<Map<String, dynamic>> stops,
  }) async {
    _setAssigningPairStops(true);

    try {
      final response = await _stopServices.assignStopIdsFromPairRoute(
        routeId: routeId,
        stops: stops,
      );

      log('Assign pair stops response: ${response.data}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        return ApiErrorUtils.getErrorMessage(
          data: response.data,
          defaultMessage: 'Failed to assign stops from pair route',
          statusCode: response.statusCode,
        );
      }

      // Re-fetch route stops and unassigned pair stops
      await fetchStopsByRouteId(routeId);
      await fetchUnassignedStopsInPairRoute(routeId);

      log('Pair stops assigned successfully');

      return null;
    } catch (e, stackTrace) {
      log('Assign pair stops error: $e', stackTrace: stackTrace);

      return ApiErrorUtils.getExceptionErrorMessage(e);
    } finally {
      _setAssigningPairStops(false);
    }
  }

  // ---------------------------------------------------------------------------
  // Update Stop and Student (Mark Attendance / Arrived)
  // ---------------------------------------------------------------------------

  Future<bool> updateStopAndStudent({required int stopId}) async {
    if (_selectedStudentIds.isEmpty) return false;

    _isSubmitting = true;
    notifyListeners();

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final response = await _stopServices.updateStopAndStudent(
        stopId: stopId,
        studentIds: _selectedStudentIds.toList(),
        latitude: position.latitude,
        longitude: position.longitude,
        routeId: _currentRouteId!,
      );

      log('Update stop and student response: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        _selectedStudentIds.clear();

        if (_currentRouteId != null) {
          await fetchStopsByRouteId(_currentRouteId!);
        }

        return true;
      }

      return false;
    } catch (e, stackTrace) {
      log('Update stop and student error: $e', stackTrace: stackTrace);
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Live Location Sharing
  // ---------------------------------------------------------------------------

  Future<void> startLiveLocationSharing(int routeId) async {
    if (_isSharingLocation) return;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      log("Location services are disabled.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      log("Location permissions are denied.");
      return;
    }

    _locationTimer?.cancel();
    _locationTimer = null;
    _isSharingLocation = true;
    notifyListeners();

    // Send immediately
    await _sendLiveLocation(routeId);

    if (!_isSharingLocation) return;

    // Periodic every 20s
    _locationTimer = Timer.periodic(
      const Duration(seconds: 20),
      (_) => _sendLiveLocation(routeId),
    );
  }

  Future<void> _sendLiveLocation(int routeId) async {
    if (!_isSharingLocation) return;

    try {
      late LocationSettings locationSettings;
      if (kIsWeb) {
        locationSettings = WebSettings(
          accuracy: LocationAccuracy.high,
          maximumAge: const Duration(seconds: 5),
        );
      } else {
        locationSettings = const LocationSettings(
          accuracy: LocationAccuracy.high,
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      if (!_isSharingLocation) return;

      final response = await _stopServices.updateLiveLocation(
        routeId: routeId,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (response.statusCode == 200) {
        log("Live location sent: ${position.latitude}, ${position.longitude}");
      } else if (response.statusCode == 404 || response.statusCode == 400) {
        log(
          "Route is inactive or not found (Status ${response.statusCode}). Stopping location sharing.",
        );
        stopLiveLocationSharing();
      }
    } catch (e) {
      log("Live Location Error: $e");
    }
  }

  void stopLiveLocationSharing() {
    _locationTimer?.cancel();
    _locationTimer = null;
    if (_isSharingLocation) {
      _isSharingLocation = false;
      notifyListeners();
    }
    log("Live location sharing stopped");
  }

  // ---------------------------------------------------------------------------
  // Reset
  // ---------------------------------------------------------------------------

  void reset() {
    _stops.clear();
    _unassignedPairStops.clear();
    _route = null;
    _singleStop = null;
    _students.clear();
    _selectedStudentIds.clear();
    _selectedLocation = null;
    _currentRouteId = null;
    stopLiveLocationSharing();
    notifyListeners();
  }
}
