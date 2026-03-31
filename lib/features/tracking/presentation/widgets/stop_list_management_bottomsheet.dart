import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_bus_tracker/core/widgets/add_button.dart';
import 'package:school_bus_tracker/features/tracking/presentation/provider/stop_management_provider.dart';
import 'package:school_bus_tracker/features/tracking/presentation/widgets/add_stop_dialog.dart';
import 'package:school_bus_tracker/features/tracking/presentation/widgets/stop_detail_bottomsheet.dart';
import 'package:school_bus_tracker/features/tracking/presentation/widgets/stop_tile.dart';

class StopListManagementBottomsheet extends StatefulWidget {
  final int routeId;
  const StopListManagementBottomsheet({super.key, required this.routeId});

  @override
  State<StopListManagementBottomsheet> createState() =>
      _StopListManagementBottomsheetState();
}

class _StopListManagementBottomsheetState
    extends State<StopListManagementBottomsheet> {
  @override
  @override
  void initState() {
    super.initState();
    context.read<StopManagementProvider>().fetchStops(widget.routeId);
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
                      'Stop List Management',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: const Color(0xFF0F172A),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 36), // Balance
                  ],
                ),
              ),

              const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

              // ── SCROLLABLE CONTENT ──────────────────────────
              Expanded(
                child: Consumer<StopManagementProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF3B82F6),
                        ),
                      );
                    }

                    final stops = provider.stops;

                    if (stops.isEmpty) {
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
                              'No Stops found',
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
                                      Icons.route,
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
                                          'ROUTE NAME',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.grey[500],
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Consumer<StopManagementProvider>(
                                          builder: (context, provider, _) {
                                            return Text(
                                              provider.stops[0].routeName ==
                                                      null
                                                  ? "No Route found!"
                                                  : provider
                                                            .stops[0]
                                                            .routeName ??
                                                        "Route not specified!",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF0F172A),
                                                letterSpacing: 0.2,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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
                                showDialog(
                                  context: context,
                                  builder: (_) =>
                                      AddStopDialog(routeId: widget.routeId),
                                );
                              },
                              buttonText: 'Add New Stop',
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
                                  'All Stops in This Route',
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
                                    '${stops.length}',
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

                        /// ALL STOPS LIST
                        Consumer<StopManagementProvider>(
                          builder: (context, provider, _) {
                            return SliverPadding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate((
                                  context,
                                  index,
                                ) {
                                  final stop = provider.stops[index];
                                  return GestureDetector(
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (context) =>
                                            StopDetailsBottomsheet(
                                              stopId: stop.id ?? 0,
                                            ),
                                      );
                                    },
                                    child: StopTile(
                                      stopName: stop.stopName,
                                      studentsCount: stop.students?.length ?? 0,
                                      time: "08:30 AM",
                                    ),
                                  );
                                }, childCount: provider.stops.length),
                              ),
                            );
                          },
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
