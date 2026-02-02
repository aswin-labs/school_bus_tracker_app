import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:school_bus_tracker/features/tracking/data/models/stop_model.dart';
import 'package:school_bus_tracker/features/tracking/data/services/stop_services.dart';

class StopManagementProvider extends ChangeNotifier {
  // ───────── STATE ─────────
  List<StopModel> stops = [];
  int currentIndex = 0;

  LatLng? selectedLocation;
  bool isLoading = false;

  // ───────── GETTERS ─────────
  StopModel? get nextStop =>
      currentIndex < stops.length ? stops[currentIndex] : null;

  bool get hasNextStop => nextStop != null;

  // ───────── FETCH STOPS ─────────
  Future<void> fetchStops(int routeId) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await StopServices().fetchStops(routeId: routeId);

      stops = (response.data['stops'] as List)
          .map((e) => StopModel.fromJson(e))
          .toList()
        ..sort((a, b) =>
            (a.priority ?? 0).compareTo(b.priority ?? 0));

      currentIndex = 0;
    } finally {
      isLoading = false;
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

  Future<void> addStop({
    required String stopName,
    required int priority,
    required int routeId,
  }) async {
    if (selectedLocation == null) return;

    isLoading = true;
    notifyListeners();

    try {
      await StopServices().sendStop(
        stop: StopModel(
          routeId: routeId,
          latitude: selectedLocation!.latitude,
          longitude: selectedLocation!.longitude,
          stopName: stopName,
          priority: priority,
        ),
      );
    } finally {
      isLoading = false;
      notifyListeners();
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
}
