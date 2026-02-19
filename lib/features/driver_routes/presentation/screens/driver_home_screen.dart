import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:school_bus_tracker/core/extensions/context_extensions.dart';
import 'package:school_bus_tracker/core/extensions/size_extensions.dart';
import 'package:school_bus_tracker/core/widgets/shimmer/shimmer_list.dart';
import 'package:school_bus_tracker/features/driver_routes/presentation/provider/route_provider.dart';
import 'package:school_bus_tracker/features/driver_routes/presentation/widgets/driver_route_card.dart';
import 'package:school_bus_tracker/features/driver_routes/presentation/widgets/start_journey_dialog.dart';
import 'package:school_bus_tracker/routes/router_constants.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRoutes();
    });
  }

  Future<void> _loadRoutes() async {
    final provider = context.read<RouteProvider>();
    final error = await provider.fetchDriverRoutes();

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(error)),
            ],
          ),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Future<bool> _activateRoute(int routeId) async {
    final provider = context.read<RouteProvider>();
    final error = await provider.activateRoute(routeId);

    if (!mounted) return false;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(error)),
            ],
          ),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return false;
    }

    return true;
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.theme.canvasColor,
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.directions_bus_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_getGreeting(), style: context.text.titleLarge),
                  const SizedBox(height: 2),
                  Text(
                    _getCurrentDate(),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: context.theme.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () =>
                  context.pushNamed(RouterConstants.settingsScreen),
              icon: const Icon(Icons.settings_outlined),
              color: context.theme.dividerColor,
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(color: context.theme.canvasColor),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Consumer<RouteProvider>(
            builder: (context, provider, _) {
              return RefreshIndicator(
                onRefresh: _loadRoutes,
                color: Colors.black,
                child: CustomScrollView(
                  slivers: [
                    // Stats Section
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromARGB(
                                255,
                                162,
                                189,
                                233,
                              ).withAlpha(20),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildQuickStat(
                                icon: Icons.route_rounded,
                                label: 'Total Routes',
                                value: provider.driverRoutes.length.toString(),
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.white.withAlpha(77),
                            ),
                            Expanded(
                              child: _buildQuickStat(
                                icon: Icons.directions_bus_filled,
                                label: 'Active Now',
                                value: provider.driverRoutes
                                    .where((r) => r.active == true)
                                    .length
                                    .toString(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Section Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Today's Routes",
                              style: context.text.titleLarge,
                            ),
                            if (provider.driverRoutes.isNotEmpty)
                              Text(
                                '${provider.driverRoutes.length} ${provider.driverRoutes.length == 1 ? 'Route' : 'Routes'}',
                                style: context.text.titleMedium,
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (provider.isLoading)
                      ShimmerList(itemHeight: 20.hp, itemCount: 3)
                    else if (provider.driverRoutes.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildEmptyState(),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final route = provider.driverRoutes[index];
                          return DriverRouteCard(
                            routeName: route.routeName ?? "Unknown Route",
                            timeRange: "07:30 am - 08:30 am",
                            isLive: route.active == true,
                            onButtonTap: () {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) {
                                  bool isLoading = false;

                                  return StatefulBuilder(
                                    builder: (context, setStateDialog) {
                                      return StartJourneyDialog(
                                        isLoading: isLoading,
                                        onStart: () async {
                                          setStateDialog(
                                            () => isLoading = true,
                                          );

                                          final success = await _activateRoute(
                                            route.id,
                                          );

                                          if (!context.mounted) return;

                                          if (success) {
                                            Navigator.pop(context);
                                            context.pushNamed(
                                              RouterConstants.trackingScreen,
                                              extra: route.id,
                                            );
                                          } else {
                                            setStateDialog(
                                              () => isLoading = false,
                                            );
                                          }
                                        },
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          );
                        }, childCount: provider.driverRoutes.length),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withAlpha(230),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.event_busy_rounded,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Routes Today',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'You don\'t have any assigned routes for today. Check back later.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
