import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_bus_tracker/core/theme/app_colors.dart';
import 'package:school_bus_tracker/core/utils/snackbar_helper.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/provider/stops_provider.dart';

class ArrivedStudentDialog extends StatefulWidget {
  final int stopId;
  final int routeId;
  final bool forPicking;

  const ArrivedStudentDialog({
    super.key,
    required this.stopId,
    required this.routeId,
    required this.forPicking,
  });

  @override
  State<ArrivedStudentDialog> createState() => _ArrivedStudentDialogState();
}

class _ArrivedStudentDialogState extends State<ArrivedStudentDialog> {
  final Set<int> _absentStudentIds = {};
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<StopsProvider>();
    provider.clearSelection();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final error = await provider.fetchSingleStop(
        stopId: widget.stopId,
        routeId: widget.routeId,
      );
      if (!mounted || error == null) return;
      SnackbarHelper.showError(
        context,
        message: error,
      );
    });
  }

  void _initializeSelection(StopsProvider provider) {
    if (_initialized || provider.students.isEmpty) return;

    for (var student in provider.students) {
      if (!provider.selectedStudentIds.contains(student.id)) {
        provider.toggleStudentSelection(student.id);
      }
    }

    _initialized = true;
  }

  void _toggleAbsent(int studentId) {
    final provider = context.read<StopsProvider>();

    setState(() {
      if (_absentStudentIds.contains(studentId)) {
        _absentStudentIds.remove(studentId);
        if (!provider.selectedStudentIds.contains(studentId)) {
          provider.toggleStudentSelection(studentId);
        }
      } else {
        _absentStudentIds.add(studentId);
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
        ? AppColors.pickupColor
        : AppColors.dropColor;
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
          color: AppColors.surface,
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
                border: const Border(
                  bottom: BorderSide(color: AppColors.divider, width: 1),
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
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── SUMMARY BAR ─────────────────────────────────────
            Consumer<StopsProvider>(
              builder: (context, provider, _) {
                final totalCount = provider.students.length;
                final presentCount = totalCount - _absentStudentIds.length;
                final absentCount = _absentStudentIds.length;

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.divider,
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
                        color: AppColors.error,
                      ),
                    ],
                  ),
                );
              },
            ),

            // ── STUDENT LIST ────────────────────────────────────
            Expanded(
              child: Consumer<StopsProvider>(
                builder: (context, provider, _) {
                  if (provider.isDetailsLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

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
                            color: AppColors.textDisabled,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No students at this stop',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final avatarColors = AppColors.avatarColorPairs;

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    itemCount: provider.students.length,
                    itemBuilder: (context, index) {
                      final student = provider.students[index];
                      final isAbsent = _absentStudentIds.contains(student.id);
                      final colorPair =
                          avatarColors[index % avatarColors.length];

                      final initials = student.fullName
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
                                ? AppColors.error.withAlpha(15)
                                : actionColor.withAlpha(12),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isAbsent
                                  ? AppColors.error.withAlpha(80)
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
                                            ? AppColors.textDisabled
                                            : AppColors.textPrimary,
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
                                          color: AppColors.textDisabled,
                                        ),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          child: Text(
                                            student.user?.name ??
                                                'Not mentioned',
                                            style: const TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.textSecondary,
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
                                      ? AppColors.error
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
              child: Consumer<StopsProvider>(
                builder: (context, provider, _) {
                  final totalCount = provider.students.length;
                  final presentCount = totalCount - _absentStudentIds.length;

                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: provider.isSubmitting
                          ? null
                          : () async {
                              final error = await provider
                                  .updateStopAndStudent(
                                    stopId: widget.stopId,
                                  );
                              if (!context.mounted) return;
                              if (error == null) {
                                SnackbarHelper.showSuccess(
                                  context,
                                  message: 'Attendance submitted successfully!',
                                );
                                Navigator.pop(context);
                              } else {
                                SnackbarHelper.showError(
                                  context,
                                  message: error,
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: actionColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.border,
                        disabledForegroundColor: AppColors.textDisabled,
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
