import 'package:geolocator/geolocator.dart';

class MapServices {
  /// Check & request permissions
  Future<void> ensurePermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied');
    }
  }

  /// Get current location
  Future<Position> getCurrentPosition() async {
    return await Geolocator.getCurrentPosition();
  }
}
