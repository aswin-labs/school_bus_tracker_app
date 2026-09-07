import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:school_bus_tracker/core/utils/api_error_utils.dart';
import 'package:school_bus_tracker/features/home/data/models/route_model.dart';
import 'package:school_bus_tracker/features/live_tracking/data/models/stop_model.dart';
import 'package:school_bus_tracker/features/live_tracking/data/services/stops_services.dart';

class StopsProvider extends ChangeNotifier {
  final StopServices _stopServices;

  StopsProvider(this._stopServices);

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<StopModel> _stops = [];
  List<StopModel> get stops => _stops;

  RouteModel? _route;
  RouteModel? get route => _route;

  // ---------------------------------------------------------------------------
  // Loading helpers
  // ---------------------------------------------------------------------------

  void _setLoading(bool value) {
    if (_isLoading == value) return;

    _isLoading = value;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Fetch stops
  // ---------------------------------------------------------------------------

  Future<String?> fetchStopsByRouteId(int routeId) async {
    _setLoading(true);

    try {
      final response = await _stopServices.fetchStops(routeId: routeId);

      log('Fetch driver stops response: ${response.data}');

      if (response.statusCode != 200) {
        return ApiErrorUtils.getErrorMessage(
          data: response.data,
          defaultMessage: 'Failed to fetch stops',
          statusCode: response.statusCode,
        );
      }

      final data = response.data['data'];

      if (data is! List) {
        _stops = [];
        notifyListeners();
        return 'No stops found';
      }
      _route = RouteModel.fromJson(response.data['route']);
      _stops = data.map<StopModel>((json) => StopModel.fromJson(json)).toList();

      notifyListeners();

      log('Fetched stops: $_stops');

      return null;
    } catch (e, stackTrace) {
      log('Fetch driver stops error: $e', stackTrace: stackTrace);

      return 'Something went wrong. Try again.';
    } finally {
      _setLoading(false);
    }
  }
}
