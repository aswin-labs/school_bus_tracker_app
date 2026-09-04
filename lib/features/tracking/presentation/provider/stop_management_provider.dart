import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:school_bus_tracker/features/driver_routes/data/models/route_model.dart';
import 'package:school_bus_tracker/features/driver_routes/presentation/provider/route_provider.dart';
import 'package:school_bus_tracker/features/tracking/data/models/stop_model.dart';
import 'package:school_bus_tracker/features/tracking/data/models/student_model.dart';
import 'package:school_bus_tracker/features/tracking/data/services/stop_services.dart';

class StopManagementProvider extends ChangeNotifier {
  /// ───────────────── STATE ─────────────────

  List<StopModel> _stops = [];
  List<StopModel> get stops => _stops;

  int currentIndex = 0;

  StopModel? singleStop;

  List<StudentModel> _students = [];
  List<StudentModel> get students => _students;

  final Set<int> _selectedStudentIds = {};
  Set<int> get selectedStudentIds => _selectedStudentIds;

  int? _currentRouteId;
  int? get currentRouteId => _currentRouteId;

  LatLng? selectedLocation;

  RouteModel? route;

  /// ───────── LOADING STATES ─────────

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingDetails = false;
  bool get isLoadingDetails => _isLoadingDetails;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  bool _isCreatingStop = false;
  bool get isCreatingStop => _isCreatingStop;

  bool _isInactivatingRoute = false;
  bool get isInactivatingRoute => _isInactivatingRoute;

  /// ───────── LOADING SETTERS ─────────

  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  void _setDetailsLoading(bool value) {
    if (_isLoadingDetails != value) {
      _isLoadingDetails = value;
      notifyListeners();
    }
  }

  void _setSubmitting(bool value) {
    if (_isSubmitting != value) {
      _isSubmitting = value;
      notifyListeners();
    }
  }

  void _setCreatingStop(bool value) {
    if (_isCreatingStop != value) {
      _isCreatingStop = value;
      notifyListeners();
    }
  }

  /// ───────── GETTERS ─────────

  StopModel? get nextStop {
    try {
      return _stops.firstWhere(
        (stop) => stop.stopLiveStatuses?.isEmpty == true,
      );
    } catch (_) {
      return null;
    }
  }

  bool get hasNextStop => nextStop != null;

  /// ───────────────── FETCH STOPS ─────────────────

  Future<void> fetchStops(int routeId) async {
    _setLoading(true);
    _currentRouteId = routeId;
    clearStops();
    try {
      final response = await StopServices().fetchStops(routeId: routeId);
      if (response.statusCode == 200) {
        route = RouteModel.fromJson(response.data['route']);
        final List<dynamic> dataList = response.data['data'] ?? [];
        _stops = dataList.map((e) => StopModel.fromJson(e)).toList()
          ..sort((a, b) => (a.priority ?? 0).compareTo(b.priority ?? 0));
        log("live statuses: ${_stops.map((e) => e.stopLiveStatuses)}");
      }
    } catch (e) {
      log("Fetch Stops Error: $e");
    } finally {
      _setLoading(false);
    }
  }

  /// ───────────────── FETCH SINGLE STOP ─────────────────

