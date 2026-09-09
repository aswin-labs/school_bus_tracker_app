import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:school_bus_tracker/core/extensions/context_extensions.dart';
import 'package:school_bus_tracker/core/extensions/size_extensions.dart';
import 'package:school_bus_tracker/core/utils/common_empty_state.dart';
import 'package:school_bus_tracker/core/utils/date_time_helpers.dart';
import 'package:school_bus_tracker/core/utils/snackbar_helper.dart';
import 'package:school_bus_tracker/core/widgets/shimmer/shimmer_list.dart';
import 'package:school_bus_tracker/features/home/data/models/route_model.dart';
import 'package:school_bus_tracker/features/home/presentation/provider/route_provider.dart';
import 'package:school_bus_tracker/features/home/presentation/widgets/driver_route_card.dart';
import 'package:school_bus_tracker/features/home/presentation/widgets/drop_stop_preview_dialog.dart';
import 'package:school_bus_tracker/features/home/presentation/widgets/resume_trip_dialog.dart';
import 'package:school_bus_tracker/features/home/presentation/widgets/start_journey_dialog.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/widgets/stops_management_bottomsheet.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/widgets/add_stop_dialog.dart';
import 'package:school_bus_tracker/routes/router_constants.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRoutes();
    });
  }

  // load routes for listing
  Future<void> _loadRoutes() async {
    final provider = context.read<RouteProvider>();
    final error = await provider.fetchDriverRoutes();

    if (!mounted || error == null) return;

    SnackbarHelper.showError(context, message: error);
  }

  // sorted routes
  List<RouteModel> _getSortedRoutes(List<RouteModel> routes) {
    return [...routes]..sort(
      (a, b) => (b.active == true ? 1 : 0).compareTo(a.active == true ? 1 : 0),
    );
  }

  // activate route
  Future<bool> _activateRoute(int routeId) async {
    final provider = context.read<RouteProvider>();
    final error = await provider.activateRoute(routeId);

    if (!mounted) return false;

    if (error != null) {
      SnackbarHelper.showError(context, message: error);
      return false;
    }

    return true;
  }

  // handle route
  Future<void> _handleRouteTap(RouteModel route) async {
    final hasActiveRoute = context.read<RouteProvider>().driverRoutes.any(
      (r) => r.active == true,
    );

    final isLive = route.active == true;
    final isPickup = route.type == 'PICKUP';
    final hasStops = (route.totalStops ?? 0) > 0;

    if (hasActiveRoute && !isLive) {
      SnackbarHelper.showError(
        context,
        message: "You already have an active route. Please finish it first.",
      );
      return;
    }

    // Check if totalStops is 0 when trying to start trip
    if (!isLive && !hasStops) {
      SnackbarHelper.showError(
        context,
        message: "This route has no stops. Please add stops first.",
      );
      return;
    }

    // 1. If already active → go tracking
    if (isLive) {
      _showResumeTripDialog(route);
      return;
    }

    // 2. No active route
    if (!hasActiveRoute) {
      if (isPickup) {
        _showStartDialog(route);
        return;
      }

      // Drop route
      if (!hasStops) {
        _showDropPreview(route);
      } else {
        _showStartDialog(route);
      }
    }
  }

  // show start journey dialog
  void _showStartDialog(RouteModel route) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return StartJourneyDialog(
              isLoading: isLoading,
              onStart: () async {
                setStateDialog(() => isLoading = true);

                final success = await _activateRoute(route.id);

                if (!context.mounted) return;

                if (success) {
                  Navigator.of(context).pop(); // ✅ close dialog first

                  context.goNamed(
                    RouterConstants.liveTrackingScreen,
                    extra: route.id,
                  );
                } else {
                  setStateDialog(() => isLoading = false);
                }
              },
            );
          },
        );
      },
    );
  }

  // show resume dialog
  void _showResumeTripDialog(RouteModel route) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Consumer<RouteProvider>(
          builder: (context, provider, _) {
            return ResumeTripDialog(
              isDeactivating: provider.isDeactivating,

              onResume: () {
                Navigator.of(dialogContext).pop();

                context.pushNamed(
                  RouterConstants.liveTrackingScreen,
                  extra: route.id,
                );
              },

              deactivateRoute: () async {
                final error = await provider.inactivateRoute(route.id);

                if (!dialogContext.mounted) return;

                if (error != null) {
                  SnackbarHelper.showError(dialogContext, message: error);
                  return;
                }

                Navigator.of(dialogContext).pop();
              },
            );
          },
        );
      },
    );
  }

  // show drop preview dialog
  void _showDropPreview(RouteModel route) {
    showDialog(
      context: context,
      builder: (_) => DropStopsPreviewDialog(
        pickupRouteId: route.pickupId ?? 0,
        dropRouteId: route.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.theme.canvasColor,
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.directions_bus_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(getDayGreeting(), style: context.text.titleLarge),
                  const SizedBox(height: 2),
                  Text(
                    getCurrentDate(),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: context.theme.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () =>
                  context.pushNamed(RouterConstants.settingsScreen),
              icon: const Icon(Icons.settings_outlined),
              color: context.theme.dividerColor,
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(color: context.theme.canvasColor),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Consumer<RouteProvider>(
            builder: (context, provider, _) {
              return RefreshIndicator(
                onRefresh: _loadRoutes,
                color: Colors.black,
                child: CustomScrollView(
                  slivers: [
                    // Stats Section
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromARGB(
                                255,
                                162,
                                189,
                                233,
                              ).withAlpha(20),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildQuickStat(
                                icon: Icons.route_rounded,
                                label: 'Total Routes',
                                value: provider.driverRoutes.length.toString(),
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.white.withAlpha(77),
                            ),
                            Expanded(
                              child: _buildQuickStat(
                                icon: Icons.directions_bus_filled,
                                label: 'Active Now',
                                value: provider.driverRoutes
                                    .where((r) => r.active == true)
                                    .length
                                    .toString(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Section Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Today's Routes",
                              style: context.text.titleLarge,
                            ),
                            if (provider.driverRoutes.isNotEmpty)
                              Text(
                                '${provider.driverRoutes.length} ${provider.driverRoutes.length == 1 ? 'Route' : 'Routes'}',
                                style: context.text.titleMedium,
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (provider.isLoading)
                      ShimmerList(itemHeight: 20.hp, itemCount: 3)
                    else if (provider.driverRoutes.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: const CommonEmptyState(
                          icon: Icons.event_busy_rounded,
                          title: 'No Routes Today',
                          message:
                              'You don\'t have any assigned routes for today. Check back later.',
                        ),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final routes = _getSortedRoutes(
                            provider.driverRoutes,
                          );
                          final route = routes[index];

                          final isPickup = route.type == 'PICKUP';
                          final isLive = route.active == true;

                          return DriverRouteCard(
                            routeName: route.routeName ?? "Unknown Route",
                            totalStops: route.totalStops ?? 0,
                            onStopsTap: () {
                              route.totalStops == 0
                                  ? showDialog(
                                      context: context,
                                      builder: (_) =>
                                          AddStopDialog(routeId: route.id),
                                    )
                                  : showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (context) {
                                        return StopsManagementBottomsheet(
                                          routeId: route.id,
                                        );
                                      },
                                    );
                            },
                            isLive: isLive,
                            isPickup: isPickup,
                            onButtonTap: () => _handleRouteTap(route),
                          );
                        }, childCount: provider.driverRoutes.length),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withAlpha(230),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
