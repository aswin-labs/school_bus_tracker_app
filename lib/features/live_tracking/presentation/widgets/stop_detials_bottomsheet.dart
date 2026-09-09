import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_bus_tracker/core/utils/snackbar_helper.dart';
import 'package:school_bus_tracker/core/widgets/add_button.dart';
import 'package:school_bus_tracker/core/widgets/custom_more_menu.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/provider/stops_provider.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/widgets/add_student_dialog.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/widgets/assign_pair_stops_dialog.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/widgets/edit_stop_dialog.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/widgets/student_tile.dart';

class StopDetailsBottomsheet extends StatefulWidget {
  final int stopId;
  final bool isCompleted;
  final int routeId;
  const StopDetailsBottomsheet({
    super.key,
    required this.stopId,
    required this.routeId,
    this.isCompleted = false,
  });

  @override
  State<StopDetailsBottomsheet> createState() => _StopDetailsBottomsheetState();
}

class _StopDetailsBottomsheetState extends State<StopDetailsBottomsheet> {
  late final StopsProvider _stopsProvider;

  @override
  void initState() {
    super.initState();
    _stopsProvider = context.read<StopsProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStopDetails();
    });
  }

  @override
  void dispose() {
    _stopsProvider.clearSingleStop();
    super.dispose();
  }

  Future<void> _loadStopDetails() async {
    final provider = context.read<StopsProvider>();
    provider.fetchUnassignedStopsInPairRoute(widget.routeId);
    final error = await provider.fetchSingleStop(
      stopId: widget.stopId,
      routeId: widget.routeId,
    );
    if (!mounted || error == null) return;

    SnackbarHelper.showError(context, message: error);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
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
          child: Column(
            children: [
              // ── DRAG HANDLE ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
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

              // ── HEADER BAR ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          size: 18,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Stop Details',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: const Color(0xFF0F172A),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const Spacer(),
                    Consumer<StopsProvider>(
                      builder: (context, provider, _) {
                        final stop = provider.singleStop;
                        if (stop == null || stop.id != widget.stopId) {
                          return const SizedBox(width: 36);
                        }
                        return CustomMoreMenu(
                          icon: Icons.more_vert_rounded,
                          iconColor: const Color(0xFF0F172A),
                          iconSize: 20,
                          options: [
                            MoreMenuOption(
                              name: 'Edit Stop',
                              icon: Icons.edit_rounded,
                              iconColor: const Color(0xFF3B82F6),
                              textColor: const Color(0xFF0F172A),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => EditStopDialog(
                                    stop: stop,
                                    routeId: widget.routeId,
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

              // ── SCROLLABLE CONTENT ──────────────────────────
              Expanded(
                child: Consumer<StopsProvider>(
                  builder: (context, provider, _) {
                    final stop = provider.singleStop;

                    if (provider.isDetailsLoading ||
                        (stop != null && stop.id != widget.stopId)) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF3B82F6),
                        ),
                      );
                    }

                    if (stop == null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Stop not found',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return CustomScrollView(
                      controller: scrollController,
                      slivers: [
                        // Stop Info Card (Informational - Not button-like)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFF3B82F6),
                                          Color(0xFF2563EB),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                      Icons.location_on_rounded,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'STOP NAME',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.grey[500],
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          stop.stopName,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF0F172A),
                                            letterSpacing: 0.2,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Import Pair Stops Option (if available)
                        if (provider.unassignedPairStops.isNotEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: InkWell(
                                onTap: () async {
                                  final updated = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AssignPairStopsDialog(
                                      routeId: widget.routeId,
                                      currentStopsCount: provider.stops.length,
                                    ),
                                  );
                                  if (updated == true) {
                                    _loadStopDetails();
                                  }
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF3B82F6).withAlpha(18),
                                        const Color(0xFF6366F1).withAlpha(18),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(
                                        0xFF3B82F6,
                                      ).withAlpha(60),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF3B82F6),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.alt_route_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Import Stops from Pair Route',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF0F172A),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${provider.unassignedPairStops.length} unassigned stop(s) available',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chevron_right_rounded,
                                        color: Color(0xFF3B82F6),
                                        size: 22,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // Add Student Button (Clear call-to-action)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: AddButton(
                              onPressed: () {
                                // final routeId = stop.routeId;
                                showDialog(
                                  context: context,
                                  builder: (_) => AddStudentDialog(
                                    routeId: widget.routeId,
                                    stopId: widget.stopId,
                                    // alreadyAddedStudents: stop.students,
                                  ),
                                );
                              },
                              buttonText: 'Add New Student',
                            ),
                          ),
                        ),

                        // Students Section Header
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 3,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3B82F6),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Students at this Stop',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: const Color(0xFF0F172A),
                                        letterSpacing: 0.2,
                                      ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF3B82F6,
                                    ).withAlpha(20),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(
                                        0xFF3B82F6,
                                      ).withAlpha(60),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    '${stop.students?.length ?? 0}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF3B82F6),
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Student List or Empty State
                        (stop.students?.isEmpty ?? true)
                            ? SliverFillRemaining(
                                hasScrollBody: false,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 40,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(24),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF10B981,
                                          ).withAlpha(15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.people_outline_rounded,
                                          size: 56,
                                          color: const Color(
                                            0xFF10B981,
                                          ).withAlpha(150),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        'No students yet',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Add students to this stop using\nthe button above',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[500],
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : SliverPadding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  24,
                                ),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate((
                                    context,
                                    index,
                                  ) {
                                    final student = stop.students![index];

                                    const avatarColors = [
                                      [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                      [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
                                      [Color(0xFFF59E0B), Color(0xFFF97316)],
                                      [Color(0xFF10B981), Color(0xFF059669)],
                                      [Color(0xFFEC4899), Color(0xFFEF4444)],
                                    ];

                                    final colorPair =
                                        avatarColors[index %
                                            avatarColors.length];

                                    return StudentTile(
                                      studentName: student.fullName,
                                      guardianName: student.user?.name ?? '',
                                      phoneNumber: student.user?.phone,
                                      colorPair: colorPair,
                                    );
                                  }, childCount: stop.students!.length),
                                ),
                              ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
