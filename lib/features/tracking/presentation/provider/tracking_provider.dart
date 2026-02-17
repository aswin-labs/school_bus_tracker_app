// import 'dart:async';
// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:school_bus_tracker/features/tracking/data/models/stop_model.dart';
// import 'package:school_bus_tracker/features/tracking/data/services/stop_services.dart';

// class TrackingProvider extends ChangeNotifier {
//   // ───────────────── STATE ─────────────────

//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   GoogleMapController? _mapController;

//   bool followVehicle = true;
//   bool trackingStarted = false;
//   bool locationLoaded = false;

//   LatLng? _currentLocation;
//   LatLng? get currentLocation => _currentLocation;

//   LatLng? _selectedLocation;
//   LatLng? get selectedLocation => _selectedLocation;

//   BitmapDescriptor? _busIcon;
//   Marker? _busMarker;

//   final Set<Marker> _markers = {};
//   final Set<Marker> _stopMarkers = {};
//   final Set<Polyline> _polylines = {};

//   Set<Marker> get markers => _markers;
//   Set<Polyline> get polylines => _polylines;

//   final List<LatLng> _path = [];
//   StreamSubscription<Position>? _positionStream;

//   CameraPosition initialPosition = const CameraPosition(
//     target: LatLng(11.2588, 75.7804),
//     zoom: 16,
//   );

//   // ───────────────── STOPS ─────────────────

//   List<StopModel> _sortedStops = [];
//   int _currentStopIndex = 0;

//   List<StopModel> get sortedStops => _sortedStops;

//   StopModel? get nextStop => (_currentStopIndex < _sortedStops.length)
//       ? _sortedStops[_currentStopIndex]
//       : null;

//   // ───────────────── MAP ─────────────────

//   void onMapCreated(GoogleMapController controller) {
//     _mapController = controller;
//     fetchCurrentLocation();
//   }

//   Future<void> fetchCurrentLocation() async {
//     final position = await Geolocator.getCurrentPosition();
//     _currentLocation = LatLng(position.latitude, position.longitude);
//     locationLoaded = true;

//     await _loadBusIcon();

//     _busMarker = _createBusMarker(_currentLocation!);
//     _rebuildMarkers();

//     _mapController?.animateCamera(
//       CameraUpdate.newLatLngZoom(_currentLocation!, 17),
//     );
//   }

//   Future<void> _loadBusIcon() async {
//     _busIcon ??= await BitmapDescriptor.asset(
//       const ImageConfiguration(size: Size(48, 48), devicePixelRatio: 3),
//       'assets/icons/bus.png',
//     );
//   }

//   Marker _createBusMarker(LatLng position) {
//     return Marker(
//       markerId: const MarkerId('bus'),
//       position: position,
//       icon: _busIcon!,
//       anchor: const Offset(0.5, 0.5),
//       flat: true,
//     );
//   }

//   // ───────────────── TRACKING ─────────────────

//   void startTracking() {
//     if (trackingStarted || _currentLocation == null) return;

//     trackingStarted = true;

//     _positionStream = Geolocator.getPositionStream(
//       locationSettings: const LocationSettings(
//         accuracy: LocationAccuracy.high,
//         distanceFilter: 5,
//       ),
//     ).listen(_onLocationUpdate);

//     notifyListeners();
//   }

//   void stopTracking() {
//     _positionStream?.cancel();
//     _positionStream = null;
//     trackingStarted = false;
//     notifyListeners();
//   }

//   void _onLocationUpdate(Position position) {
//     final point = LatLng(position.latitude, position.longitude);
//     _currentLocation = point;

//     _path.add(point);
//     _busMarker = _createBusMarker(point);

//     _polylines
//       ..clear()
//       ..add(
//         Polyline(
//           polylineId: const PolylineId('trail'),
//           points: List.unmodifiable(_path),
//           width: 6,
//           color: Colors.blue,
//         ),
//       );

//     if (followVehicle) {
//       _mapController?.animateCamera(
//         CameraUpdate.newCameraPosition(CameraPosition(target: point, zoom: 17)),
//       );
//     }

//     _rebuildMarkers();
//   }

//   // ───────────────── STOPS API ─────────────────

//   Future<void> fetchStops({required int routeId}) async {
//     _setLoading(true);

//     try {
//       final response = await StopServices().fetchStops(routeId: routeId);

//       if (response.statusCode == 200) {
//         _sortedStops =
//             (response.data['stops'] as List)
//                 .map((e) => StopModel.fromJson(e))
//                 .toList()
//               ..sort((a, b) => (a.priority ?? 0).compareTo(b.priority ?? 0));

//         _currentStopIndex = 0;
//         _stopMarkers.clear();

//         for (final stop in _sortedStops) {
//           _stopMarkers.add(
//             Marker(
//               markerId: MarkerId('stop_${stop.priority}'),
//               position: LatLng(stop.latitude, stop.longitude),
//               infoWindow: InfoWindow(
//                 title: stop.stopName,
//                 snippet: 'Priority ${stop.priority}',
//               ),
//               icon: BitmapDescriptor.defaultMarkerWithHue(
//                 BitmapDescriptor.hueRed,
//               ),
//             ),
//           );
//         }

//         _rebuildMarkers(notify: false);
//       }
//     } catch (e) {
//       log(e.toString());
//     } finally {
//       _setLoading(false);
//     }
//   }

//   Future<void> addStop({
//     required String stopName,
//     required int priority,
//     required int routeId,
//   }) async {
//     if (_currentLocation == null) return;

//     _setLoading(true);

//     try {
//       await StopServices().sendStop(
//         stop: StopModel(
//           routeId: routeId,
//           latitude: _selectedLocation!.latitude,
//           longitude: _selectedLocation!.longitude,
//           stopName: stopName,
//           priority: priority,
//         ),
//       );
//     } catch (e) {
//       log(e.toString());
//     } finally {
//       _setLoading(false);
//     }
//   }

//   void completeCurrentStop() {
//     if (_currentStopIndex < _sortedStops.length - 1) {
//       _currentStopIndex++;
//       notifyListeners();
//     }
//   }

//   // ───────────────── HELPERS ─────────────────
//   void setSelectedLocation(LatLng location) {
//     _selectedLocation = location;
//     notifyListeners();
//   }

//   void useCurrentLocation() {
//     if (_currentLocation == null) return;
//     _selectedLocation = _currentLocation;
//     notifyListeners();
//   }

//   void _rebuildMarkers({bool notify = true}) {
//     _markers
//       ..clear()
//       ..addAll(_stopMarkers);

//     if (_busMarker != null) {
//       _markers.add(_busMarker!);
//     }

//     if (notify) notifyListeners();
//   }

//   void _setLoading(bool value) {
//     _isLoading = value;
//     notifyListeners();
//   }

//   // ───────────────── CLEANUP ─────────────────

//   @override
//   void dispose() {
//     _positionStream?.cancel();
//     super.dispose();
//   }
// }
