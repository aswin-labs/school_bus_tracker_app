import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:school_bus_tracker/core/extensions/size_extensions.dart';
import 'package:school_bus_tracker/core/widgets/shimmer/shimmer_list.dart';
import 'package:school_bus_tracker/features/driver_routes/presentation/provider/route_provider.dart';
import 'package:school_bus_tracker/features/driver_routes/presentation/widgets/driver_route_card.dart';
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
                      onButtonTap: () => context.pushNamed(
                        RouterConstants.trackingScreen,
                        extra: route.id,
                      ),
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
