import 'package:go_router/go_router.dart';
import 'package:school_bus_tracker/features/auth/presentation/screens/login_screen.dart';
import 'package:school_bus_tracker/features/auth/presentation/screens/splash_screen.dart';
import 'package:school_bus_tracker/features/driver_routes/presentation/screens/driver_home_screen.dart';
import 'package:school_bus_tracker/features/settings/presentation/screens/settings_screen.dart';
import 'package:school_bus_tracker/features/tracking/presentation/screens/tracking_screen.dart';
import 'package:school_bus_tracker/routes/router_constants.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // splash
    GoRoute(path: '/', builder: (context, state) => SplashScreen()),

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
  ],
);
