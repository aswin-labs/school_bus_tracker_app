import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_bus_tracker/features/driver_routes/data/models/route_model.dart';
import 'package:school_bus_tracker/features/driver_routes/presentation/provider/route_provider.dart';
import 'package:school_bus_tracker/features/tracking/presentation/provider/live_location_provider.dart';
import 'package:school_bus_tracker/features/tracking/presentation/provider/stop_management_provider.dart';
import 'package:school_bus_tracker/features/tracking/presentation/widgets/select_location_map_screen.dart';

class AddStopDialog extends StatefulWidget {
  final int routeId;
  const AddStopDialog({super.key, required this.routeId});

  @override
  State<AddStopDialog> createState() => _AddStopDialogState();
}

class _AddStopDialogState extends State<AddStopDialog> {
  final _titleController = TextEditingController();
  final _priorityController = TextEditingController();

  late StopManagementProvider stopProvider;
  RouteModel? _selectedRoute;

  @override
  void initState() {
    super.initState();

    stopProvider = context.read<StopManagementProvider>();

    final routes = context.read<RouteProvider>().driverRoutes;

    if (routes.isNotEmpty) {
      _selectedRoute = routes.firstWhere(
        (r) => r.id == widget.routeId,
        orElse: () => routes.first,
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LiveLocationProvider>().clearCurrentLocation();
      stopProvider.clearSelectedLocation();

      final liveLocation = context.read<LiveLocationProvider>().currentLocation;

      if (liveLocation != null) {
        stopProvider.setSelectedLocation(liveLocation);
      }
    });
  }

  bool isEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
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
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── HEADER ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Row(
                  children: [
                    // Back button
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
                    // Title
                    Column(
                      children: [
                        Text(
                          'ADD NEW STOP',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withAlpha(200),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Create Stop',
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
                    const SizedBox(width: 36), // Balance
                  ],
                ),
              ),

              // ── CONTENT ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Route Selection
                    _buildSectionLabel('Route', Icons.route_rounded),
                    const SizedBox(height: 8),
                    Consumer<RouteProvider>(
                      builder: (context, provider, _) {
                        final routes = provider.driverRoutes;
                        return _ModernDropdown(
                          value: _selectedRoute,
                          items: routes,
                          onChanged: (value) {
                            setState(() => _selectedRoute = value);
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 18),

                    // Stop Name
                    _buildSectionLabel('Stop Name', Icons.location_on_rounded),
                    const SizedBox(height: 8),
                    _ModernInputField(
                      controller: _titleController,
                      hintText: 'Enter stop name',
                      icon: Icons.text_fields_rounded,
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: isEnabled,
                      onChanged: (value) {
                        setState(() {
                          isEnabled = value ?? false;
                        });
                      },
                      title: const Text(
                        'Is this stop also for the return/drop route?',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    const SizedBox(height: 18),

                    // Priority
                    _buildSectionLabel('Priority', Icons.low_priority_rounded),
                    const SizedBox(height: 8),
                    _ModernInputField(
                      controller: _priorityController,
                      hintText: 'Enter priority (e.g., 1, 2, 3)',
                      icon: Icons.format_list_numbered_rounded,
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 18),

                    // Location
                    _buildSectionLabel('Location', Icons.pin_drop_rounded),
                    const SizedBox(height: 8),
                    Consumer<StopManagementProvider>(
                      builder: (context, provider, _) {
                        final loc = provider.selectedLocation;
                        return _LocationDisplay(
                          latitude: loc?.latitude,
                          longitude: loc?.longitude,
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Location Actions
                    Consumer<LiveLocationProvider>(
                      builder: (context, liveProvider, _) {
                        return _LocationActionButton(
                          icon: Icons.my_location_rounded,
                          label: liveProvider.isFetchingLocation
                              ? "Fetching location..."
                              : "Use Current Location",
                          color: const Color(0xFF3B82F6),
                          isLoading: liveProvider.isFetchingLocation,
                          onTap: () async {
                            await liveProvider.fetchInitialLocation();

                            final location = liveProvider.currentLocation;

                            if (!context.mounted) return;

                            if (location != null) {
                              context
                                  .read<StopManagementProvider>()
                                  .useCurrentLocation(location);
                            }
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 10),

                    // Divider with "or"
                    Row(
                      children: [
                        Expanded(
                          child: Divider(color: Colors.grey[300], thickness: 1),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'or',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(color: Colors.grey[300], thickness: 1),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    _LocationActionButton(
                      icon: Icons.map_rounded,
                      label: 'Select from Map',
                      color: const Color(0xFF2563EB),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SelectLocationMapScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Submit Button
                    Consumer<StopManagementProvider>(
                      builder: (context, provider, _) {
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: provider.isCreatingStop
                                ? null
                                : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B82F6),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey[300],
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: provider.isCreatingStop
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
                                    children: const [
                                      Icon(
                                        Icons.add_location_alt_rounded,
                                        size: 20,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        'Add Stop',
                                        style: TextStyle(
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withAlpha(15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF3B82F6)),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  void _handleSubmit() async {
    if (_titleController.text.isEmpty ||
        _priorityController.text.isEmpty ||
        _selectedRoute == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Fill all fields')));
      return;
    }

    final result = await context.read<StopManagementProvider>().addStop(
      stopName: _titleController.text.trim(),
      priority: int.parse(_priorityController.text),
      routeId: _selectedRoute!.id,
      isEnabled: isEnabled,
    );

    if (!mounted) return;

    if (result == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Stop added successfully')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result)));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priorityController.dispose();
    super.dispose();
  }
}

// ═══════════════════════════════════════════════════════════════
// SUPPORTING WIDGETS
// ═══════════════════════════════════════════════════════════════

class _ModernDropdown extends StatelessWidget {
  final RouteModel? value;
  final List<RouteModel> items;
  final ValueChanged<RouteModel?> onChanged;

  const _ModernDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<RouteModel>(
          value: value,
          isExpanded: true,
          isDense: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF3B82F6),
          ),
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
          items: items.map((route) {
            return DropdownMenuItem(
              value: route,
              child: Text(route.routeName ?? ''),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _ModernInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final TextInputType? keyboardType;

  const _ModernInputField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[400]),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[400],
                ),
                isDense: true,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationDisplay extends StatelessWidget {
  final double? latitude;
  final double? longitude;

  const _LocationDisplay({this.latitude, this.longitude});

  @override
  Widget build(BuildContext context) {
    final hasLocation = latitude != null && longitude != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: hasLocation
            ? const Color(0xFF3B82F6).withAlpha(12)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasLocation
              ? const Color(0xFF3B82F6).withAlpha(60)
              : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasLocation
                ? Icons.check_circle_rounded
                : Icons.location_off_rounded,
            size: 18,
            color: hasLocation ? const Color(0xFF3B82F6) : Colors.grey[400],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              hasLocation
                  ? '${latitude!.toStringAsFixed(6)}, ${longitude!.toStringAsFixed(6)}'
                  : 'No location selected',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: hasLocation ? const Color(0xFF3B82F6) : Colors.grey[500],
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isLoading;

  const _LocationActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withAlpha(60), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isLoading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: color,
                    ),
                  )
                : Icon(icon, size: 18, color: color),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
