import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      isFetchingLocation = false;
      notifyListeners();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      isFetchingLocation = false;
      notifyListeners();
      return;
    }

    final pos = await Geolocator.getCurrentPosition();

    currentLocation = LatLng(pos.latitude, pos.longitude);

    isFetchingLocation = false;
    notifyListeners();
  }

  Future<void> startTracking() async {
    if (trackingStarted) return;

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    trackingStarted = true;

    _stream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5,
          ),
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
