import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:school_bus_tracker/core/theme/app_colors.dart';
import 'package:school_bus_tracker/core/utils/snackbar_helper.dart';
import 'package:school_bus_tracker/features/live_tracking/data/models/stop_model.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/provider/live_location_provider.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/provider/stops_provider.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/widgets/select_location_map_screen.dart';

class EditStopDialog extends StatefulWidget {
  final StopModel stop;
  final int routeId;

  const EditStopDialog({super.key, required this.stop, required this.routeId});

  @override
  State<EditStopDialog> createState() => _EditStopDialogState();
}

class _EditStopDialogState extends State<EditStopDialog> {
  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.stop.stopName);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initialLocation = LatLng(
        widget.stop.latitude,
        widget.stop.longitude,
      );
      context.read<StopsProvider>().setSelectedLocation(initialLocation);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final stopName = _titleController.text.trim();
    if (stopName.isEmpty) {
      SnackbarHelper.showError(context, message: 'Please enter a stop name');
      return;
    }

    final selectedLoc = context.read<StopsProvider>().selectedLocation;
    if (selectedLoc == null) {
      SnackbarHelper.showError(context, message: 'Please select a location');
      return;
    }

    final provider = context.read<StopsProvider>();
    final error = await provider.updateStop(
      stopId: widget.stop.id,
      stopName: stopName,
      latitude: selectedLoc.latitude,
      longitude: selectedLoc.longitude,
      routeId: widget.routeId,
    );

    if (!mounted) return;

    if (error == null) {
      SnackbarHelper.showSuccess(context, message: 'Stop updated successfully');
      Navigator.pop(context, true);
    } else {
      SnackbarHelper.showError(context, message: error);
    }
  }

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
                            'EDIT STOP',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withAlpha(200),
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Update Stop Details',
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

                // ── CONTENT ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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

                      const SizedBox(height: 20),

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
                              onPressed: provider.isUpdatingStop
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
                              child: provider.isUpdatingStop
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
                                        Icon(Icons.save_rounded, size: 20),
                                        SizedBox(width: 10),
                                        Text(
                                          'Save Changes',
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
}

// ═══════════════════════════════════════════════════════════════
// SUPPORTING WIDGETS
// ═══════════════════════════════════════════════════════════════

class _ModernInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;

  const _ModernInputField({
    required this.controller,
    required this.hintText,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
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
        color: hasLocation ? AppColors.primary.withAlpha(12) : AppColors.cardBg,
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
