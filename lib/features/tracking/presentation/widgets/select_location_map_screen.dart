import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:school_bus_tracker/features/tracking/presentation/provider/tracking_provider.dart';

class SelectLocationMapScreen extends StatefulWidget {
  const SelectLocationMapScreen({super.key});

  @override
  State<SelectLocationMapScreen> createState() =>
      _SelectLocationMapScreenState();
}

class _SelectLocationMapScreenState extends State<SelectLocationMapScreen> {
  @override
  void initState() {
    super.initState();

    final provider = context.read<TrackingProvider>();

    if (provider.selectedLocation == null && provider.currentLocation != null) {
      provider.setSelectedLocation(provider.currentLocation!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TrackingProvider>();
    final location = provider.selectedLocation;

    return Scaffold(
      appBar: AppBar(title: const Text('Select Location')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: location ?? const LatLng(11.2588, 75.7804),
          zoom: 17,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        markers: location == null
            ? {}
            : {
                Marker(
                  markerId: const MarkerId('selected'),
                  position: location,
                ),
              },
        onTap: (latLng) {
          provider.setSelectedLocation(latLng);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.check),
        label: const Text('Confirm'),
      ),
    );
  }
}
