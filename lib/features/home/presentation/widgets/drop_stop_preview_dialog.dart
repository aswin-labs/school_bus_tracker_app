import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:school_bus_tracker/features/tracking/data/models/stop_model.dart';
import 'package:school_bus_tracker/features/tracking/data/services/stop_services.dart';
import 'package:school_bus_tracker/features/tracking/presentation/provider/stop_management_provider.dart';
import 'package:school_bus_tracker/routes/router_constants.dart';

class DropStopsPreviewDialog extends StatefulWidget {
  final int pickupRouteId;
  final int dropRouteId;

  const DropStopsPreviewDialog({
    super.key,
    required this.pickupRouteId,
    required this.dropRouteId,
  });

  @override
  State<DropStopsPreviewDialog> createState() => _DropStopsPreviewDialogState();
}

class _DropStopsPreviewDialogState extends State<DropStopsPreviewDialog> {
  List<StopModel> reversedStops = [];
  bool isLoading = true;
  bool isSubmitting = false;
  bool isReorderMode = false;

  @override
  void initState() {
    super.initState();
    _loadStops();
  }

  Future<void> _loadStops() async {
    try {
      final response = await StopServices().fetchStops(
        routeId: widget.pickupRouteId,
      );

      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? [];

        final stops = data.map((e) => StopModel.fromJson(e)).toList()
          ..sort((a, b) => (a.priority ?? 0).compareTo(b.priority ?? 0));

        setState(() {
          reversedStops = stops.reversed.toList();
        });
      }
    } catch (_) {}

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _confirm() async {
    setState(() => isSubmitting = true);

    final success = await context
        .read<StopManagementProvider>()
        .createDropStops(
          dropRouteId: widget.dropRouteId,
          pickupRouteId: widget.pickupRouteId,
        );

    if (!mounted) return;

    Navigator.pop(context);

    if (success) {
      context.goNamed(
        RouterConstants.trackingScreen,
        extra: widget.dropRouteId,
      );
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = reversedStops.removeAt(oldIndex);
      reversedStops.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        constraints: BoxConstraints(maxHeight: height * 0.7, maxWidth: 440),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(18),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── HEADER ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(30),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isReorderMode
                              ? Icons.drag_handle_rounded
                              : Icons.swap_vert_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'DROP STOPS PREVIEW',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withAlpha(200),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isReorderMode ? 'Rearrange Order' : 'Confirm Stop Order',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),

            // ── INFO BANNER ─────────────────────────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
              decoration: BoxDecoration(
                color: isReorderMode
                    ? const Color(0xFFF59E0B).withAlpha(12)
                    : const Color(0xFF3B82F6).withAlpha(12),
                border: Border(
                  bottom: BorderSide(color: const Color(0xFFE2E8F0), width: 1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isReorderMode
                          ? const Color(0xFFF59E0B).withAlpha(30)
                          : const Color(0xFF3B82F6).withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isReorderMode
                          ? Icons.touch_app_rounded
                          : Icons.info_outline_rounded,
                      size: 16,
                      color: isReorderMode
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFF3B82F6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isReorderMode
                          ? 'Drag and drop stops to reorder'
                          : 'Stops will be created in reverse order of pickup route',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── STOPS COUNT HEADER ──────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
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
                    'Drop Stops Order',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                      letterSpacing: 0.2,
                    ),
                  ),
                  const Spacer(),
                  // Rearrange button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isReorderMode = !isReorderMode;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isReorderMode
                            ? const Color(0xFFF59E0B).withAlpha(20)
                            : const Color(0xFF3B82F6).withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isReorderMode
                              ? const Color(0xFFF59E0B).withAlpha(60)
                              : const Color(0xFF3B82F6).withAlpha(60),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isReorderMode
                                ? Icons.check_rounded
                                : Icons.swap_vert_rounded,
                            size: 14,
                            color: isReorderMode
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFF3B82F6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isReorderMode ? 'Done' : 'Rearrange',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: isReorderMode
                                  ? const Color(0xFFF59E0B)
                                  : const Color(0xFF3B82F6),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── STOPS LIST ──────────────────────────────────────
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF3B82F6),
                      ),
                    )
                  : reversedStops.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.route_outlined,
                            size: 48,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No stops found',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : isReorderMode
                  ? ReorderableListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: reversedStops.length,
                      onReorder: _onReorder,
                      proxyDecorator: (child, index, animation) {
                        return AnimatedBuilder(
                          animation: animation,
                          builder: (context, child) {
                            return Material(
                              elevation: 8,
                              borderRadius: BorderRadius.circular(14),
                              child: child,
                            );
                          },
                          child: child,
                        );
                      },
                      itemBuilder: (context, index) {
                        final stop = reversedStops[index];
                        return _StopCard(
                          key: ValueKey(stop.id),
                          stop: stop,
                          index: index,
                          isReorderMode: true,
                        );
                      },
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: reversedStops.length,
                      itemBuilder: (context, index) {
                        final stop = reversedStops[index];
                        return _StopCard(
                          key: ValueKey(stop.id),
                          stop: stop,
                          index: index,
                          isReorderMode: false,
                        );
                      },
                    ),
            ),

            // ── FOOTER BUTTONS ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isSubmitting
                          ? null
                          : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF64748B),
                        side: BorderSide(
                          color: const Color(0xFFE2E8F0),
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Confirm button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isSubmitting || isReorderMode
                          ? null
                          : _confirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isSubmitting
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
                              children: const [
                                Icon(Icons.check_circle_rounded, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Confirm',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
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
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// STOP CARD WIDGET
// ══════════════════════════════════════════════════════════════════

class _StopCard extends StatelessWidget {
  final StopModel stop;
  final int index;
  final bool isReorderMode;

  const _StopCard({
    super.key,
    required this.stop,
    required this.index,
    required this.isReorderMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isReorderMode
            ? const Color(0xFFFEF3C7)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isReorderMode
              ? const Color(0xFFF59E0B).withAlpha(80)
              : const Color(0xFFE2E8F0),
          width: isReorderMode ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Number badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isReorderMode
                    ? [const Color(0xFFF59E0B), const Color(0xFFF97316)]
                    : [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Stop info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stop.stopName,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                    letterSpacing: 0.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.people_alt_rounded,
                      size: 12,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${stop.students?.length ?? 0} students',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Drag handle (only in reorder mode)
          if (isReorderMode)
            Icon(
              Icons.drag_indicator_rounded,
              color: const Color(0xFFF59E0B),
              size: 24,
            ),
        ],
      ),
    );
  }
}
