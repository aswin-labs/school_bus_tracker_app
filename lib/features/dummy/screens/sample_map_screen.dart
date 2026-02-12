import 'package:flutter/material.dart';
import 'package:school_bus_tracker/features/dummy/sample_google_map_view.dart';

class SampleMapScreen extends StatelessWidget {
  const SampleMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Route In Progress"), centerTitle: true),
      body: Stack(children: [SampleGoogleMapView()]),

      //  Column(
      //   crossAxisAlignment: CrossAxisAlignment.center,
      //   children: [
      //     Text("data"),
      //     ElevatedButton(
      //       onPressed: () {
              // showModalBottomSheet(
              //   context: context,
              //   isScrollControlled: true,
              //   builder: (context) {
              //     return const StopDetailsBottomsheet();
              //   },
              // );
      //       },
      //       child: Text("Stop Details"),
      //     ),
      //     2.h,
      //     ElevatedButton(
      //       onPressed: () {
      //         showModalBottomSheet(
      //           context: context,
      //           isScrollControlled: true,
      //           builder: (context) {
      //             return const StopListManagementBottomsheet();
      //           },
      //         );
      //       },
      //       child: Text("Stops Manage"),
      //     ),
      //   ],
      // ),
    );
  }
}
