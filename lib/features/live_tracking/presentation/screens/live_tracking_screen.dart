import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:school_bus_tracker/core/extensions/context_extensions.dart';
import 'package:school_bus_tracker/core/extensions/size_extensions.dart';
import 'package:school_bus_tracker/core/utils/common_empty_state.dart';
import 'package:school_bus_tracker/core/utils/snackbar_helper.dart';
import 'package:school_bus_tracker/core/widgets/shimmer/shimmer_list.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/provider/stops_provider.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/widgets/arrived_student_dialog.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/widgets/edit_completed_stop_students_dialog.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/widgets/next_stop_card.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/widgets/stop_detials_bottomsheet.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/widgets/stop_tile.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/widgets/stops_management_bottomsheet.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/widgets/students_in_stop_dialog.dart';
import 'package:school_bus_tracker/routes/router_constants.dart';
import 'package:url_launcher/url_launcher.dart';

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

    if (mounted && error == null) {
      provider.startLiveLocationSharing(widget.routeId);
    }

    if (!mounted || error == null) return;

    SnackbarHelper.showError(context, message: error);
  }

  Future<void> _openDirections(double latitude, double longitude) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (e) {
      log('Could not launch directions URL: $e');
      if (mounted) {
        SnackbarHelper.showError(
          context,
          message: 'Unable to open Google Maps directions',
        );
      }
    }
  }

  void _showFinishTripConfirmation(StopsProvider provider) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.flag_rounded, color: Color(0xFF3B82F6)),
            SizedBox(width: 10),
            Text(
              'Complete Trip?',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to mark this route as completed? This will inactivate the active trip.',
          style: TextStyle(fontSize: 14, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final success = await provider.updateRouteInActive(
                routeId: widget.routeId,
                context: context,
              );
              if (!mounted) return;
              if (success) {
                SnackbarHelper.showSuccess(
                  context,
                  message: 'Trip completed successfully!',
                );
                context.goNamed(RouterConstants.driverHomeScreen);
              } else {
                SnackbarHelper.showError(
                  context,
                  message: 'Failed to complete trip. Try again.',
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Complete Trip'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<StopsProvider>(
          builder: (context, provider, _) {
            final routeName = provider.route?.routeName;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  routeName ?? 'Live Tracking',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
                if (provider.route?.type != null)
                  Text(
                    provider.isPickup ? 'Pickup Route' : 'Drop Route',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: provider.isPickup
                          ? const Color(0xFF10B981)
                          : const Color(0xFF3B82F6),
                    ),
                  ),
              ],
            );
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(RouterConstants.driverHomeScreen);
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_vert_rounded),
            tooltip: 'Manage & Reorder Stops',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  return StopsManagementBottomsheet(
                    routeId: widget.routeId,
                  );
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(color: context.theme.canvasColor),
        child: Consumer<StopsProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: ShimmerList(
                      itemHeight: 10.hp,
                      itemCount: 5,
                      spacing: 10,
                    ),
                  ),
                ],
              );
            }

            if (provider.stops.isEmpty) {
              return RefreshIndicator(
                onRefresh: _loadStops,
                color: Colors.black,
                child: ListView(
                  children: [
                    SizedBox(height: 20.hp),
                    const CommonEmptyState(
                      icon: Icons.event_busy_rounded,
                      title: 'No Stops Today',
                      message:
                          'You don\'t have any assigned stops for today. Check back later.',
                    ),
                  ],
                ),
              );
            }

            final nextStop = provider.nextStop;
            final upcomingStops = provider.upcomingStops;
            final completedStops = provider.completedStops;
            final isPickUp = provider.isPickup;

            return RefreshIndicator(
              onRefresh: _loadStops,
              color: Colors.black,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  // ── NEXT STOP SECTION ─────────────────────────────────
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
                              stopId: nextStop.id,
                              routeId: widget.routeId,
                            ),
                          );
                        },
                        onDirectionsTap: () {
                          _openDirections(
                            nextStop.latitude,
                            nextStop.longitude,
                          );
                        },
                        onArrivedTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => ArrivedStudentDialog(
                              stopId: nextStop.id,
                              routeId: widget.routeId,
                              forPicking: isPickUp,
                            ),
                          );
                        },
                      ),
                    )
                  else
                    // All stops completed celebratory banner
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF10B981), Color(0xFF059669)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981).withAlpha(40),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(40),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.verified_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'All Stops Completed 🎉',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'You have arrived at all stops. You can finish this trip now.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white70,
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

                  // ── UPCOMING STOPS HEADER ─────────────────────────────
                  if (upcomingStops.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 16, 10),
                        child: Row(
                          children: [
                            Container(
                              width: 3.5,
                              height: 16,
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Upcoming Stops',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
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
                                color: const Color(0xFF3B82F6).withAlpha(20),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${upcomingStops.length}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF3B82F6),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // UPCOMING STOPS LIST
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final stop = upcomingStops[index];
                            final studentsCount = stop.students?.length ?? 0;
                            final priority =
                                (stop.stopPriority?.isNotEmpty == true
                                    ? stop.stopPriority!.first.priority
                                    : stop.priority) ??
                                (index + 1);

                            return StopTile(
                              stopName: stop.stopName,
                              priority: priority,
                              studentsCount: studentsCount,
                              isCompleted: false,
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) => StopDetailsBottomsheet(
                                    stopId: stop.id,
                                    routeId: widget.routeId,
                                    isCompleted: false,
                                  ),
                                );
                              },
                            );
                          },
                          childCount: upcomingStops.length,
                        ),
                      ),
                    ),
                  ],

                  // ── COMPLETED STOPS HEADER ────────────────────────────
                  if (completedStops.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 16, 10),
                        child: Row(
                          children: [
                            Container(
                              width: 3.5,
                              height: 16,
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Completed Stops',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
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
                                color: const Color(0xFF10B981).withAlpha(20),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${completedStops.length}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // COMPLETED STOPS LIST
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final stop = completedStops[index];
                            final studentsCount = stop.students?.length ?? 0;
                            final priority =
                                (stop.stopPriority?.isNotEmpty == true
                                    ? stop.stopPriority!.first.priority
                                    : stop.priority) ??
                                0;

                            return StopTile(
                              stopName: stop.stopName,
                              priority: priority,
                              studentsCount: studentsCount,
                              isCompleted: true,
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      EditCompletedStopStudentsDialog(
                                    stop: stop,
                                    routeId: widget.routeId,
                                    isPickup: isPickUp,
                                  ),
                                );
                              },
                            );
                          },
                          childCount: completedStops.length,
                        ),
                      ),
                    ),
                  ],

                  // ── MARK TRIP AS COMPLETED BUTTON ─────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 28, 16, 32),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: provider.isInactivatingRoute
                              ? null
                              : () => _showFinishTripConfirmation(provider),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: const Color(0xFF3B82F6),
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: provider.isInactivatingRoute
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle_rounded, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Mark Trip as Completed',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
