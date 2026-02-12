import 'package:flutter/material.dart';
import 'package:school_bus_tracker/core/extensions/context_extensions.dart';
import 'package:school_bus_tracker/core/extensions/size_extensions.dart';
import 'package:school_bus_tracker/core/widgets/common_button.dart';
import 'package:school_bus_tracker/features/tracking/presentation/widgets/add_stop_dialog.dart';
import 'package:school_bus_tracker/features/tracking/presentation/widgets/stop_tile.dart';

class StopListManagementBottomsheet extends StatelessWidget {
  const StopListManagementBottomsheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.75,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: StopListHeaderDelegate(
                  onAdd: () {
                    showDialog(
                      context: context,
                      builder: (_) => AddStopDialog(routeId: 1),
                    );
                  },
                ),
              ),

              /// ALL STOPS TITLE
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'All Stops',
                    style: context.text.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),

              /// ALL STOPS LIST
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return StopTile(
                    stopName: "Stop $index",
                    studentsCount: 10,
                    time: "08:30 AM",
                  );
                }, childCount: 6),
              ),

              /// PENDING TITLE
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Pending Approval',
                    style: context.text.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),

              /// PENDING LIST
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return StopTile(
                    stopName: "Pending Stop $index",
                    studentsCount: 10,
                    time: "Pending",
                  );
                }, childCount: 6),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        );
      },
    );
  }
}

// Header
class StopListHeaderDelegate extends SliverPersistentHeaderDelegate {
  final VoidCallback onAdd;

  StopListHeaderDelegate({required this.onAdd});

  static const double _headerHeight = 160;

  @override
  double get minExtent => _headerHeight;

  @override
  double get maxExtent => _headerHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      // padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        children: [
          /// DRAG HANDLE
          Center(
            child: Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          2.h,

          /// HEADER
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.arrow_back),
              ),
              const Spacer(),
              Text(
                "Stop List Management",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const Spacer(),
            ],
          ),
          3.h,

          /// ADD BUTTON
          CommonButton(
            title: "Add New Stop",
            icon: Icons.add,
            backgroundColor: Colors.black,
            contentColor: Colors.white,
            onTap: onAdd,
          ),
          // 1.5.h,
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
