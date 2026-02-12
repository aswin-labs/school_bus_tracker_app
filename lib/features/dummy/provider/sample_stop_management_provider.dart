import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:school_bus_tracker/features/tracking/data/models/stop_model.dart';

class SampleStopManagementProvider extends ChangeNotifier {
  // ───────── STATE ─────────
  List<StopModel> stops = [];
  int currentIndex = 0;

  LatLng? selectedLocation;
  bool isLoading = false;

  // ───────── GETTERS ─────────
  StopModel? get nextStop =>
      currentIndex < stops.length ? stops[currentIndex] : null;

  bool get hasNextStop => nextStop != null;

  // ───────── FETCH STOPS (DUMMY) ─────────
  Future<void> fetchStops(int routeId) async {
    isLoading = true;
    notifyListeners();

    // Fake delay to simulate API
    await Future.delayed(const Duration(seconds: 1));

    stops = [
      StopModel(
        routeId: routeId,
        stopName: 'School',
        latitude: 11.938718355162813,
        longitude:  75.35380340695816,
        priority: 1,
      ),
      StopModel(
        routeId: routeId,
        stopName: 'Library Junction',
        latitude:11.96145322951482, 
        longitude: 75.35670821834138,
        priority: 2,
      ),
    ];

    currentIndex = 0;
    isLoading = false;
    notifyListeners();
  }

  // ───────── ADD STOP (LOCAL ONLY) ─────────
  void setSelectedLocation(LatLng location) {
    selectedLocation = location;
    notifyListeners();
  }

  void useCurrentLocation(LatLng location) {
    selectedLocation = location;
    notifyListeners();
  }

  Future<void> addStop({
    required String stopName,
    required int priority,
    required int routeId,
  }) async {
    if (selectedLocation == null) return;

    isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    stops.add(
      StopModel(
        routeId: routeId,
        stopName: stopName,
        latitude: selectedLocation!.latitude,
        longitude: selectedLocation!.longitude,
        priority: priority,
      ),
    );

    stops.sort((a, b) => (a.priority ?? 0).compareTo(b.priority ?? 0));

    isLoading = false;
    notifyListeners();
  }

  // ───────── STOP PROGRESSION ─────────
  void completeCurrentStop() {
    if (currentIndex < stops.length - 1) {
      currentIndex++;
      notifyListeners();
    }
  }

  // ───────── RESET ─────────
  void reset() {
    stops.clear();
    currentIndex = 0;
    selectedLocation = null;
    notifyListeners();
  }
}
