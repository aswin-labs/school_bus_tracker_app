import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_bus_tracker/features/tracking/presentation/provider/stop_management_provider.dart';

class ArrivedStudentDialog extends StatefulWidget {
  final int stopId;
  final bool forPicking;

  const ArrivedStudentDialog({
    super.key,
    required this.stopId,
    required this.forPicking,
  });

  @override
  State<ArrivedStudentDialog> createState() => _ArrivedStudentDialogState();
}

class _ArrivedStudentDialogState extends State<ArrivedStudentDialog> {
  // Track absent students
  Set<int> absentStudentIds = {};
  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    final provider = context.read<StopManagementProvider>();
    provider.clearSelection();
    // provider.fetchSingleStop(widget.stopId);
  }

  void _initializeSelection(StopManagementProvider provider) {
    if (_initialized || provider.students.isEmpty) return;

    // Auto-select all students on first load
    for (var student in provider.students) {
      if (!provider.selectedStudentIds.contains(student.id)) {
        provider.toggleStudentSelection(student.id);
      }
    }

    _initialized = true;
  }

  void _toggleAbsent(int studentId) {
    final provider = context.read<StopManagementProvider>();

    setState(() {
      if (absentStudentIds.contains(studentId)) {
        absentStudentIds.remove(studentId);
        // Add back to selection
        if (!provider.selectedStudentIds.contains(studentId)) {
          provider.toggleStudentSelection(studentId);
        }
      } else {
        absentStudentIds.add(studentId);
        // Remove from selection
        if (provider.selectedStudentIds.contains(studentId)) {
          provider.toggleStudentSelection(studentId);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final actionColor = widget.forPicking
        ? const Color(0xFF10B981)
        : const Color(0xFF3B82F6);
    final actionLabel = widget.forPicking ? 'PICKUP' : 'DROP';
    final actionIcon = widget.forPicking
        ? Icons.login_rounded
        : Icons.logout_rounded;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        constraints: BoxConstraints(maxHeight: height * 0.75, maxWidth: 440),
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
                        'MARK ATTENDANCE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withAlpha(200),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(actionIcon, color: Colors.white, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            actionLabel,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
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
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
              decoration: BoxDecoration(
                color: actionColor.withAlpha(15),
                border: Border(
                  bottom: BorderSide(color: const Color(0xFFE2E8F0), width: 1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: actionColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: actionColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'All students marked for $actionLabel. Tap any to mark absent.',
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

            // ── SUMMARY BAR ─────────────────────────────────────
            Consumer<StopManagementProvider>(
              builder: (context, provider, _) {
                final totalCount = provider.students.length;
                final presentCount = totalCount - absentStudentIds.length;
                final absentCount = absentStudentIds.length;

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SummaryPill(
                        icon: actionIcon,
                        label: actionLabel,
                        count: presentCount,
                        color: actionColor,
                      ),
                      const SizedBox(width: 12),
                      _SummaryPill(
                        icon: Icons.cancel_outlined,
                        label: 'Absent',
                        count: absentCount,
                        color: const Color(0xFFEF4444),
                      ),
                    ],
                  ),
                );
              },
            ),

            // ── STUDENT LIST ────────────────────────────────────
            Expanded(
              child: Consumer<StopManagementProvider>(
                builder: (context, provider, _) {
                  // Initialize selection after students are loaded
                  if (provider.students.isNotEmpty && !_initialized) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _initializeSelection(provider);
                    });
                  }

                  if (provider.students.isEmpty) {
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
                            'No students at this stop',
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

                  const avatarColors = [
                    [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
                    [Color(0xFFF59E0B), Color(0xFFF97316)],
                    [Color(0xFF10B981), Color(0xFF059669)],
                    [Color(0xFFEC4899), Color(0xFFEF4444)],
                  ];

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    itemCount: provider.students.length,
                    itemBuilder: (context, index) {
                      final student = provider.students[index];
                      final isAbsent = absentStudentIds.contains(student.id);
                      final colorPair =
                          avatarColors[index % avatarColors.length];

                      final initials = (student.fullName)
                          .trim()
                          .split(' ')
                          .take(2)
                          .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
                          .join();

                      return GestureDetector(
                        onTap: () => _toggleAbsent(student.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isAbsent
                                ? const Color(0xFFEF4444).withAlpha(15)
                                : actionColor.withAlpha(12),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isAbsent
                                  ? const Color(0xFFEF4444).withAlpha(80)
                                  : actionColor.withAlpha(60),
                              width: isAbsent ? 2 : 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Avatar
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: colorPair,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  // opacity: isAbsent ? 0.5 : 1.0,
                                ),
                                child: Center(
                                  child: Text(
                                    initials.isEmpty ? '?' : initials,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              // Name + Guardian
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      student.fullName,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: isAbsent
                                            ? Colors.grey[500]
                                            : const Color(0xFF0F172A),
                                        letterSpacing: 0.1,
                                        decoration: isAbsent
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person_outline_rounded,
                                          size: 13,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          child: Text(
                                            student.user?.name ??
                                                'Not mentioned',
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[500],
                                              letterSpacing: 0.1,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Status badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isAbsent
                                      ? const Color(0xFFEF4444)
                                      : actionColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isAbsent
                                          ? Icons.cancel_rounded
                                          : actionIcon,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      isAbsent ? 'Absent' : actionLabel,
                                      style: const TextStyle(
                                        fontSize: 12,
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
                  );
                },
              ),
            ),

            // ── FOOTER BUTTON ───────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Consumer<StopManagementProvider>(
                builder: (context, provider, _) {
                  final totalCount = provider.students.length;
                  final presentCount = totalCount - absentStudentIds.length;

                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: provider.isSubmitting
                          ? null
                          : () async {
                              final success = await provider
                                  .updateStopAndStudent(
                                    stopId: widget.stopId,
                                    forPicking: widget.forPicking,
                                  );
                              if (!context.mounted) return;
                              if (success && context.mounted) {
                                Navigator.pop(context);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: actionColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        disabledForegroundColor: Colors.grey[500],
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: provider.isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  size: 22,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Submit $presentCount $actionLabel',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.4,
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
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SUPPORTING WIDGETS
// ═══════════════════════════════════════════════════════════════

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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(60), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            '$count $label',
            style: TextStyle(
              fontSize: 12.5,
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
