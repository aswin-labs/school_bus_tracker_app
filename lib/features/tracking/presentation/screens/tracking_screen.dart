import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:school_bus_tracker/features/tracking/presentation/provider/directions_provider.dart';
import 'package:school_bus_tracker/features/tracking/presentation/provider/live_location_provider.dart';
import 'package:school_bus_tracker/features/tracking/presentation/provider/map_rendering_provider.dart';
import 'package:school_bus_tracker/features/tracking/presentation/provider/stop_management_provider.dart';
import 'package:school_bus_tracker/features/tracking/presentation/widgets/google_map_view.dart';
import 'package:school_bus_tracker/features/tracking/presentation/widgets/stop_list_management_bottomsheet.dart';
import 'package:school_bus_tracker/features/tracking/presentation/widgets/tracking_bottom_sheet.dart';

class TrackingScreen extends StatefulWidget {
  final int routeId;
  const TrackingScreen({super.key, required this.routeId});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  static const double _minSize = 0.35;
  static const double _maxSize = 0.65;

  static const double _rerouteThresholdMeters = 30;

  late LiveLocationProvider _live;
  late MapRenderingProvider _map;
  late StopManagementProvider _stops;
  late DirectionsProvider _directions;

  LatLng? _lastRoutedFrom;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;
    _initialized = true;

    _live = context.read<LiveLocationProvider>();
    _map = context.read<MapRenderingProvider>();
    _stops = context.read<StopManagementProvider>();
    _directions = context.read<DirectionsProvider>();

    _initialize();
  }

  Future<void> _initialize() async {
    /// RESET OLD STATE
    _lastRoutedFrom = null;
    _map.clearPolylines();
    _map.clearMarkers();
    _stops.reset();

    await _stops.fetchStops(widget.routeId);

    await _live.fetchInitialLocation();
    final loc = _live.currentLocation;

    if (loc != null) {
      _map.moveTo(loc);
      _map.updateBus(loc);
      await _drawRouteToNextStop();
    }

    _live.addListener(_onLocationChanged);
    await _live.startTracking();
  }

  void _onLocationChanged() {
    final loc = _live.currentLocation;
    if (loc == null) return;

    _map.updateBus(loc);

    if (_shouldReroute(loc)) {
      _drawRouteToNextStop();
    }
  }

  bool _shouldReroute(LatLng current) {
    if (_lastRoutedFrom == null) return true;

    final distance = Geolocator.distanceBetween(
      _lastRoutedFrom!.latitude,
      _lastRoutedFrom!.longitude,
      current.latitude,
      current.longitude,
    );

    return distance > _rerouteThresholdMeters;
  }

  Future<void> _drawRouteToNextStop() async {
    final from = _live.currentLocation;
    final stop = _stops.nextStop;

    if (from == null || stop == null) return;

    final points = await _directions.fetchRoute(
      from: from,
      to: LatLng(stop.latitude, stop.longitude),
    );

    if (points.isNotEmpty) {
      _map.updatePolyline(points);
      _lastRoutedFrom = from;
    }
  }

  @override
  void dispose() {
    _live.removeListener(_onLocationChanged);
    _live.stopTracking(); // IMPORTANT
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Route In Progress"), centerTitle: true),
      body: Stack(
        children: [
          const GoogleMapView(),

          Positioned(
            right: 16,
            top: 80,
            child: GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) {
                    return StopListManagementBottomsheet(
                      routeId: widget.routeId,
                    );
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.add),
                    SizedBox(width: 8),
                    Text(
                      "Add Stop",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),

          TrackingBottomSheet(
            sheetController: _sheetController,
            minSize: _minSize,
            maxSize: _maxSize,
          ),
        ],
      ),
    );
  }
}
