import 'package:provider/provider.dart';
import 'package:school_bus_tracker/core/theme/theme_provider.dart';
import 'package:school_bus_tracker/features/auth/presentation/provider/auth_provider.dart';
import 'package:school_bus_tracker/features/home/data/services/route_services.dart';
import 'package:school_bus_tracker/features/home/presentation/provider/route_provider.dart';
import 'package:school_bus_tracker/features/live_tracking/data/services/stops_services.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/provider/stops_provider.dart';
import 'package:school_bus_tracker/features/tracking/presentation/provider/directions_provider.dart';
import 'package:school_bus_tracker/features/tracking/presentation/provider/live_location_provider.dart';
import 'package:school_bus_tracker/features/tracking/presentation/provider/map_rendering_provider.dart';
import 'package:school_bus_tracker/features/tracking/presentation/provider/stop_management_provider.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/provider/student_provider.dart';

getProviders() {
  return [
    // theme provider
    ChangeNotifierProvider(create: (_) => ThemeProvider()),

    // auth provider
    ChangeNotifierProvider(create: (_) => AuthProvider()),

    // route provider
    ChangeNotifierProvider(
      create: (_) => RouteProvider(RouteServices(), StopManagementProvider()),
    ),

    // stop provider
    ChangeNotifierProvider(create: (_) => StopsProvider(StopServices())),

    ChangeNotifierProvider(
      create: (_) {
        final provider = LiveLocationProvider();
        provider.fetchInitialLocation();
        return provider;
      },
    ),

    ChangeNotifierProvider(create: (_) => StopManagementProvider()),
    ChangeNotifierProvider(create: (_) => MapRenderingProvider()),
    ChangeNotifierProvider(create: (_) => DirectionsProvider()),
    ChangeNotifierProvider(create: (_) => StudentProvider()),
  ];
}
