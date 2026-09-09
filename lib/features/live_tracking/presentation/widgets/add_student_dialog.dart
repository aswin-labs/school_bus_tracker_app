import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_bus_tracker/core/theme/app_colors.dart';
import 'package:school_bus_tracker/core/utils/snackbar_helper.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/provider/stops_provider.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/provider/student_provider.dart';

class AddStudentDialog extends StatefulWidget {
  final int routeId;
  final int stopId;

  const AddStudentDialog({
    super.key,
    required this.routeId,
    required this.stopId,
  });

  @override
  State<AddStudentDialog> createState() => _AddStudentDialogState();
}

class _AddStudentDialogState extends State<AddStudentDialog> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final error = await context
          .read<StudentProvider>()
          .fetchStudentsByRouteId(routeId: widget.routeId);
      if (mounted && error != null) {
        SnackbarHelper.showError(context, message: error);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

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
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.only(
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
                        'ADD STUDENTS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withAlpha(200),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Select Students',
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

            // ── SELECTION COUNT ─────────────────────────────────
            Consumer<StudentProvider>(
              builder: (context, provider, _) {
                final availableStudents = provider.students;
                final selectedCount = provider.selectedStudentIds.length;
                final totalCount = availableStudents.length;

                return Container(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(15),
                    border: const Border(
                      bottom: BorderSide(
                        color: AppColors.divider,
                        width: 1,
                      ),
                    ),
                  ),
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
                      const SizedBox(width: 10),
                      const Text(
                        'Select students to add',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
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
                          '$selectedCount / $totalCount',
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
                );
              },
            ),

            // ── STUDENT LIST ────────────────────────────────────
            Expanded(
              child: Consumer<StudentProvider>(
                builder: (context, provider, _) {
                  final availableStudents = provider.students;

                  if (provider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (availableStudents.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            size: 48,
                            color: AppColors.success,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'All students added',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'No more students to add',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final avatarColors = AppColors.avatarColorPairs;

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    itemCount: availableStudents.length,
                    itemBuilder: (context, index) {
                      final student = availableStudents[index];
                      final isSelected = provider.selectedStudentIds.contains(
                        student.id,
                      );

                      final colorPair =
                          avatarColors[index % avatarColors.length];
                      const accentColor = AppColors.primary;

                      final initials = (student.fullName)
                          .trim()
                          .split(' ')
                          .take(2)
                          .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
                          .join();

                      return GestureDetector(
                        onTap: () {
                          provider.toggleStudentSelection(student.id);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? accentColor.withAlpha(15)
                                : AppColors.cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? accentColor.withAlpha(80)
                                  : AppColors.border,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: accentColor.withAlpha(15),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              // Avatar with gradient
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: colorPair,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
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

                              // Name + Guardian
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      student.fullName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? accentColor
                                            : AppColors.textPrimary,
                                        letterSpacing: 0.1,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person_outline_rounded,
                                          size: 12,
                                          color: AppColors.textDisabled,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            student.user?.name ??
                                                'Not mentioned',
                                            style: const TextStyle(
                                              fontSize: 12,
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

                              const SizedBox(width: 10),

                              // Custom Checkbox
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? accentColor
                                        : AppColors.border,
                                    width: 2,
                                  ),
                                  color: isSelected
                                      ? accentColor
                                      : Colors.transparent,
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      )
                                    : null,
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
              child: Consumer<StudentProvider>(
                builder: (context, provider, _) {
                  final selectedCount = provider.selectedStudentIds.length;
                  final isDisabled =
                      provider.isSubmitting || selectedCount == 0;

                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isDisabled
                          ? null
                          : () async {
                              final error = await provider
                                  .addSelectedStudentsToStop(widget.stopId);
                              if (!context.mounted) return;

                              if (error == null) {
                                SnackbarHelper.showSuccess(
                                  context,
                                  message: 'Student(s) added successfully',
                                );
                                await context
                                    .read<StopsProvider>()
                                    .fetchSingleStop(
                                      routeId: widget.routeId,
                                      stopId: widget.stopId,
                                    );
                                if (!context.mounted) return;
                                await context
                                    .read<StopsProvider>()
                                    .fetchStopsByRouteId(widget.routeId);

                                if (context.mounted) {
                                  Navigator.pop(context, true);
                                }
                              } else {
                                SnackbarHelper.showError(
                                  context,
                                  message: error,
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.border,
                        disabledForegroundColor: AppColors.textDisabled,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 15),
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
                                const Icon(Icons.add_circle_rounded, size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  selectedCount == 0
                                      ? 'Select students'
                                      : 'Add $selectedCount Student${selectedCount != 1 ? 's' : ''}',
                                  style: const TextStyle(
                                    fontSize: 14.5,
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
