import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SampleLiveLocationProvider extends ChangeNotifier {
  LatLng? currentLocation;
  final List<LatLng> path = [];
  Timer? _timer;
  bool trackingStarted = false;

  // Dummy route
  final List<LatLng> _dummyPoints = [
    // const LatLng(9.931233, 76.267303),
    // const LatLng(9.932000, 76.268000),
    // const LatLng(9.933000, 76.269000),
    // const LatLng(9.934000, 76.270000),
    // const LatLng(9.935000, 76.271000),
  ];

  int _index = 0;

  Future<void> fetchInitialLocation() async {
    currentLocation = _dummyPoints.first;
    notifyListeners();
  }

  void startTracking() {
    if (trackingStarted) return;
    trackingStarted = true;

    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (_index >= _dummyPoints.length) return;

      final point = _dummyPoints[_index];
      currentLocation = point;
      path.add(point);
      _index++;

      notifyListeners();
    });
  }

  void stopTracking() {
    _timer?.cancel();
    _timer = null;
    trackingStarted = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
