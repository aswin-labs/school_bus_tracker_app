import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_bus_tracker/core/theme/app_colors.dart';
import 'package:school_bus_tracker/features/tracking/presentation/provider/directions_provider.dart';
import 'package:school_bus_tracker/features/tracking/presentation/provider/stop_management_provider.dart';
import 'package:school_bus_tracker/features/tracking/presentation/widgets/arrived_student_dialog.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/widgets/next_stop_card.dart';
import 'package:school_bus_tracker/features/tracking/presentation/widgets/stop_detail_bottomsheet.dart';
import 'package:school_bus_tracker/features/tracking/presentation/widgets/stop_tile.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/widgets/students_in_stop_dialog.dart';
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
    final allStops = stopProvider.stops;

    final stops = allStops
        .where((s) => s.stopLiveStatuses?.isEmpty == true)
        .toList();
    final arrivedStops = allStops
        .where((s) => s.stopLiveStatuses?.isNotEmpty == true)
        .toList();
    final nextStop = stopProvider.nextStop;
    final isPickUp = stopProvider.route?.type == "PICKUP";

    return DraggableScrollableSheet(
      controller: sheetController,
      initialChildSize: 0.5,
      minChildSize: minSize,
      maxChildSize: maxSize,
      snap: true,
      snapSizes: [minSize, maxSize],
      builder: (context, scrollController) {
        final allStops = stopProvider.stops;

        if (allStops.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(12),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Stack(
            children: [
              /// DRAG HANDLE
              Positioned(
                top: 12,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),

              /// CONTENT
              Padding(
                padding: const EdgeInsets.only(top: 28),
                child: CustomScrollView(
                  controller: scrollController,
                  physics: const ClampingScrollPhysics(),
                  slivers: [
                    /// NEXT STOP CARD
                    if (nextStop != null)
                      SliverToBoxAdapter(
                        child: NextStopCard(
                          stopName: nextStop.stopName,
                          stopId: nextStop.id,
                          isPickup: isPickUp,
                          onStudentsTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => StudentsInStopDialog(
                                stopId: nextStop.id ?? 0,
                              ),
                            );
                          },
                          onDirectionsTap: () {
                            final url = context
                                .read<DirectionsProvider>()
                                .buildGoogleMapsUrl(nextStop);
                            launchUrl(Uri.parse(url));
                          },
                          onArrivedTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => ArrivedStudentDialog(
                                stopId: nextStop.id ?? 0,
                                forPicking: isPickUp,
                              ),
                            );
                          },
                        ),
                      ),
                    if (nextStop == null)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: Text(
                              "All stops completed 🎉",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),

                    /// UPCOMING STOPS HEADER
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 16, 10),
                        child: Row(
                          children: [
                            Container(
                              width: 3,
                              height: 16,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Upcoming Stops',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${stops.length}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    /// STOPS LIST
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final stop = stops[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: StopTile(
                            stopName: stop.stopName,
                            studentsCount: stop.students?.length ?? 0,
                            time: 'time',
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) => StopDetailsBottomsheet(
                                  stopId: stop.id ?? 0,
                                  routeId:
                                      context
                                          .read<StopManagementProvider>()
                                          .currentRouteId ??
                                      0,
                                ),
                              );
                            },
                          ),
                        );
                      }, childCount: stops.length),
                    ),

                    // completed stops
                    if (arrivedStops.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 16, 10),
                          child: Row(
                            children: [
                              Container(
                                width: 3,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: AppColors.success,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Completed Stops',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withAlpha(15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${arrivedStops.length}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.success,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    /// COMPLETED STOPS LIST
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final stop = arrivedStops[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: StopTile(
                            stopName: stop.stopName,
                            studentsCount: stop.students?.length ?? 0,
                            time: "time",
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) => StopDetailsBottomsheet(
                                  stopId: stop.id ?? 0,
                                  routeId:
                                      context
                                          .read<StopManagementProvider>()
                                          .currentRouteId ??
                                      0,
                                ),
                              );
                            },
                          ),
                        );
                      }, childCount: arrivedStops.length),
                    ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        child: Builder(
                          builder: (context) {
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final routeId = context
                                      .read<StopManagementProvider>()
                                      .currentRouteId;
                                  log(routeId.toString());

                                  if (routeId == null) return;

                                  await context
                                      .read<StopManagementProvider>()
                                      .updateRouteInActive(
                                        routeId: routeId,
                                        context: context,
                                      );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  "Mark Trip as Completed",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
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