  Future<void> fetchSingleStop({
    required int stopId,
    required int routeId,
  }) async {
    singleStop = null;
    _setDetailsLoading(true);

    try {
      final response = await StopServices().fetchSingleStop(
        stopId: stopId,
        routeId: routeId,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];

        singleStop = StopModel.fromJson(data);

        _students = (data["students"] as List)
            .map((e) => StudentModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      log("Fetch Single Stop Error: $e");
    } finally {
      _setDetailsLoading(false);
    }
  }

  /// ───────────────── LOCATION MANAGEMENT ─────────────────

  void setSelectedLocation(LatLng location) {
    selectedLocation = location;
    notifyListeners();
  }

  void useCurrentLocation(LatLng location) {
    selectedLocation = location;
    notifyListeners();
  }

  void clearSelectedLocation() {
    selectedLocation = null;
    notifyListeners();
  }

  /// ───────────────── ADD STOP ─────────────────

  Future<String?> addStop({
    required String stopName,
    required int priority,
    required int routeId,
    required bool isEnabled,
  }) async {
    if (_isCreatingStop) return null;

    if (selectedLocation == null) {
      return "Location not selected";
    }

    _setCreatingStop(true);

    try {
      final response = await StopServices().createStop(
        stop: StopModel(
          routeId: routeId,
          latitude: selectedLocation!.latitude,
          longitude: selectedLocation!.longitude,
          stopName: stopName,
          priority: priority,
        ),
        both: isEnabled,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchStops(routeId);
        return null;
      }

      return response.data['message'] ??
          "Failed to add stop (status ${response.statusCode})";
    } catch (e) {
      log("Add Stop Error: $e");
      return "Something went wrong. Please try again.";
    } finally {
      _setCreatingStop(false);
    }
  }

  // Create bulk stops

  List<StopModel> prepareDropStops({
    required List<StopModel> pickupStops,
    required int dropRouteId,
  }) {
    final reversed = pickupStops.reversed.toList();

    return List.generate(reversed.length, (index) {
      final stop = reversed[index];

      return StopModel(
        routeId: dropRouteId,
        stopName: stop.stopName,
        latitude: stop.latitude,
        longitude: stop.longitude,
        priority: index + 1,
      );
    });
  }

  Future<bool> createDropStops({
    required int dropRouteId,
    required int pickupRouteId,
  }) async {
    _setCreatingStop(true);

    try {
      /// 1 fetch pickup stops
      final response = await StopServices().fetchStops(routeId: pickupRouteId);

      if (response.statusCode != 200) return false;

      final List<dynamic> data = response.data['data'] ?? [];

      final pickupStops = data.map((e) => StopModel.fromJson(e)).toList()
        ..sort((a, b) => (a.priority ?? 0).compareTo(b.priority ?? 0));

      /// 2 reverse them
      final dropStops = prepareDropStops(
        pickupStops: pickupStops,
        dropRouteId: dropRouteId,
      );

      /// 3 send bulk API
      final bulkResponse = await StopServices().createBulkStops(
        routeId: dropRouteId,
        stops: dropStops,
      );

      if (bulkResponse.statusCode == 200 || bulkResponse.statusCode == 201) {
        await fetchStops(dropRouteId);
        return true;
      }

      return false;
    } catch (e) {
      log("Bulk Stop Error: $e");
      return false;
    } finally {
      _setCreatingStop(false);
    }
  }

  /// ───────────────── STOP PROGRESSION ─────────────────

  void completeCurrentStop() {
    if (currentIndex < _stops.length - 1) {
      currentIndex++;
      notifyListeners();
    }
  }

  /// ───────────────── STUDENT SELECTION ─────────────────

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

  /// ───────────────── UPDATE STUDENT STATUS ─────────────────

  Future<bool> updateStopAndStudent({
    required int stopId,
    required bool forPicking,
  }) async {
    if (_selectedStudentIds.isEmpty) return false;

    _setSubmitting(true);

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      final response = await StopServices().updateStopAndStudent(
        stopId: stopId,
        studentIds: _selectedStudentIds.toList(),
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (response.statusCode == 200) {
        _selectedStudentIds.clear();

        /// ✅ REFRESH FULL LIST (MAIN FIX)
        if (_currentRouteId != null) {
          await fetchStops(_currentRouteId!);
        }

        return true;
      }

      return false;
    } catch (e) {
      log("Update Stop Error: $e");
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  /// ───────────────── UPDATE ROUTE INACTIVE ─────────────────

  Future<void> updateRouteInActive({
    required int routeId,
    required BuildContext context,
  }) async {
    _isInactivatingRoute = true;
    notifyListeners();
    try {
      final response = await StopServices().updateRouteInActive(
        routeId: routeId,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        reset();
        if (!context.mounted) return;
        await context.read<RouteProvider>().fetchDriverRoutes();
        stopLiveLocationSharing();
        if (!context.mounted) return;
        Navigator.of(context).pop(); // Close the bottom sheet
        // if (context.mounted) {
        //   context.pushNamed(RouterConstants.driverHomeScreen);
        // }

        log("Route Inactivated Successfully");
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isInactivatingRoute = false;
      notifyListeners();
    }
  }

  /// ───────────LIVE LOCATION SHARING ────────
  Timer? _locationTimer;
  bool _isSharingLocation = false;

  Future<void> startLiveLocationSharing(int routeId) async {
    if (_isSharingLocation) return;

    // Check location service & permissions (required for web compatibility)
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

    _isSharingLocation = true;

    // Send location immediately when tracking starts
    await _sendLiveLocation(routeId);

    // Then send location every 20 seconds
    _locationTimer = Timer.periodic(
      const Duration(seconds: 20),
      (_) => _sendLiveLocation(routeId),
    );
  }

  Future<void> _sendLiveLocation(int routeId) async {
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

      final response = await StopServices().updateLiveLocation(
        routeId: routeId,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (response.statusCode == 200) {
        log(
          "Live location sent: "
          "${position.latitude}, ${position.longitude}",
        );
      }
    } catch (e) {
      log("Live Location Error: $e");
    }
  }

  void stopLiveLocationSharing() {
    _locationTimer?.cancel();
    _locationTimer = null;
    _isSharingLocation = false;

    log("Live location sharing stopped");
  }

  /// ───────────────── RESET ─────────────────

  void reset() {
    _stops.clear();
    currentIndex = 0;
    selectedLocation = null;
    _selectedStudentIds.clear();
    notifyListeners();
  }

  // clear stops
  void clearStops() {
    _stops.clear();
    currentIndex = 0;
    notifyListeners();
  }
}
