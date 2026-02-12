import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:school_bus_tracker/features/dummy/provider/sample_live_location_provider.dart';
import 'package:school_bus_tracker/features/dummy/provider/sample_map_rendering_provider.dart';
import 'package:school_bus_tracker/features/dummy/provider/sample_stop_management_provider.dart';
import 'package:school_bus_tracker/features/tracking/data/models/stop_model.dart';

class SampleGoogleMapView extends StatefulWidget {
  const SampleGoogleMapView({super.key});

  @override
  State<SampleGoogleMapView> createState() => _SampleGoogleMapViewState();
}

class _SampleGoogleMapViewState extends State<SampleGoogleMapView> {
  List<StopModel>? _lastStops;
  LatLng? _lastLocation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final map = context.read<SampleMapRenderingProvider>();
    final stopsProvider = context.watch<SampleStopManagementProvider>();
    final liveProvider = context.watch<SampleLiveLocationProvider>();

    // ✅ Update stops only when changed
    if (_lastStops != stopsProvider.stops) {
      _lastStops = stopsProvider.stops;
      map.updateStops(stopsProvider.stops);
    }

    // ✅ Update bus only when location changes
    if (_lastLocation != liveProvider.currentLocation &&
        liveProvider.currentLocation != null) {
      _lastLocation = liveProvider.currentLocation;
      map.updateBus(liveProvider.currentLocation!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final map = context.watch<SampleMapRenderingProvider>();

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
