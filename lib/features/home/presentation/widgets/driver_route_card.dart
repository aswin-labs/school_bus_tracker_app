import 'package:flutter/material.dart';
import 'package:school_bus_tracker/core/extensions/context_extensions.dart';
import 'package:school_bus_tracker/core/theme/app_colors.dart';

class DriverRouteCard extends StatelessWidget {
  final String routeName;
  final VoidCallback onStopsTap;
  final VoidCallback onButtonTap;
  final VoidCallback? onStudentsTap;
  final String buttonTitle;
  final bool isLive;
  final bool isPickup;
  final int totalStops;
  final int totalStudents;

  const DriverRouteCard({
    super.key,
    required this.routeName,
    required this.onStopsTap,
    required this.onButtonTap,
    this.onStudentsTap,
    this.buttonTitle = 'Resume Trip',
    this.isLive = true,
    this.isPickup = true,
    this.totalStops = 0,
    this.totalStudents = 0,
  });

  @override
  Widget build(BuildContext context) {
    // ── Primary identity: Pickup vs Drop ──────────────────────────
    final routeColor = isPickup ? AppColors.pickupColor : AppColors.dropColor;
    // final routeColorDark = isPickup
    //     ? AppColors.pickupColorDark
    //     : AppColors.dropColorDark;
    final routeLabel = isPickup ? 'Pickup' : 'Drop';
    final routeIcon = isPickup ? Icons.login_rounded : Icons.logout_rounded;

    // ── Secondary indicator: Live status ─────────────────────────
    final liveColor = AppColors.success;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: context.theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLive ? liveColor.withAlpha(180) : routeColor.withAlpha(70),
            width: isLive ? 1.8 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isLive
                  ? liveColor.withAlpha(30)
                  : routeColor.withAlpha(18),
              blurRadius: isLive ? 14 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── LEFT ACCENT STRIPE ───────────────────────────
                // Container(
                //   width: 5,
                //   decoration: BoxDecoration(
                //     gradient: LinearGradient(
                //       begin: Alignment.topCenter,
                //       end: Alignment.bottomCenter,
                //       colors: [routeColor, routeColorDark],
                //     ),
                //   ),
                // ),

                // ── CARD CONTENT ─────────────────────────────────
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── HEADER ────────────────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              routeColor.withAlpha(22),
                              routeColor.withAlpha(8),
                            ],
                          ),
                        ),
                        child: Row(
                          children: [
                            // Route type icon bubble
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: routeColor.withAlpha(25),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: routeColor.withAlpha(60),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                routeIcon,
                                size: 16,
                                color: routeColor,
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Route type label
                            Text(
                              routeLabel.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: routeColor,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'ROUTE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: routeColor.withAlpha(160),
                                letterSpacing: 0.6,
                              ),
                            ),

                            const Spacer(),

                            // Live badge (secondary)
                            if (isLive)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: liveColor.withAlpha(20),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: liveColor.withAlpha(80),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: liveColor,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: liveColor.withAlpha(130),
                                            blurRadius: 4,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'LIVE',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: liveColor,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.textDisabled.withAlpha(15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.textDisabled.withAlpha(40),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'SCHEDULED',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSecondary.withAlpha(
                                      180,
                                    ),
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // ── BODY ─────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Route name
                            Text(
                              routeName,
                              style: context.text.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),

                            const SizedBox(height: 10),

                            // Stats row: Stops & Students
                            Row(
                              children: [
                                // Stops
                                Expanded(
                                  child: _StatChip(
                                    icon: totalStops > 0
                                        ? Icons.location_on_rounded
                                        : Icons.add_location_alt_rounded,
                                    label: totalStops > 0
                                        ? '$totalStops ${totalStops == 1 ? 'Stop' : 'Stops'}'
                                        : 'Add Stop',
                                    color: routeColor,
                                    onTap: onStopsTap,
                                    context: context,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Students
                                Expanded(
                                  child: _StatChip(
                                    icon: Icons.people_alt_rounded,
                                    label: totalStudents > 0
                                        ? '$totalStudents ${totalStudents == 1 ? 'Student' : 'Students'}'
                                        : '0 Students',
                                    color: routeColor,
                                    onTap: onStudentsTap,
                                    context: context,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // CTA Button — colored by route type
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: onButtonTap,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isLive
                                      ? liveColor
                                      : routeColor,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 11,
                                  ),
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
                                          : routeIcon,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      isLive ? buttonTitle : 'Start Trip',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Reusable stat chip used for Stops & Students
// ─────────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final BuildContext context;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.context,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: color.withAlpha(10),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withAlpha(35), width: 1),
          ),
          child: Row(
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: color.withAlpha(200),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 15,
                color: color.withAlpha(100),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
