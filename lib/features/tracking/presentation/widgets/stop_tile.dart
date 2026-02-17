import 'package:flutter/material.dart';

class StopTile extends StatelessWidget {
  final String stopName;
  final int studentsCount;
  final String time;
  final VoidCallback? onTap;
  final bool isActive;
  final bool isCompleted;

  const StopTile({
    super.key,
    required this.stopName,
    required this.studentsCount,
    required this.time,
    this.onTap,
    this.isActive = false,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = isActive
        ? const Color(0xFF00D9A3)
        : isCompleted
        ? const Color(0xFF94A3B8)
        : const Color(0xFF6366F1);

    return Padding(
      padding: EdgeInsets.only(bottom: isActive ? 10 : 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isActive ? 20 : 16),
            border: Border.all(
              color: accentColor.withAlpha(isActive ? 80 : 40),
              width: isActive ? 2 : 1,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: accentColor.withAlpha(25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: Colors.black.withAlpha(6),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withAlpha(5),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header strip (only for active)
              if (isActive)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accentColor.withAlpha(30),
                        accentColor.withAlpha(15),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withAlpha(120),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        'NEXT STOP',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),

              // Main row
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isActive ? 16 : 14,
                  vertical: isActive ? 14 : 11,
                ),
                child: Row(
                  children: [
                    // Left icon
                    Container(
                      width: isActive ? 46 : 38,
                      height: isActive ? 46 : 38,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            accentColor.withAlpha(40),
                            accentColor.withAlpha(20),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(isActive ? 14 : 11),
                      ),
                      child: Icon(
                        isCompleted
                            ? Icons.check_circle_outline_rounded
                            : Icons.location_on_rounded,
                        size: isActive ? 22 : 19,
                        color: accentColor,
                      ),
                    ),

                    SizedBox(width: isActive ? 14 : 12),

                    // Text content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stopName,
                            style: TextStyle(
                              fontSize: isActive ? 14.5 : 13.5,
                              fontWeight: FontWeight.w600,
                              color: isCompleted
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF0F172A),
                              letterSpacing: 0.1,
                            ),
                          ),
                          SizedBox(height: isActive ? 6 : 5),
                          Row(
                            children: [
                              // Students badge
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isActive ? 8 : 7,
                                  vertical: isActive ? 4 : 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6366F1).withAlpha(15),
                                  borderRadius: BorderRadius.circular(7),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF6366F1,
                                    ).withAlpha(35),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.people_alt_rounded,
                                      size: isActive ? 12 : 11,
                                      color: const Color(0xFF6366F1),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$studentsCount',
                                      style: TextStyle(
                                        fontSize: isActive ? 11.5 : 10.5,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF6366F1),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(width: isActive ? 8 : 6),

                              // Time badge
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isActive ? 8 : 7,
                                  vertical: isActive ? 4 : 3,
                                ),
                                decoration: BoxDecoration(
                                  color: accentColor.withAlpha(15),
                                  borderRadius: BorderRadius.circular(7),
                                  border: Border.all(
                                    color: accentColor.withAlpha(35),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.schedule_rounded,
                                      size: isActive ? 12 : 11,
                                      color: accentColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      time,
                                      style: TextStyle(
                                        fontSize: isActive ? 11.5 : 10.5,
                                        fontWeight: FontWeight.w600,
                                        color: accentColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: isActive ? 10 : 8),

                    // Right arrow
                    Container(
                      width: isActive ? 34 : 30,
                      height: isActive ? 34 : 30,
                      decoration: BoxDecoration(
                        color: accentColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(isActive ? 11 : 9),
                        border: Border.all(
                          color: accentColor.withAlpha(40),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: isActive ? 20 : 18,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
