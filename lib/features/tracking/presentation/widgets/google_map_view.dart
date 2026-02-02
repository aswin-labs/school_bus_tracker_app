import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:school_bus_tracker/features/tracking/presentation/provider/map_rendering_provider.dart';
import 'package:school_bus_tracker/features/tracking/presentation/provider/stop_management_provider.dart';

class GoogleMapView extends StatefulWidget {
  const GoogleMapView({super.key});

  @override
  State<GoogleMapView> createState() => _GoogleMapViewState();
}

class _GoogleMapViewState extends State<GoogleMapView> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final stopProvider = context.read<StopManagementProvider>();
    final map = context.read<MapRenderingProvider>();

    map.updateStops(stopProvider.stops);
  }

  @override
  Widget build(BuildContext context) {
    final map = context.watch<MapRenderingProvider>();

    return GoogleMap(
      initialCameraPosition: const CameraPosition(
        target: LatLng(11.2588, 75.7804),
        zoom: 16,
      ),
      markers: map.markers,
      polylines: map.polylines,
      onMapCreated: map.init,
    );
  }
}
