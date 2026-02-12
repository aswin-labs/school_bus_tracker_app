import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:school_bus_tracker/features/tracking/data/models/stop_model.dart';
import 'package:school_bus_tracker/features/tracking/data/services/stop_services.dart';

class StopManagementProvider extends ChangeNotifier {
  // ───────── STATE ─────────
  List<StopModel> _stops = [];
  List<StopModel> get stops => _stops;
  int currentIndex = 0;

  StopModel? singleStop;

  LatLng? selectedLocation;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  // ───────── GETTERS ─────────
  StopModel? get nextStop =>
      currentIndex < stops.length ? stops[currentIndex] : null;

  bool get hasNextStop => nextStop != null;

  // ───────── FETCH STOPS ─────────
  Future<void> fetchStops(int routeId) async {
    _isLoading = true;
    // notifyListeners();

    try {
      final response = await StopServices().fetchStops(routeId: routeId);
      if (response.statusCode == 200) {
        log("success");
        log(response.data.toString());
        final List<dynamic> dataList = response.data['data'] ?? [];

        _stops = dataList.map((e) => StopModel.fromJson(e)).toList()
          ..sort((a, b) => (a.priority ?? 0).compareTo(b.priority ?? 0));

        currentIndex = 0;
        log(_stops.toString());
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // fetch single stop
  Future<void> fetchSingleStop(int stopId) async {
    singleStop = null; // reset old data
    _isLoading = true;
    notifyListeners();

    try {
      final response = await StopServices().fetchSingleStop(stopId: stopId);
      if (response.statusCode == 200) {
        log("success");
        log(response.data.toString());
        singleStop = StopModel.fromJson(response.data['data']);
        log(singleStop.toString());
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ───────── ADD STOP ─────────
  void setSelectedLocation(LatLng location) {
    selectedLocation = location;
    notifyListeners();
  }

  void useCurrentLocation(LatLng location) {
    selectedLocation = location;
    notifyListeners();
  }

  Future<String?> addStop({
    required String stopName,
    required int priority,
    required int routeId,
  }) async {
    if (_isLoading) return null;
    if (selectedLocation == null) {
      return "Location not selected";
    }

    _setLoading(true);

    try {
      final response = await StopServices().sendStop(
        stop: StopModel(
          routeId: routeId,
          latitude: selectedLocation!.latitude,
          longitude: selectedLocation!.longitude,
          stopName: stopName,
          priority: priority,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return null; // success
      }

      final errorMsg =
          response.data['message'] ??
          "Failed to add stop (status ${response.statusCode})";
      return errorMsg;
    } catch (e) {
      log("Add stop error: $e");
      return "Something went wrong. Please try again.";
    } finally {
      _setLoading(false);
    }
  }

  // ───────── STOP PROGRESSION ─────────
  void completeCurrentStop() {
    if (currentIndex < stops.length - 1) {
      currentIndex++;
      notifyListeners();
    }
  }

  // ───────── RESET (OPTIONAL) ─────────
  void reset() {
    stops.clear();
    currentIndex = 0;
    selectedLocation = null;
    notifyListeners();
  }

  void clearSelectedLocation() {
    selectedLocation = null;
    notifyListeners();
  }
}
