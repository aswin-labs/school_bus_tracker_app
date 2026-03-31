import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:school_bus_tracker/features/tracking/presentation/provider/live_location_provider.dart';
import 'package:school_bus_tracker/features/tracking/presentation/provider/stop_management_provider.dart';

class SelectLocationMapScreen extends StatefulWidget {
  const SelectLocationMapScreen({super.key});

  @override
  State<SelectLocationMapScreen> createState() =>
      _SelectLocationMapScreenState();
}

class _SelectLocationMapScreenState extends State<SelectLocationMapScreen> {
  GoogleMapController? mapController;

  bool _listenerAttached = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_listenerAttached) return;
    _listenerAttached = true;

    final live = context.read<LiveLocationProvider>();
    final stop = context.read<StopManagementProvider>();

    live.addListener(() async {
      final loc = live.currentLocation;
      log("Location received: $loc");
      if (loc == null) return;

      // Set selected location once
      if (stop.selectedLocation == null) {
        stop.setSelectedLocation(loc);
      }

      // Move camera
      if (mapController != null) {
        await mapController!.animateCamera(CameraUpdate.newLatLngZoom(loc, 17));
      }
    });
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final live = context.read<LiveLocationProvider>();

      if (live.currentLocation == null) {
        await live.fetchInitialLocation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final stopProvider = context.watch<StopManagementProvider>();
    final selectedLocation = stopProvider.selectedLocation;

    return Scaffold(
      appBar: AppBar(title: const Text('Select Location')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: selectedLocation ?? const LatLng(11.2588, 75.7804),
          zoom: 17,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        onMapCreated: (controller) => mapController = controller,
        markers: selectedLocation == null
            ? {}
            : {
                Marker(
                  markerId: const MarkerId('selected_location'),
                  position: selectedLocation,
                ),
              },
        onTap: (latLng) {
          stopProvider.setSelectedLocation(latLng);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.check),
        label: const Text('Confirm'),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
