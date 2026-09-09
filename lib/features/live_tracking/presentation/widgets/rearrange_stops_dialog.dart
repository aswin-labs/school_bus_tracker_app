import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_bus_tracker/core/utils/snackbar_helper.dart';
import 'package:school_bus_tracker/features/live_tracking/data/models/stop_model.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/provider/stops_provider.dart';

class RearrangeStopsDialog extends StatefulWidget {
  final List<StopModel> stops;
  final int routeId;
  final bool isPickupRoute;

  const RearrangeStopsDialog({
    super.key,
    required this.stops,
    required this.routeId,
    required this.isPickupRoute,
  });

  @override
  State<RearrangeStopsDialog> createState() => _RearrangeStopsDialogState();
}

class _RearrangeStopsDialogState extends State<RearrangeStopsDialog> {
  late List<StopModel> _stops;

  @override
  void initState() {
    super.initState();

    _stops = List<StopModel>.from(widget.stops);

    final allHavePriority = _stops.every(
      (stop) =>
          stop.stopPriority != null &&
          stop.stopPriority!.isNotEmpty &&
          stop.stopPriority!.first.priority != null,
    );

    final allPrioritiesNull = _stops.every(
      (stop) =>
          stop.stopPriority == null ||
          stop.stopPriority!.isEmpty ||
          stop.stopPriority!.first.priority == null,
    );

    if (!widget.isPickupRoute && allPrioritiesNull) {
      _stops = _stops.reversed.toList();
      return;
    }

    if (!allHavePriority) return;

    _stops.sort(
      (a, b) => a.stopPriority!.first.priority!.compareTo(
        b.stopPriority!.first.priority!,
      ),
    );
  }

  Future<void> _submit() async {
    final stopPriorities = List.generate(
      _stops.length,
      (index) => {'stop_id': _stops[index].id, 'priority': index + 1},
    );

    final error = await context.read<StopsProvider>().rearrangeStopPriorities(
      routeId: widget.routeId,
      stopPriorities: stopPriorities,
    );

    if (!mounted) return;

    if (error != null) {
      SnackbarHelper.showError(context, message: error);
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<StopsProvider>().isRearranging;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Rearrange Stops',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Drag the stops to change their priority.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: ReorderableListView.builder(
                  shrinkWrap: true,
                  buildDefaultDragHandles: false,
                  itemCount: _stops.length,
                  // ignore: deprecated_member_use
                  onReorder: (oldIndex, newIndex) {
                    if (isLoading) return;

                    setState(() {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }

                      final stop = _stops.removeAt(oldIndex);
                      _stops.insert(newIndex, stop);
                    });
                  },
                  itemBuilder: (context, index) {
                    final stop = _stops[index];

                    return Container(
                      key: ValueKey(stop.id),
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 34,
                          height: 34,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withAlpha(20),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        title: Text(
                          stop.stopName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'Priority ${index + 1}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        trailing: ReorderableDragStartListener(
                          index: index,
                          child: const Icon(
                            Icons.drag_indicator,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // AddButton(onPressed: () {}, buttonText: "buttonText"),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFBFDBFE),
                    disabledForegroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Save Priorities',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
