import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_bus_tracker/core/theme/app_colors.dart';
import 'package:school_bus_tracker/core/utils/snackbar_helper.dart';
import 'package:school_bus_tracker/features/home/presentation/provider/route_provider.dart';
import 'package:school_bus_tracker/features/live_tracking/data/models/stop_model.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/provider/stops_provider.dart';

class AssignPairStopsDialog extends StatefulWidget {
  final int routeId;
  final int currentStopsCount;

  const AssignPairStopsDialog({
    super.key,
    required this.routeId,
    this.currentStopsCount = 0,
  });

  @override
  State<AssignPairStopsDialog> createState() => _AssignPairStopsDialogState();
}

class _AssignPairStopsDialogState extends State<AssignPairStopsDialog> {
  final Set<int> _selectedStopIds = {};
  final Map<int, TextEditingController> _priorityControllers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeStops();
    });
  }

  void _initializeStops() {
    final provider = context.read<StopsProvider>();
    final unassigned = provider.unassignedPairStops;

    _priorityControllers.clear();
    _selectedStopIds.clear();

    for (int i = 0; i < unassigned.length; i++) {
      final stop = unassigned[i];
      final defaultPriority = widget.currentStopsCount + i + 1;
      _priorityControllers[stop.id] = TextEditingController(
        text: defaultPriority.toString(),
      );
      // Select all by default
      _selectedStopIds.add(stop.id);
    }
    setState(() {});
  }

  @override
  void dispose() {
    for (final controller in _priorityControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _toggleSelectAll(List<StopModel> unassigned) {
    setState(() {
      if (_selectedStopIds.length == unassigned.length) {
        _selectedStopIds.clear();
      } else {
        _selectedStopIds.clear();
        for (int i = 0; i < unassigned.length; i++) {
          final stop = unassigned[i];
          _selectedStopIds.add(stop.id);
          if (!_priorityControllers.containsKey(stop.id)) {
            _priorityControllers[stop.id] = TextEditingController(
              text: (widget.currentStopsCount + i + 1).toString(),
            );
          }
        }
      }
    });
  }

  Future<void> _handleSubmit(RouteProvider routeProvider) async {
    if (_selectedStopIds.isEmpty) {
      SnackbarHelper.showError(
        context,
        message: 'Please select at least one stop to add',
      );
      return;
    }

    final List<Map<String, dynamic>> payload = [];

    for (final stopId in _selectedStopIds) {
      final controller = _priorityControllers[stopId];
      final priorityText = controller?.text.trim() ?? '';
      final priority = int.tryParse(priorityText);

      if (priority == null || priority < 1) {
        SnackbarHelper.showError(
          context,
          message:
              'Please provide a valid priority number for all selected stops',
        );
        return;
      }

      payload.add({'stop_id': stopId, 'priority': priority});
    }

    final provider = context.read<StopsProvider>();
    final error = await provider.assignStopsFromPairRoute(
      routeId: widget.routeId,
      stops: payload,
    );
    await routeProvider.fetchDriverRoutes();

    if (!mounted) return;

    if (error == null) {
      SnackbarHelper.showSuccess(
        context,
        message: '${payload.length} stop(s) added successfully',
      );
      Navigator.pop(context, true);
    } else {
      SnackbarHelper.showError(context, message: error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 36),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        clipBehavior: Clip.antiAlias,
        elevation: 16,
        shadowColor: Colors.black.withAlpha(60),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 460, maxHeight: 620),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── HEADER ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(30),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Column(
                      children: [
                        Text(
                          'PAIR ROUTE STOPS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withAlpha(200),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Import Unassigned Stops',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const SizedBox(width: 36),
                  ],
                ),
              ),

              // ── BODY ─────────────────────────────────────────────
              Expanded(
                child: Consumer<StopsProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoadingPairStops) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }

                    final unassigned = provider.unassignedPairStops;

                    if (unassigned.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_circle_outline_rounded,
                                  size: 48,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No Unassigned Stops',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'All stops from the paired route are already assigned to this route.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final allSelected =
                        _selectedStopIds.length == unassigned.length;

                    return Column(
                      children: [
                        // Select all bar
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () => _toggleSelectAll(unassigned),
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: Checkbox(
                                          value: allSelected,
                                          activeColor: AppColors.primary,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          onChanged: (_) =>
                                              _toggleSelectAll(unassigned),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        allSelected
                                            ? 'Deselect All'
                                            : 'Select All (${unassigned.length})',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Spacer(),
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
                                  '${_selectedStopIds.length} Selected',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          height: 12,
                          thickness: 1,
                          color: AppColors.divider,
                        ),

                        // Stops list
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                            itemCount: unassigned.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final stop = unassigned[index];
                              final isSelected = _selectedStopIds.contains(
                                stop.id,
                              );

                              if (!_priorityControllers.containsKey(stop.id)) {
                                _priorityControllers[stop
                                    .id] = TextEditingController(
                                  text: (widget.currentStopsCount + index + 1)
                                      .toString(),
                                );
                              }

                              final priorityCtrl =
                                  _priorityControllers[stop.id]!;

                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary.withAlpha(10)
                                      : AppColors.cardBg,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary.withAlpha(80)
                                        : AppColors.border,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Checkbox(
                                        value: isSelected,
                                        activeColor: AppColors.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        onChanged: (checked) {
                                          setState(() {
                                            if (checked == true) {
                                              _selectedStopIds.add(stop.id);
                                            } else {
                                              _selectedStopIds.remove(stop.id);
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            stop.stopName,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: isSelected
                                                  ? AppColors.textPrimary
                                                  : AppColors.textSecondary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 2,
                                            ),
                                            child: Text(
                                              '${stop.latitude.toStringAsFixed(4)}, ${stop.longitude.toStringAsFixed(4)}',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: AppColors.textMuted,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Priority Input
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        const Text(
                                          'Priority',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Container(
                                          width: 52,
                                          height: 34,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: AppColors.surface,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: isSelected
                                                  ? AppColors.primary.withAlpha(120)
                                                  : AppColors.border,
                                              width: 1,
                                            ),
                                          ),
                                          child: TextField(
                                            controller: priorityCtrl,
                                            keyboardType: TextInputType.number,
                                            textAlign: TextAlign.center,
                                            enabled: isSelected,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: isSelected
                                                  ? AppColors.textPrimary
                                                  : AppColors.textDisabled,
                                            ),
                                            decoration: const InputDecoration(
                                              isDense: true,
                                              border: InputBorder.none,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    vertical: 6,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // ── FOOTER ACTIONS ───────────────────────────────────
              Consumer2<StopsProvider, RouteProvider>(
                builder: (context, stopsProvider, routeProvider, _) {
                  if (stopsProvider.unassignedPairStops.isEmpty &&
                      !stopsProvider.isLoadingPairStops) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Close'),
                        ),
                      ),
                    );
                  }

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      border: Border(
                        top: BorderSide(color: AppColors.divider, width: 1.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: stopsProvider.isAssigningPairStops
                                ? null
                                : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                              side: const BorderSide(color: AppColors.border),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed:
                                stopsProvider.isAssigningPairStops ||
                                    _selectedStopIds.isEmpty
                                ? null
                                : () => _handleSubmit(routeProvider),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: AppColors.border,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: stopsProvider.isAssigningPairStops
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.add_link_rounded,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Add ${_selectedStopIds.length} Stops',
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
