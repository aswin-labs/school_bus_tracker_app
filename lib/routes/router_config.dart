import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_bus_tracker/core/storage/storage_services.dart';
import 'package:school_bus_tracker/features/auth/presentation/screens/login_screen.dart';
import 'package:school_bus_tracker/features/home/presentation/screens/driver_home_screen.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/screens/live_tracking_screen.dart';
import 'package:school_bus_tracker/features/settings/presentation/screens/settings_screen.dart';
import 'package:school_bus_tracker/features/tracking/presentation/screens/tracking_screen.dart';
import 'package:school_bus_tracker/routes/router_constants.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) async {
    if (state.uri.path == '/') {
      final token = await StorageService.instance.getToken();
      if (token != null && token.isNotEmpty) {
        return '/driverHomeScreen';
      } else {
        return '/loginScreen';
      }
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SizedBox.shrink(),
    ),

    // login
    GoRoute(
      path: '/loginScreen',
      name: RouterConstants.loginScreen,
      builder: (context, state) => LoginScreen(),
    ),

    // driverHome
    GoRoute(
      path: '/driverHomeScreen',
      name: RouterConstants.driverHomeScreen,
      builder: (context, state) => DriverHomeScreen(),
    ),

    // settings
    GoRoute(
      path: '/settingsScreen',
      name: RouterConstants.settingsScreen,
      builder: (context, state) => SettingsScreen(),
    ),

    // tracking
    GoRoute(
      path: '/trackingScreen',
      name: RouterConstants.trackingScreen,
      builder: (context, state) {
        final routeId = state.extra as int;
        return TrackingScreen(routeId: routeId);
      },
    ),

    // live tracking screen
    GoRoute(
      path: '/liveTrackingScreen',
      name: RouterConstants.liveTrackingScreen,
      builder: (context, state) {
        final routeId = state.extra as int;
        return LiveTrackingScreen(routeId: routeId);
      },
    ),
  ],
);
