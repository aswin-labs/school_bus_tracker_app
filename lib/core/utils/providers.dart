import 'package:provider/provider.dart';
import 'package:school_bus_tracker/core/theme/theme_provider.dart';
import 'package:school_bus_tracker/features/auth/presentation/provider/auth_provider.dart';
import 'package:school_bus_tracker/features/driver_routes/presentation/provider/route_provider.dart';
import 'package:school_bus_tracker/features/tracking/presentation/provider/tracking_provider.dart';

getProviders(){
  return [
    // theme provider
    ChangeNotifierProvider(create: (_) => ThemeProvider()),

    // auth provider
    ChangeNotifierProvider(create: (_) => AuthProvider()),

    // route provider
    ChangeNotifierProvider(create: (_) => RouteProvider()),

    // tracking provider
    ChangeNotifierProvider(create: (_) => TrackingProvider()),
  ];
}