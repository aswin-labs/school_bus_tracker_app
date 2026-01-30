import 'package:flutter/material.dart';
import 'package:school_bus_tracker/core/extensions/context_extensions.dart';
import 'package:school_bus_tracker/core/extensions/size_extensions.dart';
import 'package:school_bus_tracker/core/widgets/common_button.dart';
import 'package:school_bus_tracker/features/tracking/presentation/widgets/stop_tile.dart';

class TrackingBottomSheet extends StatelessWidget {
  const TrackingBottomSheet({
    super.key,
    required this.sheetController,
    required this.minSize,
    required this.maxSize,
    required this.sortedStops,
    required this.onArrived,
  });

  final DraggableScrollableController sheetController;
  final double minSize;
  final double maxSize;
  final List<dynamic> sortedStops; // use StopModel if available
  final VoidCallback onArrived;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: sheetController,
      initialChildSize: 0.4,
      minChildSize: minSize,
      maxChildSize: maxSize,
      snap: true,
      snapSizes: [minSize, maxSize],
      builder: (context, scrollController) {
        if (sortedStops.isEmpty) {
          return const SizedBox.shrink();
        }

        final nextStop = sortedStops.first;

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Stack(
            children: [
              /// DRAG HANDLE
              Positioned(
                top: 8,
                left: 0,
                right: 0,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onVerticalDragUpdate: (details) {
                    final height = MediaQuery.of(context).size.height;
                    final delta = -details.delta.dy / height;
                    sheetController.jumpTo(
                      (sheetController.size + delta).clamp(minSize, maxSize),
                    );
                  },
                  child: Center(
                    child: Container(
                      width: 50,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),

              /// CONTENT
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: CustomScrollView(
                  controller: scrollController,
                  physics: const ClampingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Next Stop",
                              style: context.text.bodyMedium!.copyWith(
                                color: Color(0xFF9C9C9C),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              nextStop.stopName,
                              style: context.text.titleLarge!.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            1.5.h,
                            Text(
                              "Students in this stop",
                              style: context.text.bodyMedium!.copyWith(
                                color: Color(0xFF9C9C9C),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            1.h,
                            Row(
                              children: [
                                Text(
                                  "Students",
                                  style: context.text.titleMedium!.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                2.w,
                                Icon(Icons.arrow_forward_ios_rounded),
                              ],
                            ),
                            1.5.h,
                            CommonButton(
                              title: "Arrived at Stop",
                              onTap: onArrived,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(left: 16, bottom: 16),
                        child: Text(
                          "Upcoming stops",
                          style: context.text.titleMedium!.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final stop = sortedStops[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: StopTile(
                            stopName: stop.stopName,
                            studentsCount: 12,
                            time: "time",
                          ),
                        );
                      }, childCount: sortedStops.length),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
