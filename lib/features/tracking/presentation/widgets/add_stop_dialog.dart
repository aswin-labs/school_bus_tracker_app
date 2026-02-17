import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_bus_tracker/core/widgets/common_button.dart';
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ───── HEADER ─────
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  const Text(
                    'Add New Stop',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(flex: 2),
                ],
              ),

              const SizedBox(height: 16),

              /// ───── ROUTE ─────
              Consumer<RouteProvider>(
                builder: (context, provider, _) {
                  final routes = provider.driverRoutes;
                  return _DropdownContainer(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<RouteModel>(
                        value: _selectedRoute,
                        isExpanded: true,
                        isDense: true,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: routes.map((route) {
                          return DropdownMenuItem(
                            value: route,
                            child: Text(route.routeName ?? ''),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedRoute = value);
                        },
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              /// ───── STOP NAME ─────
              _InputTile(
                icon: Icons.text_fields,
                child: TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Add title',
                    isDense: true,
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              /// ───── PRIORITY ─────
              _InputTile(
                icon: Icons.format_list_numbered,
                child: TextField(
                  controller: _priorityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Add Priority',
                    isDense: true,
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              /// ───── COORDINATES ─────
              Consumer<StopManagementProvider>(
                builder: (context, provider, _) {
                  final loc = provider.selectedLocation;
                  return _InputTile(
                    icon: Icons.location_on_outlined,
                    child: Text(
                      loc != null
                          ? '${loc.latitude}, ${loc.longitude}'
                          : 'No location selected',
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              /// ───── CURRENT LOCATION ─────
              Consumer<LiveLocationProvider>(
                builder: (context, liveProvider, _) {
                  return _ActionTile(
                    icon: Icons.my_location,
                    text: liveProvider.isFetchingLocation
                        ? "Fetching location..."
                        : "Select current location",
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

              const SizedBox(height: 8),
              const Center(child: Text('or')),
              const SizedBox(height: 8),

              /// ───── MAP PICK ─────
              _ActionTile(
                icon: Icons.map_outlined,
                text: 'Select location from map',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SelectLocationMapScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              /// ───── SUBMIT ─────
              Consumer<StopManagementProvider>(
                builder: (context, provider, _) {
                  return CommonButton(
                    title: "Add New Stop",
                    icon: Icons.add_location_alt_outlined,
                    contentColor: Colors.white,
                    backgroundColor: Colors.black,
                    isLoading: provider.isLoading,
                    onTap: _handleSubmit,
                  );
                },
              ),
            ],
          ),
        ),
      ),
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
    );

    if (!mounted) return;

    if (result == null) {
      // ✅ SUCCESS
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Stop added successfully')));
      Navigator.pop(context);
    } else {
      // ❌ ERROR
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

class _DropdownContainer extends StatelessWidget {
  final Widget child;
  const _DropdownContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 224, 223, 223),
        borderRadius: BorderRadius.circular(18),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}

class _InputTile extends StatelessWidget {
  final IconData icon;
  final Widget child;

  const _InputTile({required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 224, 223, 223),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final bool isLoading;

  const _ActionTile({
    required this.icon,
    required this.text,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 224, 223, 223),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(icon),
            const SizedBox(width: 12),
            Text(text),
          ],
        ),
      ),
    );
  }
}

// class AddStopDialog extends StatefulWidget {
//   final int routeId;
//   const AddStopDialog({super.key, required this.routeId});

//   @override
//   State<AddStopDialog> createState() => _AddStopDialogState();
// }

// class _AddStopDialogState extends State<AddStopDialog> {
//   final _titleController = TextEditingController();
//   final _priorityController = TextEditingController();
//   late TrackingProvider trackingProvider;

//   RouteModel? _selectedRoute;

//   @override
//   void initState() {
//     super.initState();
//     trackingProvider = context.read<TrackingProvider>();

//     if (trackingProvider.selectedLocation == null &&
//         trackingProvider.currentLocation != null) {
//       trackingProvider.setSelectedLocation(trackingProvider.currentLocation!);
//     }
//     final routes = context.read<RouteProvider>().driverRoutes;

//     _selectedRoute = routes.firstWhere((r) => r.id == widget.routeId);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//       insetPadding: const EdgeInsets.all(16),
//       child: SingleChildScrollView(
//         padding: EdgeInsets.only(
//           bottom: MediaQuery.of(context).viewInsets.bottom,
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               /// Header
//               Row(
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.arrow_back),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                   const Spacer(),
//                   const Text(
//                     'Add New stop',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//                   ),
//                   const Spacer(flex: 2),
//                 ],
//               ),

//               const SizedBox(height: 16),

//               /// Route Dropdown
//               Consumer<RouteProvider>(
//                 builder: (context, provider, _) {
//                   final routes = provider.driverRoutes;
//                   return _DropdownContainer(
//                     child: DropdownButtonHideUnderline(
//                       child: DropdownButton<RouteModel>(
//                         value: _selectedRoute,
//                         hint: Text(
//                           'Choose a Route',
//                           style: context.text.bodyMedium,
//                         ),
//                         isExpanded: true,
//                         isDense: true,
//                         icon: const Icon(Icons.keyboard_arrow_down),
//                         items: routes.map((route) {
//                           return DropdownMenuItem(
//                             value: route,
//                             child: Text(route.routeName ?? ''),
//                           );
//                         }).toList(),
//                         onChanged: (value) {
//                           setState(() => _selectedRoute = value);
//                         },
//                       ),
//                     ),
//                   );
//                 },
//               ),

//               const SizedBox(height: 12),

//               /// Title
//               _InputTile(
//                 icon: Icons.text_fields,
//                 child: TextField(
//                   controller: _titleController,
//                   style: const TextStyle(fontSize: 14),
//                   decoration: const InputDecoration(
//                     hintText: 'Add title',
//                     isDense: true,
//                     contentPadding: EdgeInsets.zero,
//                     border: InputBorder.none,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 12),

//               /// Title
//               _InputTile(
//                 icon: Icons.format_list_numbered,
//                 child: TextField(
//                   controller: _priorityController,
//                   keyboardType: TextInputType.number,
//                   style: const TextStyle(fontSize: 14),
//                   decoration: const InputDecoration(
//                     hintText: 'Add Priority',
//                     isDense: true,
//                     contentPadding: EdgeInsets.zero,
//                     border: InputBorder.none,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 12),

//               /// Coordinates
//               Consumer<TrackingProvider>(
//                 builder: (context, provider, _) {
//                   final location = provider.selectedLocation;
//                   return _InputTile(
//                     icon: Icons.location_on_outlined,
//                     child: Text(
//                       location != null
//                           ? '${location.latitude}, ${location.longitude}'
//                           : 'No location selected',
//                     ),
//                   );
//                 },
//               ),

//               const SizedBox(height: 12),

//               /// Select Current Location
//               _ActionTile(
//                 icon: Icons.my_location,
//                 text: 'Select current location',
//                 onTap: () {
//                   context.read<TrackingProvider>().useCurrentLocation();
//                 },
//               ),

//               const SizedBox(height: 8),

//               const Center(child: Text('or')),

//               const SizedBox(height: 8),

//               /// Pick from Map
//               _ActionTile(
//                 icon: Icons.map_outlined,
//                 text: 'Select location from map',
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => const SelectLocationMapScreen(),
//                     ),
//                   );
//                 },
//               ),

//               const SizedBox(height: 20),
//               CommonButton(
//                 title: "Add New Stop",
//                 onTap: _handleSubmit,
//                 icon: Icons.add_location_alt_outlined,
//                 contentColor: Colors.white,
//                 backgroundColor: Colors.black,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _handleSubmit() {
//     if (_titleController.text.isEmpty) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Fill all fields')));
//       return;
//     }

//     context.read<TrackingProvider>().addStop(
//       routeId: _selectedRoute!.id!,
//       stopName: _titleController.text.trim(),
//       priority: int.parse(_priorityController.text),
//     );

//     Navigator.pop(context);
//   }
// }

// class _DropdownContainer extends StatelessWidget {
//   final Widget child;
//   const _DropdownContainer({required this.child});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: Color.fromARGB(255, 224, 223, 223),
//         borderRadius: BorderRadius.circular(18),
//       ),
//       alignment: Alignment.center,
//       child: child,
//     );
//   }
// }

// class _InputTile extends StatelessWidget {
//   final IconData icon;
//   final Widget child;

//   const _InputTile({required this.icon, required this.child});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//       decoration: BoxDecoration(
//         color: Color.fromARGB(255, 224, 223, 223),
//         borderRadius: BorderRadius.circular(18),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, size: 20),
//           const SizedBox(width: 12),
//           Expanded(child: child),
//         ],
//       ),
//     );
//   }
// }

// class _ActionTile extends StatelessWidget {
//   final IconData icon;
//   final String text;
//   final VoidCallback onTap;

//   const _ActionTile({
//     required this.icon,
//     required this.text,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       borderRadius: BorderRadius.circular(12),
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         decoration: BoxDecoration(
//           color: Color.fromARGB(255, 224, 223, 223),
//           borderRadius: BorderRadius.circular(18),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [Icon(icon), const SizedBox(width: 12), Text(text)],
//         ),
//       ),
//     );
//   }
// }
