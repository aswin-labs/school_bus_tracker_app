import 'package:flutter/material.dart';
import 'package:school_bus_tracker/core/extensions/context_extensions.dart';

class DriverRouteCard extends StatelessWidget {
  final String routeName;
  final String timeRange;
  final VoidCallback onButtonTap;
  final String buttonTitle;
  final bool isLive;
  final bool isPickup;

  const DriverRouteCard({
    super.key,
    required this.routeName,
    required this.timeRange,
    required this.onButtonTap,
    this.buttonTitle = 'Resume Trip',
    this.isLive = true,
    this.isPickup = true,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = isLive
        ? const Color.fromARGB(255, 82, 207, 101) // Modern vibrant teal/cyan
        : const Color(0xFF94A3B8);

    final statusColor = isPickup
        ? const Color(0xFF3B82F6)
        : const Color(0xFFEF4444);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.only(bottom: isLive ? 12 : 8),
      child: Container(
        decoration: BoxDecoration(
          color: context.theme.cardColor,
          borderRadius: BorderRadius.circular(isLive ? 20 : 16),
          border: Border.all(
            color: Color(0xFF3B82F6).withAlpha(isLive ? 80 : 50),
            width: isLive ? 2 : 1,
          ),
          boxShadow: isLive
              ? [
                  BoxShadow(
                    color: Color.fromARGB(255, 188, 211, 248).withAlpha(10),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withAlpha(8),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(5),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Compact header
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isLive ? 16 : 12,
                vertical: isLive ? 12 : 10,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF3B82F6).withAlpha(isLive ? 30 : 15),
                    Color(0xFF3B82F6).withAlpha(isLive ? 15 : 8),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isLive ? 18 : 14),
                  topRight: Radius.circular(isLive ? 18 : 14),
                ),
              ),
              child: Row(
                children: [
                  // Live pulse indicator
                  if (isLive)
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withAlpha(100),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Color(0xFF3B82F6),
                        shape: BoxShape.circle,
                      ),
                    ),
                  SizedBox(width: isLive ? 8 : 6),
                  Text(
                    isLive ? 'LIVE NOW' : 'Scheduled',
                    style: TextStyle(
                      fontSize: isLive ? 12.5 : 11.5,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                  // Status badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isLive ? 10 : 8,
                      vertical: isLive ? 5 : 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: statusColor.withAlpha(60),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPickup
                              ? Icons.north_east_rounded
                              : Icons.south_west_rounded,
                          size: isLive ? 13 : 12,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isPickup ? "Pickup" : "Drop",
                          style: TextStyle(
                            fontSize: isLive ? 11.5 : 10.5,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Compact content
            Padding(
              padding: EdgeInsets.all(isLive ? 16 : 12),
              child: Column(
                children: [
                  // Route info - more compact
                  Row(
                    children: [
                      // Smaller icon container
                      Container(
                        width: isLive ? 46 : 38,
                        height: isLive ? 46 : 38,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF2563EB).withAlpha(40),
                              Color(0xFF2563EB).withAlpha(20),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.route_rounded,
                          size: isLive ? 22 : 20,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                      SizedBox(width: isLive ? 12 : 10),
                      // Route name - inline, more compact
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Route',
                              style: context.text.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: context.theme.dividerColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: isLive ? 4 : 3),
                            Row(
                              children: [
                                Icon(
                                  Icons.home_rounded,
                                  size: isLive ? 15 : 14,
                                  color: context.theme.dividerColor,
                                ),
                                SizedBox(width: isLive ? 6 : 5),
                                Icon(
                                  Icons.arrow_forward,
                                  size: isLive ? 13 : 12,
                                  color: context.theme.dividerColor,
                                ),
                                SizedBox(width: isLive ? 6 : 5),
                                Expanded(
                                  child: Text(
                                    routeName,
                                    style: context.text.bodyMedium,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isLive ? 12 : 10),

                  // Time badge - inline and compact
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isLive ? 12 : 10,
                          vertical: isLive ? 8 : 6,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFF3B82F6).withAlpha(20),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Color(0xFF3B82F6).withAlpha(40),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: isLive ? 15 : 14,
                              color: Color(0xFF2563EB),
                            ),
                            SizedBox(width: isLive ? 8 : 6),
                            Text(
                              timeRange,
                              style: TextStyle(
                                fontSize: isLive ? 12.5 : 11.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2563EB),
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  if (isLive) ...[
                    const SizedBox(height: 12),
                    // Compact button for live routes
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onButtonTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              buttonTitle,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, size: 17),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 8),
                    // Minimal button for upcoming routes
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: onButtonTap,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: accentColor,
                          side: BorderSide(color: accentColor.withAlpha(60)),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'View Details',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: accentColor,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
