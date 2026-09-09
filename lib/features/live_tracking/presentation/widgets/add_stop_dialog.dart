import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_bus_tracker/core/theme/app_colors.dart';
import 'package:school_bus_tracker/core/utils/snackbar_helper.dart';
import 'package:school_bus_tracker/features/home/data/models/route_model.dart';
import 'package:school_bus_tracker/features/home/presentation/provider/route_provider.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/provider/live_location_provider.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/provider/stops_provider.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/widgets/select_location_map_screen.dart';

class AddStopDialog extends StatefulWidget {
  final int routeId;
  const AddStopDialog({super.key, required this.routeId});

  @override
  State<AddStopDialog> createState() => _AddStopDialogState();
}

class _AddStopDialogState extends State<AddStopDialog> {
  final _titleController = TextEditingController();
  final _priorityController = TextEditingController();

  late StopsProvider stopProvider;
  int? _selectedRouteId;

  @override
  void initState() {
    super.initState();

    stopProvider = context.read<StopsProvider>();
    _selectedRouteId = widget.routeId;

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
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        clipBehavior: Clip.antiAlias,
        elevation: 12,
        shadowColor: Colors.black.withAlpha(50),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
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
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.only(
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
                            value: _selectedRouteId,
                            items: routes,
                            onChanged: (value) {
                              setState(() => _selectedRouteId = value);
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 18),

                      // Stop Name
                      _buildSectionLabel(
                        'Stop Name',
                        Icons.location_on_rounded,
                      ),
                      const SizedBox(height: 8),
                      _ModernInputField(
                        controller: _titleController,
                        hintText: 'Enter stop name',
                        icon: Icons.text_fields_rounded,
                      ),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: isEnabled,
                        activeColor: AppColors.primary,
                        onChanged: (value) {
                          setState(() {
                            isEnabled = value ?? false;
                          });
                        },
                        title: const Text(
                          'Is this stop also for both pickup and drop?',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      const SizedBox(height: 18),

                      // Priority
                      _buildSectionLabel(
                        'Priority',
                        Icons.low_priority_rounded,
                      ),
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
                      Consumer<StopsProvider>(
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
                            color: AppColors.primary,
                            isLoading: liveProvider.isFetchingLocation,
                            onTap: () async {
                              await liveProvider.fetchInitialLocation();

                              final location = liveProvider.currentLocation;

                              if (!context.mounted) return;

                              if (location != null) {
                                context
                                    .read<StopsProvider>()
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
                          const Expanded(
                            child: Divider(
                              color: AppColors.divider,
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'or',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Divider(
                              color: AppColors.divider,
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      _LocationActionButton(
                        icon: Icons.map_rounded,
                        label: 'Select from Map',
                        color: AppColors.primaryDark,
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
                      Consumer<StopsProvider>(
                        builder: (context, provider, _) {
                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: provider.isCreatingStop
                                  ? null
                                  : _handleSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: AppColors.border,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
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
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
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
      ),
    );
  }

  Widget _buildSectionLabel(String label, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  void _handleSubmit() async {
    if (_titleController.text.isEmpty ||
        _priorityController.text.isEmpty ||
        _selectedRouteId == null) {
      SnackbarHelper.showError(context, message: 'Fill all fields');
      return;
    }

    final result = await context.read<StopsProvider>().createStop(
      stopName: _titleController.text.trim(),
      priority: int.parse(_priorityController.text),
      routeId: _selectedRouteId!,
      isEnabled: isEnabled,
    );

    if (!mounted) return;

    await context.read<RouteProvider>().fetchDriverRoutes();

    if (!mounted) return;

    if (result == null) {
      SnackbarHelper.showSuccess(context, message: 'Stop added successfully');
      Navigator.pop(context, true);
    } else {
      SnackbarHelper.showError(context, message: result);
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
  final int? value;
  final List<RouteModel> items;
  final ValueChanged<int?> onChanged;

  const _ModernDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveValue = items.any((r) => r.id == value)
        ? value
        : (items.isNotEmpty ? items.first.id : null);

    return DropdownButtonFormField<int>(
      initialValue: effectiveValue,
      isExpanded: true,
      dropdownColor: AppColors.surface,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.primary,
      ),
      style: const TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.cardBg,
        prefixIcon: const Icon(
          Icons.alt_route_rounded,
          size: 18,
          color: AppColors.textDisabled,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
        ),
      ),
      items: items.map((route) {
        return DropdownMenuItem<int>(
          value: route.id,
          child: Text(
            route.routeName ?? 'Route #${route.id}',
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
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
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.cardBg,
        hintText: hintText,
        hintStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textDisabled,
        ),
        prefixIcon: Icon(icon, size: 18, color: AppColors.textDisabled),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
        ),
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
            ? AppColors.primary.withAlpha(12)
            : AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasLocation
              ? AppColors.primary.withAlpha(60)
              : AppColors.border,
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
            color: hasLocation ? AppColors.primary : AppColors.textDisabled,
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
                color: hasLocation ? AppColors.primary : AppColors.textMuted,
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
