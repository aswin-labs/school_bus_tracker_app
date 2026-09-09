import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_bus_tracker/core/theme/app_colors.dart';
import 'package:school_bus_tracker/core/utils/snackbar_helper.dart';
import 'package:school_bus_tracker/core/widgets/add_button.dart';
import 'package:school_bus_tracker/features/home/presentation/provider/route_provider.dart';
import 'package:school_bus_tracker/features/live_tracking/data/models/stop_model.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/provider/stops_provider.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/widgets/rearrange_stops_dialog.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/widgets/stop_detials_bottomsheet.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/widgets/stop_tile.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/widgets/add_stop_dialog.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/widgets/assign_pair_stops_dialog.dart';

class StopsManagementBottomsheet extends StatefulWidget {
  final int routeId;
  const StopsManagementBottomsheet({super.key, required this.routeId});

  @override
  State<StopsManagementBottomsheet> createState() =>
      _StopsManagementBottomsheetState();
}

class _StopsManagementBottomsheetState
    extends State<StopsManagementBottomsheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStops();
    });
  }

  Future<void> _loadStops() async {
    final provider = context.read<StopsProvider>();
    provider.fetchUnassignedStopsInPairRoute(widget.routeId);
    final error = await provider.fetchStopsByRouteId(widget.routeId);
    if (!mounted || error == null) return;

    SnackbarHelper.showError(context, message: error);
  }

  Future<void> _confirmDeleteStop(StopModel stop) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Delete Stop',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete "${stop.stopName}"? All student assignments for this stop will also be removed.',
            style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) return;

    final error = await context.read<StopsProvider>().deleteStop(
      stopId: stop.id,
      routeId: widget.routeId,
    );

    if (!mounted) return;

    if (error == null) {
      SnackbarHelper.showSuccess(
        context,
        message: '${stop.stopName} deleted successfully',
      );
      context.read<RouteProvider>().fetchDriverRoutes();
    } else {
      SnackbarHelper.showError(context, message: error);
    }
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
                      color: AppColors.border,
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
                          color: AppColors.cardBg,
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                            color: AppColors.border,
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          size: 18,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Stop List Management',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const Spacer(),

                    const SizedBox(width: 36), // Balance
                  ],
                ),
              ),

              const Divider(height: 1, thickness: 1, color: AppColors.divider),

              // ── SCROLLABLE CONTENT ──────────────────────────
              Expanded(
                child: Consumer<StopsProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }

                    final stops = provider.stops;

                    if (stops.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                size: 64,
                                color: AppColors.textDisabled,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No Stops found',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              AddButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) =>
                                        AddStopDialog(routeId: widget.routeId),
                                  );
                                },
                                buttonText: 'Add New Stop',
                              ),
                              if (provider.unassignedPairStops.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                OutlinedButton.icon(
                                  onPressed: () async {
                                    final updated = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AssignPairStopsDialog(
                                        routeId: widget.routeId,
                                        currentStopsCount: 0,
                                      ),
                                    );
                                    if (updated == true) {
                                      _loadStops();
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.alt_route_rounded,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                  label: Text(
                                    'Import Stops from Pair Route (${provider.unassignedPairStops.length})',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: AppColors.primary,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
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
                                color: AppColors.cardBg,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.border,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      gradient: AppColors.primaryGradient,
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
                                        const Text(
                                          'ROUTE NAME',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textMuted,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Consumer<StopsProvider>(
                                          builder: (context, provider, _) {
                                            return Text(
                                              provider.route?.routeName == null
                                                  ? "No Route found!"
                                                  : provider.route?.routeName ??
                                                        "Route not specified!",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.textPrimary,
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

                        // Import Pair Stops Banner (if available)
                        if (provider.unassignedPairStops.isNotEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
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
                                    _loadStops();
                                  }
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.primary.withAlpha(18),
                                        AppColors.accent.withAlpha(18),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColors.primary.withAlpha(60),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(12),
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
                                              'Import from Pair Route',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${provider.unassignedPairStops.length} unassigned stop(s) available',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chevron_right_rounded,
                                        color: AppColors.primary,
                                        size: 22,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // Add Stop Button (Clear call-to-action)
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
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Total ${stops.length} Stops',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: AppColors.textPrimary,
                                        letterSpacing: 0.2,
                                      ),
                                ),
                                const Spacer(),
                                TextButton.icon(
                                  onPressed: () async {
                                    final updated = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => RearrangeStopsDialog(
                                        stops: provider.stops,
                                        routeId: widget.routeId,
                                        isPickupRoute:
                                            provider.route?.type == "PICKUP",
                                      ),
                                    );
                                    if (updated == true) {
                                      _loadStops();
                                    }
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  icon: const Icon(
                                    Icons.swap_vert_rounded,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    'Reorder',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        /// ALL STOPS LIST
                        Consumer<StopsProvider>(
                          builder: (context, provider, _) {
                            return SliverPadding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate((
                                  context,
                                  index,
                                ) {
                                  final stop = provider.stops[index];
                                  final studentsCount =
                                      stop.students?.length ?? 0;
                                  final priority =
                                      stop.stopPriority?.first.priority ?? 0;
                                  return StopTile(
                                    stopName: stop.stopName,
                                    priority: priority,
                                    studentsCount: studentsCount,
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (context) =>
                                            StopDetailsBottomsheet(
                                              stopId: stop.id,
                                              routeId: widget.routeId,
                                            ),
                                      );
                                    },
                                    onDelete: () => _confirmDeleteStop(stop),
                                    isDeleting: provider.isDeletingStop &&
                                        provider.deletingStopId == stop.id,
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
