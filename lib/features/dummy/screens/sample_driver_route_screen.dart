import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:school_bus_tracker/core/extensions/size_extensions.dart';
import 'package:school_bus_tracker/core/widgets/shimmer/shimmer_list.dart';
import 'package:school_bus_tracker/features/driver_routes/data/models/route_model.dart';
import 'package:school_bus_tracker/features/driver_routes/presentation/provider/route_provider.dart';
import 'package:school_bus_tracker/features/driver_routes/presentation/widgets/driver_route_card.dart';
import 'package:school_bus_tracker/routes/router_constants.dart';

class SampleDriverRouteScreen extends StatelessWidget {
  SampleDriverRouteScreen({super.key});

  final List<RouteModel> _driverRoutes = [
    RouteModel(routeName: "Kannur - Dharmasala", type: "Pick Up"),
  ];

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
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final route = _driverRoutes[index]; //dummy data
                      return DriverRouteCard(
                        routeName: route.routeName ?? "",
                        timeRange: "07:30 am - 08:30 am",
                        onButtonTap: () =>
                            context.pushNamed(RouterConstants.sampleMapScreen),
                      );
                    },
                    childCount: _driverRoutes.length,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
