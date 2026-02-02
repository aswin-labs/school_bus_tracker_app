import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LiveLocationProvider extends ChangeNotifier {
  LatLng? currentLocation;
  final List<LatLng> path = [];
  StreamSubscription<Position>? _stream;
  bool trackingStarted = false;

  Future<void> fetchInitialLocation() async {
    final pos = await Geolocator.getCurrentPosition();
    currentLocation = LatLng(pos.latitude, pos.longitude);
    notifyListeners();
  }

  void startTracking() {
    if (trackingStarted) return;
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
}
