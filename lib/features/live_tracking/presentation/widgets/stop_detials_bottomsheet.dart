import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_bus_tracker/core/theme/app_colors.dart';
import 'package:school_bus_tracker/core/utils/location_helper.dart';
import 'package:school_bus_tracker/core/utils/snackbar_helper.dart';
import 'package:school_bus_tracker/core/widgets/add_button.dart';
import 'package:school_bus_tracker/core/widgets/custom_more_menu.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/provider/stops_provider.dart';
import 'package:school_bus_tracker/features/live_tracking/data/models/stop_model.dart';
import 'package:school_bus_tracker/features/live_tracking/data/models/student_model.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/provider/student_provider.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/widgets/add_student_dialog.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/widgets/assign_pair_stops_dialog.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/widgets/edit_stop_dialog.dart';
import 'package:school_bus_tracker/features/home/presentation/widgets/student_details_dialog.dart';
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
  bool _isUpdatingLocation = false;

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

  Future<void> _confirmDeleteStudent(StudentModel student) async {
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
                'Remove Student',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to remove ${student.fullName} from this stop?',
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
                'Remove',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) return;

    final error = await context.read<StudentProvider>().deleteStudentFromStop(
      stopId: widget.stopId,
      studentId: student.id,
    );

    if (!mounted) return;

    if (error == null) {
      SnackbarHelper.showSuccess(
        context,
        message: '${student.fullName} removed from stop',
      );
      _loadStopDetails();
      context.read<StopsProvider>().fetchStopsByRouteId(widget.routeId);
    } else {
      SnackbarHelper.showError(context, message: error);
    }
  }

  Future<void> _confirmDeleteCurrentStop(StopModel stop) async {
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
      Navigator.pop(context);
    } else {
      SnackbarHelper.showError(context, message: error);
    }
  }

  Future<void> _updateStopToCurrentLocation(StopModel stop) async {
    final shouldUpdate = await showDialog<bool>(
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
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.my_location_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Set Stop Location',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to update the location of "${stop.stopName}" to your device\'s current GPS position?',
                style: const TextStyle(
                  fontSize: 13.5,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(
                      (stop.latitude != 0.0 || stop.longitude != 0.0)
                          ? Icons.pin_drop_rounded
                          : Icons.location_off_rounded,
                      size: 16,
                      color: (stop.latitude != 0.0 || stop.longitude != 0.0)
                          ? AppColors.primary
                          : AppColors.textDisabled,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CURRENT COORDINATES',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMuted,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            (stop.latitude != 0.0 || stop.longitude != 0.0)
                                ? '${stop.latitude.toStringAsFixed(6)}, ${stop.longitude.toStringAsFixed(6)}'
                                : 'Not set',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: (stop.latitude != 0.0 || stop.longitude != 0.0)
                                  ? AppColors.textPrimary
                                  : AppColors.textDisabled,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
                backgroundColor: AppColors.primary,
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
                'Update Location',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );

    if (shouldUpdate != true || !mounted) return;

    setState(() => _isUpdatingLocation = true);

    try {
      final position = await LocationHelper.getCurrentPosition();

      if (!mounted) return;

      final error = await context.read<StopsProvider>().updateStop(
            stopId: stop.id,
            stopName: stop.stopName,
            latitude: position.latitude,
            longitude: position.longitude,
            routeId: widget.routeId,
          );

      if (!mounted) return;

      if (error == null) {
        SnackbarHelper.showSuccess(
          context,
          message: 'Stop location updated successfully',
        );
      } else {
        SnackbarHelper.showError(context, message: error);
      }
    } catch (e) {
      if (!mounted) return;
      final errorMsg = e is LocationException
          ? e.message
          : 'Failed to fetch current location: $e';
      SnackbarHelper.showError(context, message: errorMsg);
    } finally {
      if (mounted) {
        setState(() => _isUpdatingLocation = false);
      }
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
                      color: AppColors.divider,
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
                      'Stop Details',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: AppColors.textPrimary,
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
                          iconColor: AppColors.textPrimary,
                          iconSize: 20,
                          options: [
                            MoreMenuOption(
                              name: 'Edit Stop',
                              icon: Icons.edit_rounded,
                              iconColor: AppColors.primary,
                              textColor: AppColors.textPrimary,
                              onTap: () async {
                                final updated = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => EditStopDialog(
                                    stop: stop,
                                    routeId: widget.routeId,
                                  ),
                                );
                                if (updated == true && mounted) {
                                  _loadStopDetails();
                                }
                              },
                            ),
                            MoreMenuOption(
                              name: 'Delete Stop',
                              icon: Icons.delete_outline_rounded,
                              iconColor: AppColors.error,
                              textColor: AppColors.error,
                              onTap: () => _confirmDeleteCurrentStop(stop),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, thickness: 1, color: AppColors.divider),

              // ── SCROLLABLE CONTENT ──────────────────────────
              Expanded(
                child: Consumer<StopsProvider>(
                  builder: (context, provider, _) {
                    final stop = provider.singleStop;

                    if (provider.isDetailsLoading ||
                        (stop != null && stop.id != widget.stopId)) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
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
                        // Stop Info & Location Card
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 52,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          gradient: AppColors.primaryGradient,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: const Icon(
                                          Icons.location_on_rounded,
                                          color: Colors.white,
                                          size: 26,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
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
                                                color: AppColors.textMuted,
                                                letterSpacing: 1.2,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              stop.stopName,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.textPrimary,
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
                                  const SizedBox(height: 14),
                                  // Current Coordinates Bar
                                  Builder(
                                    builder: (context) {
                                      final hasCoords = stop.latitude != 0.0 ||
                                          stop.longitude != 0.0;
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 9,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: hasCoords
                                                ? AppColors.primary.withAlpha(35)
                                                : AppColors.border,
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              hasCoords
                                                  ? Icons.pin_drop_rounded
                                                  : Icons.location_off_rounded,
                                              size: 16,
                                              color: hasCoords
                                                  ? AppColors.primary
                                                  : AppColors.textDisabled,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'COORDINATES',
                                                    style: TextStyle(
                                                      fontSize: 9,
                                                      fontWeight: FontWeight.w700,
                                                      color: AppColors.textMuted,
                                                      letterSpacing: 0.8,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 1),
                                                  Text(
                                                    hasCoords
                                                        ? '${stop.latitude.toStringAsFixed(6)}, ${stop.longitude.toStringAsFixed(6)}'
                                                        : 'Location not set yet',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                      color: hasCoords
                                                          ? AppColors.textPrimary
                                                          : AppColors.textMuted,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  // Update to Current Location Action Button
                                  InkWell(
                                    onTap: (_isUpdatingLocation ||
                                            provider.isUpdatingStop)
                                        ? null
                                        : () => _updateStopToCurrentLocation(
                                              stop,
                                            ),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withAlpha(20),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.primary.withAlpha(60),
                                          width: 1.2,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          if (_isUpdatingLocation ||
                                              provider.isUpdatingStop) ...[
                                            const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Text(
                                              'Updating Location...',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.primary,
                                                letterSpacing: 0.2,
                                              ),
                                            ),
                                          ] else ...[
                                            const Icon(
                                              Icons.my_location_rounded,
                                              size: 18,
                                              color: AppColors.primary,
                                            ),
                                            const SizedBox(width: 8),
                                            const Text(
                                              'Set Stop to Current Location',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.primary,
                                                letterSpacing: 0.2,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
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

                        // Add Student Button (Clear call-to-action)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: AddButton(
                              onPressed: () async {
                                final updated = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AddStudentDialog(
                                    routeId: widget.routeId,
                                    stopId: widget.stopId,
                                  ),
                                );
                                if (updated == true && mounted) {
                                  _loadStopDetails();
                                }
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
                                    color: AppColors.primary,
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
                                        color: AppColors.textPrimary,
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
                                    color: AppColors.primary.withAlpha(20),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.primary.withAlpha(60),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    '${stop.students?.length ?? 0}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
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
                                          color: AppColors.success.withAlpha(15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.people_outline_rounded,
                                          size: 56,
                                          color: AppColors.success.withAlpha(150),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      const Text(
                                        'No students yet',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Add students to this stop using\nthe button above',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textMuted,
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
                                    final colorPair = AppColors.avatarColorPairs[
                                        index % AppColors.avatarColorPairs.length];

                                    return Consumer<StudentProvider>(
                                      builder: (context, studentProvider, _) {
                                        return StudentTile(
                                          studentName: student.fullName,
                                          guardianName: student.user?.name ?? '',
                                          phoneNumber: student.user?.phone,
                                          className: student.classGrade?.classname,
                                          imageUrl: student.image,
                                          colorPair: colorPair,
                                          onTap: () {
                                            StudentDetailsDialog.show(
                                              context,
                                              student.id,
                                              initialStudent: student,
                                            );
                                          },
                                          onDeleteTap: () =>
                                              _confirmDeleteStudent(student),
                                          isDeleting:
                                              studentProvider.isDeleting &&
                                              studentProvider.deletingStudentId ==
                                                  student.id,
                                        );
                                      },
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
