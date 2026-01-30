import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:school_bus_tracker/features/driver_routes/data/models/route_model.dart';
import 'package:school_bus_tracker/features/driver_routes/data/services/route_services.dart';

class RouteProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<RouteModel> _routes = [];
  List<RouteModel> get driverRoutes => _routes;

  void _setLoading(bool val) {
    if (_isLoading != val) {
      _isLoading = val;
      notifyListeners();
    }
  }

  /// Fetch driver routes
  /// Returns error message if fails, null if success
  Future<String?> fetchDriverRoutes() async {
    _setLoading(true);
    try {
      final response = await RouteServices().fetchDriverRoutes();

      if (response.statusCode == 200) {
        final fetchedRoutes = response.data['data'];
        if (fetchedRoutes == null || fetchedRoutes is! List) {
          return "No routes found";
        }

        _routes = fetchedRoutes
            .map<RouteModel>((e) => RouteModel.fromJson(e))
            .toList();
        log("Fetched routes: $_routes");
        return null; // success
      }

      // Server returned an error
      final errorMsg = response.data['message'] ??
          "Failed to fetch routes (status: ${response.statusCode})";
      return errorMsg;
    } catch (e) {
      log("Fetch routes error: $e");
      return "Something went wrong. Try again.";
    } finally {
      _setLoading(false);
    }
  }
}