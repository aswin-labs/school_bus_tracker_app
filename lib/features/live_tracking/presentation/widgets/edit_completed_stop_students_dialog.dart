import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_bus_tracker/core/utils/snackbar_helper.dart';
import 'package:school_bus_tracker/features/live_tracking/data/models/stop_live_status_model.dart';
import 'package:school_bus_tracker/features/live_tracking/data/models/stop_model.dart';
import 'package:school_bus_tracker/features/live_tracking/data/models/student_model.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/provider/stops_provider.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/provider/student_provider.dart';

class EditCompletedStopStudentsDialog extends StatefulWidget {
  final StopModel stop;
  final int routeId;
  final bool isPickup;

  const EditCompletedStopStudentsDialog({
    super.key,
    required this.stop,
    required this.routeId,
    required this.isPickup,
  });

  @override
  State<EditCompletedStopStudentsDialog> createState() =>
      _EditCompletedStopStudentsDialogState();
}

class _EditCompletedStopStudentsDialogState
    extends State<EditCompletedStopStudentsDialog> {
  int? _loadingStudentId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StopsProvider>().fetchSingleStop(
        stopId: widget.stop.id,
        routeId: widget.routeId,
      );
    });
  }

  Future<void> _toggleStudentStatus({
    required int studentId,
    required int? studentStopId,
    required bool isCurrentlyAbsent,
  }) async {
    if (_loadingStudentId != null) return;

    final targetStudentStopId = studentStopId ?? studentId;
    final newStatus = isCurrentlyAbsent
        ? (widget.isPickup ? 'picked' : 'dropped')
        : (widget.isPickup ? 'not_picked' : 'not_dropped');

    setState(() {
      _loadingStudentId = studentId;
    });

    final studentProvider = context.read<StudentProvider>();
    final stopsProvider = context.read<StopsProvider>();

    final success = await studentProvider.editStudentStopStatus(
      studentStopId: targetStudentStopId,
      studentId: studentId.toString(),
      status: newStatus,
    );

    if (mounted) {
      setState(() {
        _loadingStudentId = null;
      });

      if (success) {
        // Refresh single stop and full stops list
        await stopsProvider.fetchSingleStop(
          stopId: widget.stop.id,
          routeId: widget.routeId,
        );
        if (mounted) {
          await stopsProvider.fetchStopsByRouteId(widget.routeId);
        }
      } else {
        SnackbarHelper.showError(
          context,
          message: 'Failed to update student status',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final actionColor = widget.isPickup
        ? const Color(0xFF10B981)
        : const Color(0xFF3B82F6);
    final presentLabel = widget.isPickup ? 'Picked' : 'Dropped';
    final absentLabel = widget.isPickup ? 'Not Picked' : 'Not Dropped';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        constraints: BoxConstraints(maxHeight: height * 0.78, maxWidth: 440),
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
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [actionColor, actionColor.withAlpha(200)],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
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
                        'EDIT ATTENDANCE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withAlpha(200),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Consumer<StopsProvider>(
                        builder: (context, provider, _) {
                          final name =
                              provider.singleStop?.stopName ??
                              widget.stop.stopName;
                          return Text(
                            name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),
                    ],
                  ),
                  const Spacer(),
                  const SizedBox(width: 36),
                ],
              ),
            ),

            // ── INFO BANNER ─────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              decoration: BoxDecoration(
                color: actionColor.withAlpha(15),
                border: const Border(
                  bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: actionColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(
                      Icons.touch_app_rounded,
                      size: 17,
                      color: actionColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tap on a student to switch between $presentLabel and $absentLabel.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── SUMMARY & LIST ──────────────────────────────────
            Expanded(
              child: Consumer<StopsProvider>(
                builder: (context, stopsProvider, _) {
                  if (stopsProvider.isDetailsLoading &&
                      stopsProvider.singleStop == null) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF3B82F6),
                      ),
                    );
                  }

                  final activeStop = stopsProvider.singleStop ?? widget.stop;

                  // Build status map from live statuses
                  final Map<int, StudentsStopStatus> statusMap = {};
                  if (activeStop.stopLiveStatuses != null &&
                      activeStop.stopLiveStatuses!.isNotEmpty) {
                    for (final liveStatus in activeStop.stopLiveStatuses!) {
                      if (liveStatus.studentsStopStatuses != null) {
                        for (final sss in liveStatus.studentsStopStatuses!) {
                          if (sss.studentId != null) {
                            statusMap[sss.studentId!] = sss;
                          } else if (sss.student?.id != null) {
                            statusMap[sss.student!.id] = sss;
                          }
                        }
                      }
                    }
                  }

                  // Determine full list of students
                  List<StudentModel> studentsList = [];
                  if (activeStop.students != null &&
                      activeStop.students!.isNotEmpty) {
                    studentsList = activeStop.students!;
                  } else if (statusMap.isNotEmpty) {
                    studentsList = statusMap.values
                        .where((s) => s.student != null)
                        .map((s) => s.student!)
                        .toList();
                  }

                  if (studentsList.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline_rounded,
                            size: 48,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No students found for this stop',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Count present vs absent
                  int absentCount = 0;
                  int presentCount = 0;

                  for (final student in studentsList) {
                    final sss = statusMap[student.id];
                    final st = sss?.status?.toLowerCase();
                    final isAb =
                        st == 'not_picked' ||
                        st == 'not_dropped' ||
                        st == 'absent';
                    if (isAb) {
                      absentCount++;
                    } else {
                      presentCount++;
                    }
                  }

                  const avatarColors = [
                    [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
                    [Color(0xFFF59E0B), Color(0xFFF97316)],
                    [Color(0xFF10B981), Color(0xFF059669)],
                    [Color(0xFFEC4899), Color(0xFFEF4444)],
                  ];

                  return Column(
                    children: [
                      // Summary bar
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xFFE2E8F0),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _SummaryPill(
                              icon: widget.isPickup
                                  ? Icons.login_rounded
                                  : Icons.logout_rounded,
                              label: presentLabel,
                              count: presentCount,
                              color: actionColor,
                            ),
                            const SizedBox(width: 12),
                            _SummaryPill(
                              icon: Icons.cancel_outlined,
                              label: absentLabel,
                              count: absentCount,
                              color: const Color(0xFFEF4444),
                            ),
                          ],
                        ),
                      ),

                      // Student list
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                          itemCount: studentsList.length,
                          itemBuilder: (context, index) {
                            final student = studentsList[index];
                            final sss = statusMap[student.id];
                            final statusStr = sss?.status?.toLowerCase();
                            final isAbsent =
                                statusStr == 'not_picked' ||
                                statusStr == 'not_dropped' ||
                                statusStr == 'absent';
                            final isItemLoading =
                                _loadingStudentId == student.id;

                            final colorPair =
                                avatarColors[index % avatarColors.length];

                            final initials = student.fullName
                                .trim()
                                .split(' ')
                                .take(2)
                                .map(
                                  (e) => e.isNotEmpty ? e[0].toUpperCase() : '',
                                )
                                .join();

                            return GestureDetector(
                              onTap: isItemLoading
                                  ? null
                                  : () => _toggleStudentStatus(
                                      studentId: student.id,
                                      studentStopId: sss?.id,
                                      isCurrentlyAbsent: isAbsent,
                                    ),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(13),
                                decoration: BoxDecoration(
                                  color: isAbsent
                                      ? const Color(0xFFEF4444).withAlpha(12)
                                      : actionColor.withAlpha(12),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isAbsent
                                        ? const Color(0xFFEF4444).withAlpha(70)
                                        : actionColor.withAlpha(60),
                                    width: isAbsent ? 2 : 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // Avatar
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: colorPair,
                                        ),
                                        borderRadius: BorderRadius.circular(13),
                                      ),
                                      child: Center(
                                        child: Text(
                                          initials.isEmpty ? '?' : initials,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Student info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            student.fullName,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: isAbsent
                                                  ? Colors.grey[600]
                                                  : const Color(0xFF0F172A),
                                              decoration: isAbsent
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 3),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.person_outline_rounded,
                                                size: 12,
                                                color: Colors.grey[400],
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  student.user?.name ??
                                                      'Not mentioned',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.grey[500],
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),

                                    // Action / Status toggle badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 7,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isAbsent
                                            ? const Color(0xFFEF4444)
                                            : actionColor,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                (isAbsent
                                                        ? const Color(
                                                            0xFFEF4444,
                                                          )
                                                        : actionColor)
                                                    .withAlpha(40),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: isItemLoading
                                          ? const SizedBox(
                                              width: 14,
                                              height: 14,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  isAbsent
                                                      ? Icons.cancel_rounded
                                                      : Icons
                                                            .check_circle_rounded,
                                                  size: 14,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  isAbsent
                                                      ? absentLabel
                                                      : presentLabel,
                                                  style: const TextStyle(
                                                    fontSize: 11.5,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white,
                                                    letterSpacing: 0.3,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ],
                                ),
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

            // ── FOOTER BUTTON ───────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: actionColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const _SummaryPill({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(60), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            '$count $label',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
