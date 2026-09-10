import 'package:flutter/material.dart';
import 'package:school_bus_tracker/core/theme/app_colors.dart';

class StopTile extends StatelessWidget {
  final String stopName;
  final int priority;
  final int studentsCount;
  final bool isCompleted;
  final DateTime? arrivedAt;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool isDeleting;

  const StopTile({
    super.key,
    required this.stopName,
    required this.priority,
    required this.studentsCount,
    this.isCompleted = false,
    this.arrivedAt,
    this.onTap,
    this.onDelete,
    this.isDeleting = false,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = isCompleted ? AppColors.success : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accentColor.withAlpha(40), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(5),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            children: [
              // Priority / Check
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? accentColor.withAlpha(25)
                      : (priority == 0
                          ? AppColors.borderLight
                          : accentColor.withAlpha(20)),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: isCompleted
                        ? accentColor.withAlpha(50)
                        : (priority == 0
                            ? AppColors.textDisabled
                            : accentColor.withAlpha(35)),
                  ),
                ),
                child: Center(
                  child: isCompleted
                      ? Icon(
                          Icons.check_circle_rounded,
                          size: 20,
                          color: accentColor,
                        )
                      : (priority == 0
                          ? const Icon(
                              Icons.remove_rounded,
                              size: 17,
                              color: AppColors.textSecondary,
                            )
                          : Text(
                              '$priority',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: accentColor,
                              ),
                            )),
                ),
              ),

              const SizedBox(width: 12),

              // Stop name + students
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            stopName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ),
                        if (isCompleted) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withAlpha(15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppColors.success.withAlpha(40),
                              ),
                            ),
                            child: const Text(
                              'Arrived',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                          if (arrivedAt != null) ...[
                            const SizedBox(width: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withAlpha(10),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppColors.success.withAlpha(30),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 9,
                                    color: AppColors.success.withAlpha(180),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    _formatTime(arrivedAt!),
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.success.withAlpha(180),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ] else if (priority == 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.cardBg,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppColors.border,
                              ),
                            ),
                            child: const Text(
                              'Priority not set',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),

                    // Students badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withAlpha(15),
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: accentColor.withAlpha(35)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.people_alt_rounded,
                            size: 11,
                            color: accentColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$studentsCount',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: accentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (onDelete != null) ...[
                const SizedBox(width: 6),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: isDeleting ? null : onDelete,
                    borderRadius: BorderRadius.circular(9),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.error.withAlpha(15),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: AppColors.error.withAlpha(40),
                        ),
                      ),
                      child: isDeleting
                          ? const Center(
                              child: SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.error,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.delete_outline_rounded,
                              size: 16,
                              color: AppColors.error,
                            ),
                    ),
                  ),
                ),
              ],

              const SizedBox(width: 6),

              // Arrow
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: accentColor.withAlpha(40)),
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: accentColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime utcTime) {
    final local = utcTime.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
