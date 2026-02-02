import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_bus_tracker/core/extensions/context_extensions.dart';
import 'package:school_bus_tracker/core/extensions/size_extensions.dart';
import 'package:school_bus_tracker/core/widgets/common_button.dart';
import 'package:school_bus_tracker/features/tracking/presentation/provider/directions_provider.dart';
import 'package:school_bus_tracker/features/tracking/presentation/provider/stop_management_provider.dart';
import 'package:school_bus_tracker/features/tracking/presentation/widgets/stop_tile.dart';
import 'package:url_launcher/url_launcher.dart';

class TrackingBottomSheet extends StatelessWidget {
  const TrackingBottomSheet({
    super.key,
    required this.sheetController,
    required this.minSize,
    required this.maxSize,
  });

  final DraggableScrollableController sheetController;
  final double minSize;
  final double maxSize;

  @override
  Widget build(BuildContext context) {
    final stopProvider = context.watch<StopManagementProvider>();
    final stops = stopProvider.stops;
    final nextStop = stopProvider.nextStop;

    return DraggableScrollableSheet(
      controller: sheetController,
      initialChildSize: 0.4,
      minChildSize: minSize,
      maxChildSize: maxSize,
      snap: true,
      snapSizes: [minSize, maxSize],
      builder: (context, scrollController) {
        if (stops.isEmpty || nextStop == null) {
          return const SizedBox.shrink();
        }

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Stack(
            children: [
              /// DRAG HANDLE
              Positioned(
                top: 8,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 50,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              /// CONTENT
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: CustomScrollView(
                  controller: scrollController,
                  physics: const ClampingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Next Stop",
                              style: context.text.bodyMedium!.copyWith(
                                color: const Color(0xFF9C9C9C),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              nextStop.stopName,
                              style: context.text.titleLarge!.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            1.5.h,

                            /// Directions button
                            Row(
                              children: [
                                Text(
                                  "Navigate",
                                  style: context.text.titleMedium!.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.directions),
                                  onPressed: () {
                                    final url = context
                                        .read<DirectionsProvider>()
                                        .buildGoogleMapsUrl(nextStop);
                                    launchUrl(Uri.parse(url));
                                  },
                                ),
                              ],
                            ),

                            1.5.h,
                            CommonButton(
                              title: "Arrived at Stop",
                              onTap: () {
                                context
                                    .read<StopManagementProvider>()
                                    .completeCurrentStop();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    /// UPCOMING STOPS
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 16, bottom: 16),
                        child: Text(
                          "Upcoming stops",
                          style: context.text.titleMedium!.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final stop = stops[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: StopTile(
                              stopName: stop.stopName,
                              studentsCount: 12,
                              time: "time",
                            ),
                          );
                        },
                        childCount: stops.length,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
