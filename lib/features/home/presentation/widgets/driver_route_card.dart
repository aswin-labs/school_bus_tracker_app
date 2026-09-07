import 'package:flutter/material.dart';
import 'package:school_bus_tracker/core/extensions/context_extensions.dart';

class DriverRouteCard extends StatelessWidget {
  final String routeName;
  final VoidCallback onStopsTap;
  final VoidCallback onButtonTap;
  final String buttonTitle;
  final bool isLive;
  final bool isPickup;
  final int totalStops;

  const DriverRouteCard({
    super.key,
    required this.routeName,
    required this.onStopsTap,
    required this.onButtonTap,
    this.buttonTitle = 'Resume Trip',
    this.isLive = true,
    this.isPickup = true,
    this.totalStops = 0,
  });

  @override
  Widget build(BuildContext context) {
    // Colors based on Live vs Scheduled status
    final liveColor = const Color(0xFF10B981); // Emerald Green for Live
    final primaryBlue = const Color(0xFF3B82F6); // Standard primary brand blue

    // Card border color: Subtle blue for scheduled, vibrant green glow for live
    final borderColor = isLive
        ? liveColor.withAlpha(200)
        : primaryBlue.withAlpha(60);

    // Route Type (Pickup vs Drop) colors
    final pickupColor = const Color(0xFF2563EB); // Deep Blue for Pickup
    final dropColor = const Color.fromARGB(
      255,
      240,
      69,
      69,
    ); // Warm Orange for Drop
    final routeTypeColor = isPickup ? pickupColor : dropColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: context.theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: isLive ? 1.8 : 1.0),
          boxShadow: isLive
              ? [
                  BoxShadow(
                    color: liveColor.withAlpha(35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(6),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Bar - Compact
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isLive
                    ? liveColor.withAlpha(20)
                    : primaryBlue.withAlpha(12),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(13),
                  topRight: Radius.circular(13),
                ),
              ),
              child: Row(
                children: [
                  // Live pulse dot vs Scheduled dot
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isLive ? liveColor : primaryBlue,
                      shape: BoxShape.circle,
                      boxShadow: isLive
                          ? [
                              BoxShadow(
                                color: liveColor.withAlpha(140),
                                blurRadius: 4,
                                spreadRadius: 1.5,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isLive ? 'LIVE TRIP' : 'SCHEDULED',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isLive ? liveColor : primaryBlue,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const Spacer(),
                  // Route Type Badge (Pickup vs Drop)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: routeTypeColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: routeTypeColor.withAlpha(60),
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
                          size: 12,
                          color: routeTypeColor,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          isPickup ? "Pickup" : "Drop",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: routeTypeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Card Body Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Route Title with icon
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: routeTypeColor.withAlpha(18),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.alt_route_rounded,
                          size: 20,
                          color: routeTypeColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          routeName,
                          style: context.text.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Stops Button Action Card
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onStopsTap,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: context.theme.canvasColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: context.theme.dividerColor.withAlpha(45),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 16,
                              color: primaryBlue,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                totalStops > 0
                                    ? "$totalStops ${totalStops == 1 ? 'Stop' : 'Stops'} Configured"
                                    : "No Stops (Tap to add)",
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: totalStops > 0
                                      ? context.text.bodyMedium?.color
                                      : const Color.fromARGB(255, 89, 175, 251),
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 18,
                              color: context.theme.dividerColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Main Button Action (Start / Resume Trip)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onButtonTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isLive ? liveColor : primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isLive
                                ? Icons.play_circle_fill_rounded
                                : Icons.navigation_rounded,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isLive ? buttonTitle : "Start Trip",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
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
