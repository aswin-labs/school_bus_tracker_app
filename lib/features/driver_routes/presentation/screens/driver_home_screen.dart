import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:school_bus_tracker/core/extensions/size_extensions.dart';
import 'package:school_bus_tracker/core/widgets/shimmer/shimmer_list.dart';
import 'package:school_bus_tracker/features/driver_routes/presentation/provider/route_provider.dart';
import 'package:school_bus_tracker/features/driver_routes/presentation/widgets/driver_route_card.dart';
import 'package:school_bus_tracker/features/driver_routes/presentation/widgets/start_journey_dialog.dart';
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

  // _loadRoutes
  Future<void> _loadRoutes() async {
    final provider = context.read<RouteProvider>();
    final error = await provider.fetchDriverRoutes();

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  // activate route
  Future<bool> _activateRoute(int routeId) async {
    final provider = context.read<RouteProvider>();

    final error = await provider.activateRoute(routeId);

    if (!mounted) return false;

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Today's Routes"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => context.pushNamed(RouterConstants.settingsScreen),
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: CustomScrollView(
          slivers: [
            Consumer<RouteProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return ShimmerList(itemHeight: 20.hp, itemCount: 3);
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final route = provider.driverRoutes[index];
                    return DriverRouteCard(
                      routeName: route.routeName ?? "",
                      timeRange: "07:30 am - 08:30 am",
                      isLive: route.active == true,
                      onButtonTap: () {
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

                                    final success = await _activateRoute(
                                      route.id,
                                    );

                                    if (!mounted) return;

                                    if (success) {
                                      // ignore: use_build_context_synchronously
                                      Navigator.pop(context);
                                      this.context.pushNamed(
                                        RouterConstants.trackingScreen,
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
                      },
                    );
                  }, childCount: provider.driverRoutes.length),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
