import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:school_bus_tracker/features/tracking/data/models/stop_model.dart';

class SampleMapRenderingProvider extends ChangeNotifier {
  GoogleMapController? controller;
  BitmapDescriptor? busIcon;

  final Set<Marker> markers = {};
  final Set<Polyline> polylines = {};

  Future<void> init(GoogleMapController c) async {
    controller = c;
    busIcon ??= await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48), devicePixelRatio: 3),
      'assets/icons/bus.png',
    );
  }

  void updateBus(LatLng position) {
    markers.removeWhere((m) => m.markerId.value == 'bus');
    markers.add(
      Marker(
        markerId: const MarkerId('bus'),
        position: position,
        icon: busIcon!,
        anchor: const Offset(0.5, 0.5),
        flat: true,
      ),
    );
    notifyListeners();
  }

  void updateStops(List<StopModel> stops) {
    markers.removeWhere((m) => m.markerId.value.startsWith('stop_'));

    for (final s in stops) {
      markers.add(
        Marker(
          markerId: MarkerId('stop_${s.priority}'),
          position: LatLng(s.latitude, s.longitude),
          infoWindow: InfoWindow(title: s.stopName),
        ),
      );
    }
    notifyListeners();
  }

  void updatePolyline(List<LatLng> points) {
    polylines
      ..clear()
      ..add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: points,
          width: 6,
          color: Colors.blue,
        ),
      );
    notifyListeners();
  }

  void moveTo(LatLng position, {double zoom = 17}) {
    controller?.animateCamera(CameraUpdate.newLatLngZoom(position, zoom));
  }
}
