import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:school_bus_tracker/core/utils/location_helper.dart';

class LiveLocationProvider extends ChangeNotifier {
  LatLng? currentLocation;
  final List<LatLng> path = [];
  StreamSubscription<Position>? _stream;
  bool trackingStarted = false;
  bool isFetchingLocation = false;

  Future<void> fetchInitialLocation() async {
    if (isFetchingLocation) return;

    isFetchingLocation = true;
    notifyListeners();

    try {
      final pos = await LocationHelper.getCurrentPosition();
      currentLocation = LatLng(pos.latitude, pos.longitude);
    } catch (e) {
      debugPrint("Location fetch error: $e");
    } finally {
      isFetchingLocation = false;
      notifyListeners();
    }
  }

  Future<void> startTracking() async {
    if (trackingStarted) return;

    final status = await LocationHelper.ensurePermission();
    if (status != LocationPermissionStatus.granted) {
      return;
    }

    trackingStarted = true;

    final locationSettings = kIsWeb
        ? WebSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5,
          )
        : const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5,
          );

    _stream =
        Geolocator.getPositionStream(
          locationSettings: locationSettings,
        ).listen((pos) {
          final point = LatLng(pos.latitude, pos.longitude);
          currentLocation = point;
          path.add(point);
          notifyListeners();
        });
  }

  void stopTracking() {
    _stream?.cancel();
    _stream = null;
    trackingStarted = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _stream?.cancel();
    super.dispose();
  }

  void clearCurrentLocation() {
    currentLocation = null;
    notifyListeners();
  }
}
