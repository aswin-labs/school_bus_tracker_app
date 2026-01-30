import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:school_bus_tracker/features/tracking/presentation/provider/tracking_provider.dart';

class GoogleMapView extends StatelessWidget {
  final TrackingProvider provider;

  const GoogleMapView({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: provider.initialPosition,
      markers: provider.markers,
      polylines: provider.polylines,
      onMapCreated: provider.onMapCreated,
      myLocationEnabled: true,
    );
  }
}
