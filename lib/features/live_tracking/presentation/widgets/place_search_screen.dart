import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart'
    hide LatLng;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:school_bus_tracker/core/theme/app_colors.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/widgets/web_map/places_web_registrar.dart';

/// A full-screen place-search + map confirmation screen.
/// Returns a [LatLng] when the user confirms, or null if cancelled.
class PlaceSearchScreen extends StatefulWidget {
  final String apiKey;
  final LatLng? initialLocation;

  const PlaceSearchScreen({
    super.key,
    required this.apiKey,
    this.initialLocation,
  });

  @override
  State<PlaceSearchScreen> createState() => _PlaceSearchScreenState();
}

class _PlaceSearchScreenState extends State<PlaceSearchScreen> {
  late final FlutterGooglePlacesSdk _places;
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  List<AutocompletePrediction> _predictions = [];
  bool _isSearching = false;
  bool _showMap = true;
  bool _isFetchingDetails = false;
  bool _isLocatingCurrent = false;

  LatLng? _selectedLatLng;
  String? _selectedPlaceName;

  bool _ignoreSearchChange = false;

  GoogleMapController? _mapController;
  Timer? _debounce;

  static const _defaultCenter = LatLng(11.2588, 75.7804);

  @override
  void initState() {
    super.initState();
    ensurePlacesWebInitialized();
    _places = FlutterGooglePlacesSdk(widget.apiKey);
    _selectedLatLng = widget.initialLocation;
    _showMap = true;

    if (_selectedLatLng == null) {
      _fetchCurrentLocation();
    }

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_ignoreSearchChange) return;
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() => _predictions = []);
      return;
    }
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(query));
  }

  Future<void> _search(String query) async {
    setState(() => _isSearching = true);
    try {
      final result = await _places.findAutocompletePredictions(
        query,
        countries: [],
        placeTypesFilter: [],
      );
      if (mounted && !_ignoreSearchChange) {
        setState(() => _predictions = result.predictions);
      }
    } catch (_) {
      if (mounted) setState(() => _predictions = []);
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _selectPrediction(AutocompletePrediction prediction) async {
    _debounce?.cancel();
    FocusScope.of(context).unfocus();
    setState(() {
      _isFetchingDetails = true;
      _predictions = [];
    });

    try {
      final result = await _places.fetchPlace(
        prediction.placeId,
        fields: [PlaceField.Location, PlaceField.Name],
      );
      final loc = result.place?.latLng;
      if (loc != null && mounted) {
        final latLng = LatLng(loc.lat, loc.lng);
        _debounce?.cancel();
        _ignoreSearchChange = true;
        _searchController.text = prediction.fullText;
        _ignoreSearchChange = false;

        setState(() {
          _selectedLatLng = latLng;
          _selectedPlaceName = prediction.primaryText;
          _predictions = [];
          _showMap = true;
        });
        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 16));
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not determine location for this place')),
        );
      }
    } catch (e) {
      debugPrint('Error fetching place details: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not fetch place details')),
        );
      }
    } finally {
      if (mounted) setState(() => _isFetchingDetails = false);
    }
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() => _isLocatingCurrent = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );
      if (mounted) {
        final latLng = LatLng(pos.latitude, pos.longitude);
        setState(() {
          _selectedLatLng = latLng;
          _selectedPlaceName = 'Current Location';
          _showMap = true;
        });
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(latLng, 16),
        );
      }
    } catch (e) {
      debugPrint('Error getting current location: $e');
    } finally {
      if (mounted) setState(() => _isLocatingCurrent = false);
    }
  }

  void _onMapTap(LatLng latLng) {
    FocusScope.of(context).unfocus();
    setState(() {
      _selectedLatLng = latLng;
      _selectedPlaceName = null;
    });
  }

  void _confirm() {
    if (_selectedLatLng != null) {
      Navigator.pop(context, _selectedLatLng);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: AppColors.surface,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── HEADER ──────────────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top bar
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(30),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SEARCH LOCATION',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white70,
                                letterSpacing: 1.2,
                              ),
                            ),
                            SizedBox(height: 1),
                            Text(
                              'Search & Pin Stop Location',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Search field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      autofocus: false,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search for a place...',
                        hintStyle: const TextStyle(
                          fontSize: 13.5,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.normal,
                        ),
                        prefixIcon: _isSearching || _isFetchingDetails
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.search_rounded,
                                size: 20,
                                color: AppColors.textMuted,
                              ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  _debounce?.cancel();
                                  _searchController.clear();
                                  setState(() => _predictions = []);
                                },
                                child: const Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: AppColors.textMuted,
                                ),
                              )
                            : null,
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── BODY CONTENT ────────────────────────────────────
            Expanded(
              child: _predictions.isNotEmpty
                  ? Container(
                      color: AppColors.surface,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        itemCount: _predictions.length,
                        separatorBuilder: (_, __) => const Divider(
                          height: 1,
                          indent: 56,
                          color: AppColors.divider,
                        ),
                        itemBuilder: (context, index) {
                          final p = _predictions[index];
                          return InkWell(
                            onTap: () => _selectPrediction(p),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 11,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withAlpha(15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.location_on_rounded,
                                      size: 17,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.primaryText,
                                          style: const TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (p.secondaryText.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            p.secondaryText,
                                            style: const TextStyle(
                                              fontSize: 11.5,
                                              color: AppColors.textSecondary,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : (_showMap
                        ? Stack(
                            children: [
                              GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: _selectedLatLng ?? _defaultCenter,
                                  zoom: 15,
                                ),
                                onMapCreated: (c) => _mapController = c,
                                onTap: _onMapTap,
                                markers: _selectedLatLng == null
                                    ? {}
                                    : {
                                        Marker(
                                          markerId: const MarkerId('selected'),
                                          position: _selectedLatLng!,
                                          infoWindow: InfoWindow(
                                            title:
                                                _selectedPlaceName ??
                                                'Selected Location',
                                          ),
                                        ),
                                      },
                                myLocationEnabled: true,
                                myLocationButtonEnabled: false,
                                zoomControlsEnabled: false,
                                mapToolbarEnabled: false,
                              ),

                              // Tap-to-adjust hint
                              Positioned(
                                top: 12,
                                left: 16,
                                right: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(15),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.touch_app_rounded,
                                        size: 15,
                                        color: AppColors.primary.withAlpha(200),
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'Tap on the map to adjust pin',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Floating My Location Button
                              Positioned(
                                bottom: 16,
                                right: 16,
                                child: FloatingActionButton.small(
                                  heroTag: 'places_my_location_btn',
                                  onPressed: _fetchCurrentLocation,
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.primary,
                                  elevation: 4,
                                  child: _isLocatingCurrent
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.primary,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.my_location_rounded,
                                          size: 20,
                                        ),
                                ),
                              ),
                            ],
                          )
                        : Center(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_rounded,
                                    size: 56,
                                    color: AppColors.textDisabled,
                                  ),
                                  const SizedBox(height: 14),
                                  const Text(
                                    'Search for a location above',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Type a place name to find and pin it on the map',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textDisabled,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
            ),

            // ── CONFIRM BUTTON ───────────────────────────────────
            if (_predictions.isEmpty && !isKeyboardOpen)
              Container(
                padding: EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  12 + MediaQuery.of(context).padding.bottom,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: const Border(
                    top: BorderSide(color: AppColors.divider, width: 1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(8),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_selectedLatLng != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withAlpha(50),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _selectedPlaceName != null
                                    ? _selectedPlaceName!
                                    : '${_selectedLatLng!.latitude.toStringAsFixed(6)}, ${_selectedLatLng!.longitude.toStringAsFixed(6)}',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _selectedLatLng == null ? null : _confirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.border,
                          disabledForegroundColor: AppColors.textDisabled,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.pin_drop_rounded, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Confirm Location',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
