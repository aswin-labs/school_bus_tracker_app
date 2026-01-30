import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_bus_tracker/core/extensions/context_extensions.dart';
import 'package:school_bus_tracker/core/extensions/size_extensions.dart';
import 'package:school_bus_tracker/features/tracking/presentation/provider/tracking_provider.dart';
import 'package:school_bus_tracker/features/tracking/presentation/widgets/add_stop_dialog.dart';
import 'package:school_bus_tracker/features/tracking/presentation/widgets/tracking_bottom_sheet.dart';
import 'package:school_bus_tracker/features/tracking/presentation/widgets/tracking_map.dart';

class TrackingScreen extends StatefulWidget {
  final int routeId;
  const TrackingScreen({super.key, required this.routeId});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  late TrackingProvider trackingProvider;

  static const double _minSize = 0.3;
  static const double _maxSize = 0.65;

  @override
  void initState() {
    super.initState();
    trackingProvider = context.read<TrackingProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      trackingProvider.fetchCurrentLocation();
      trackingProvider.fetchStops(routeId: widget.routeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TrackingProvider>();
    return Scaffold(
      appBar: AppBar(title: Text("Route In Progress"), centerTitle: true),
      body: Stack(
        children: [
          GoogleMapView(provider: provider),
          Positioned(
            right: 3.wp,
            top: 10.hp,
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AddStopDialog(routeId: widget.routeId,),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),

                child: Row(
                  children: [
                    Icon(Icons.add),
                    2.w,
                    Text(
                      "Add Stop",
                      style: context.text.bodyLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          TrackingBottomSheet(
            sheetController: _sheetController,
            minSize: _minSize,
            maxSize: _maxSize,
            sortedStops: provider.sortedStops,
            onArrived: () {
              // provider.markArrivedAtStop();
            },
          ),
        ],
      ),
    );
  }
}
