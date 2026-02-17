import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_bus_tracker/features/tracking/presentation/provider/directions_provider.dart';
import 'package:school_bus_tracker/features/tracking/presentation/provider/stop_management_provider.dart';
import 'package:school_bus_tracker/features/tracking/presentation/widgets/stop_detail_bottomsheet.dart';
import 'package:school_bus_tracker/features/tracking/presentation/widgets/stop_tile.dart';
import 'package:school_bus_tracker/features/tracking/presentation/widgets/students_in_stop_dialog.dart';
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
      initialChildSize: 0.5,
      minChildSize: minSize,
      maxChildSize: maxSize,
      snap: true,
      snapSizes: [minSize, maxSize],
      builder: (context, scrollController) {
        if (stops.isEmpty || nextStop == null) {
          return const SizedBox.shrink();
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
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
                      color: const Color(0xFFE2E8F0),
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
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF00D9A3).withAlpha(80),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00D9A3).withAlpha(25),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                              BoxShadow(
                                color: Colors.black.withAlpha(6),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Active header strip
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFF00D9A3).withAlpha(30),
                                      const Color(0xFF00D9A3).withAlpha(12),
                                    ],
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(18),
                                    topRight: Radius.circular(18),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF00D9A3),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(
                                              0xFF00D9A3,
                                            ).withAlpha(120),
                                            blurRadius: 6,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 7),
                                    Text(
                                      'NEXT STOP',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF00D9A3),
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Stop info
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  14,
                                  16,
                                  14,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Stop name row
                                    Row(
                                      children: [
                                        Container(
                                          width: 46,
                                          height: 46,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                const Color(
                                                  0xFF00D9A3,
                                                ).withAlpha(40),
                                                const Color(
                                                  0xFF00D9A3,
                                                ).withAlpha(20),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.location_on_rounded,
                                            size: 22,
                                            color: Color(0xFF00D9A3),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Stop Name',
                                                style: TextStyle(
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey[500],
                                                  letterSpacing: 0.4,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                nextStop.stopName,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF0F172A),
                                                  letterSpacing: 0.1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 14),

                                    // Action row: Students + Directions
                                    Row(
                                      children: [
                                        // Students button
                                        GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (_) =>
                                                  StudentsInStopDialog(),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFF6366F1,
                                              ).withAlpha(15),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: const Color(
                                                  0xFF6366F1,
                                                ).withAlpha(40),
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.people_alt_rounded,
                                                  size: 15,
                                                  color: const Color(
                                                    0xFF6366F1,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  'Students',
                                                  style: const TextStyle(
                                                    fontSize: 12.5,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF6366F1),
                                                    letterSpacing: 0.2,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Icon(
                                                  Icons
                                                      .arrow_forward_ios_rounded,
                                                  size: 11,
                                                  color: const Color(
                                                    0xFF6366F1,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        const Spacer(),

                                        // Directions button
                                        GestureDetector(
                                          onTap: () {
                                            final url = context
                                                .read<DirectionsProvider>()
                                                .buildGoogleMapsUrl(nextStop);
                                            launchUrl(Uri.parse(url));
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFF0EA5E9,
                                              ).withAlpha(15),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: const Color(
                                                  0xFF0EA5E9,
                                                ).withAlpha(40),
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.directions_rounded,
                                                  size: 15,
                                                  color: const Color(
                                                    0xFF0EA5E9,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                const Text(
                                                  'Directions',
                                                  style: TextStyle(
                                                    fontSize: 12.5,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF0EA5E9),
                                                    letterSpacing: 0.2,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 14),

                                    // Arrived button
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          // context
                                          //     .read<StopManagementProvider>()
                                          //     .completeCurrentStop();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF00D9A3,
                                          ),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 13,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            Icon(
                                              Icons
                                                  .check_circle_outline_rounded,
                                              size: 18,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Arrived at Stop',
                                              style: TextStyle(
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.4,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
                                color: const Color(0xFF6366F1),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Upcoming Stops',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
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
                                color: const Color(0xFF6366F1).withAlpha(15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${stops.length}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF6366F1),
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
                                ),
                              );
                            },
                          ),
                        );
                      }, childCount: stops.length),
                    ),

                    const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
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
