import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:school_bus_tracker/core/network/google_map_api.dart';
import 'package:school_bus_tracker/features/tracking/data/models/stop_model.dart';

class DirectionsProvider extends ChangeNotifier {
  List<LatLng> routePoints = [];

  Future<List<LatLng>> fetchRoute({
    required LatLng from,
    required LatLng to,
  }) async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${from.latitude},${from.longitude}'
        '&destination=${to.latitude},${to.longitude}'
        '&mode=driving'
        '&key=${GoogleMapApi.url}';

    final res = await http.get(Uri.parse(url));
    final data = jsonDecode(res.body);

    if (data['routes'].isEmpty) return [];

    final polyline = data['routes'][0]['overview_polyline']['points'];

    return _decodePolyline(polyline);
  }

  List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> points = [];
    int index = 0, lat = 0, lng = 0;

    while (index < encoded.length) {
      int shift = 0, result = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  String buildGoogleMapsUrl(StopModel stop) {
    return 'https://www.google.com/maps/dir/?api=1'
        '&destination=${stop.latitude},${stop.longitude}'
        '&travelmode=driving';
  }
}
