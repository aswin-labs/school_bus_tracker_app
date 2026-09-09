import 'package:flutter/material.dart';

class StopTile extends StatelessWidget {
  final String stopName;
  final int priority;
  final int studentsCount;
  final bool isCompleted;
  final VoidCallback? onTap;

  const StopTile({
    super.key,
    required this.stopName,
    required this.priority,
    required this.studentsCount,
    this.isCompleted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = isCompleted
        ? const Color(0xFF10B981)
        : const Color(0xFF3B82F6);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
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
                          ? const Color(0xFFF1F5F9)
                          : accentColor.withAlpha(20)),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: isCompleted
                        ? accentColor.withAlpha(50)
                        : (priority == 0
                            ? const Color(0xFFCBD5E1)
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
                              color: Color(0xFF64748B),
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
                              color: Color(0xFF0F172A),
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
                              color: const Color(0xFF10B981).withAlpha(15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFF10B981).withAlpha(40),
                              ),
                            ),
                            child: const Text(
                              'Arrived',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ),
                        ] else if (priority == 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: const Text(
                              'Priority not set',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
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

              const SizedBox(width: 8),

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
}
