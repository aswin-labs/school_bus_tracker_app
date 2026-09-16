import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

enum LocationPermissionStatus {
  granted,
  denied,
  deniedForever,
  serviceDisabled,
}

class LocationException implements Exception {
  final String message;
  final LocationPermissionStatus? status;

  const LocationException(this.message, [this.status]);

  @override
  String toString() => message;
}

class LocationHelper {
  LocationHelper._();

  /// Ensures that location services are enabled and permissions are granted.
  /// On Web, this triggers the browser's permission prompt if permission is 'prompt' / 'denied'.
  static Future<LocationPermissionStatus> ensurePermission() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationPermissionStatus.serviceDisabled;
      }
    } catch (e) {
      log('Error checking location service: $e');
    }

    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationPermissionStatus.deniedForever;
      }

      if (permission == LocationPermission.denied) {
        return LocationPermissionStatus.denied;
      }

      return LocationPermissionStatus.granted;
    } catch (e) {
      log('Error requesting location permission: $e');
      return LocationPermissionStatus.denied;
    }
  }

  /// Returns user-facing error message based on permission status.
  static String getPermissionErrorMessage(LocationPermissionStatus status) {
    switch (status) {
      case LocationPermissionStatus.serviceDisabled:
        return 'Location services are turned off. Please enable location on your device.';
      case LocationPermissionStatus.deniedForever:
        return kIsWeb
            ? 'Location access is blocked in your browser settings. Please allow location access from the address bar icon and reload.'
            : 'Location permission is permanently denied. Please enable it in app settings.';
      case LocationPermissionStatus.denied:
        return 'Location permission was denied. Please allow location access to continue.';
      case LocationPermissionStatus.granted:
        return '';
    }
  }

  /// Retrieves the current position with appropriate platform settings and fallbacks.
  /// On Web: tries high accuracy first; if that fails or times out (common on desktop web),
  /// automatically falls back to low/network accuracy.
  static Future<Position> getCurrentPosition() async {
    final status = await ensurePermission();
    if (status != LocationPermissionStatus.granted) {
      throw LocationException(getPermissionErrorMessage(status), status);
    }

    if (kIsWeb) {
      // 1. High accuracy attempt on web
      try {
        return await Geolocator.getCurrentPosition(
          locationSettings: WebSettings(
            accuracy: LocationAccuracy.high,
            maximumAge: const Duration(seconds: 5),
          ),
        ).timeout(const Duration(seconds: 8));
      } catch (e) {
        log('Web high accuracy location failed ($e), attempting network/low accuracy fallback...');
      }

      // 2. Low accuracy fallback (IP/Wi-Fi geolocation)
      try {
        return await Geolocator.getCurrentPosition(
          locationSettings: WebSettings(
            accuracy: LocationAccuracy.low,
            maximumAge: const Duration(minutes: 1),
          ),
        ).timeout(const Duration(seconds: 8));
      } catch (e) {
        log('Web fallback location failed: $e');
        throw LocationException(
          'Unable to determine your current location. Please verify your internet and browser location settings.',
          status,
        );
      }
    } else {
      // Mobile platforms
      try {
        return await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 10),
          ),
        );
      } catch (e) {
        log('Mobile high accuracy location failed ($e), falling back to medium...');
        try {
          return await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium,
              timeLimit: Duration(seconds: 10),
            ),
          );
        } catch (e2) {
          log('Mobile medium accuracy location failed: $e2');
          throw LocationException(
            'Unable to determine location. Please ensure GPS is active.',
            status,
          );
        }
      }
    }
  }
}
