import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_bus_tracker/core/extensions/context_extensions.dart';
import 'package:school_bus_tracker/core/extensions/size_extensions.dart';
import 'package:school_bus_tracker/core/utils/common_empty_state.dart';
import 'package:school_bus_tracker/core/utils/snackbar_helper.dart';
import 'package:school_bus_tracker/core/widgets/shimmer/shimmer_list.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/provider/stops_provider.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/widgets/stop_tile.dart';

class LiveTrackingScreen extends StatefulWidget {
  final int routeId;
  const LiveTrackingScreen({super.key, required this.routeId});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStops();
    });
  }

  Future<void> _loadStops() async {
    final provider = context.read<StopsProvider>();
    final error = await provider.fetchStopsByRouteId(widget.routeId);
    if (!mounted || error == null) return;

    SnackbarHelper.showError(context, message: error);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Stops'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(color: context.theme.canvasColor),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Consumer<StopsProvider>(
            builder: (context, provider, _) {
              return RefreshIndicator(
                onRefresh: _loadStops,
                color: Colors.black,
                child: CustomScrollView(
                  slivers: [
                    // Section Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Today's Stops",
                              style: context.text.titleLarge,
                            ),
                            if (provider.stops.isNotEmpty)
                              Text(
                                '${provider.stops.length} ${provider.stops.length == 1 ? 'Stop' : 'Stops'}',
                                style: context.text.titleMedium,
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (provider.isLoading)
                      ShimmerList(itemHeight: 8.hp, itemCount: 5, spacing: 6)
                    else if (provider.stops.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: const CommonEmptyState(
                          icon: Icons.event_busy_rounded,
                          title: 'No Stops Today',
                          message:
                              'You don\'t have any assigned stops for today. Check back later.',
                        ),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final stops = provider.stops;

                          final stop = stops[index];
                          final studentsCount = stop.students?.length;
                          final priority =
                              stop.stopPriority?.first.priority ?? 0;

                          return StopTile(
                            stopName: stop.stopName,
                            priority: priority,
                            studentsCount: studentsCount ?? 0,
                            onTap: () {
                              // Handle stop tile tap
                            },
                          );
                        }, childCount: provider.stops.length),
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
}
