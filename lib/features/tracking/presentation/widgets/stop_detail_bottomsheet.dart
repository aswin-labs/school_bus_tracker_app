import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_bus_tracker/core/extensions/context_extensions.dart';
import 'package:school_bus_tracker/core/extensions/size_extensions.dart';
import 'package:school_bus_tracker/core/widgets/common_button.dart';
import 'package:school_bus_tracker/features/tracking/presentation/provider/stop_management_provider.dart';
import 'package:school_bus_tracker/features/tracking/presentation/widgets/add_student_dialog.dart';
import 'package:school_bus_tracker/features/tracking/presentation/widgets/student_tile.dart';

class StopDetailsBottomsheet extends StatefulWidget {
  final int stopId;
  const StopDetailsBottomsheet({super.key, required this.stopId});

  @override
  State<StopDetailsBottomsheet> createState() => _StopDetailsBottomsheetState();
}

class _StopDetailsBottomsheetState extends State<StopDetailsBottomsheet> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<StopManagementProvider>().fetchSingleStop(widget.stopId);
  }

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
              Consumer<StopManagementProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final stop = provider.singleStop;

                  if (stop == null) {
                    return const SliverFillRemaining(
                      child: Center(child: Text("No data found")),
                    );
                  }

                  return SliverPersistentHeader(
                    pinned: true,
                    delegate: StopHeaderDelegate(
                      stopName: provider.singleStop?.stopName ?? "",
                      onTap: () {
                        final routeId = provider.singleStop?.routeId;
                        showDialog(
                          context: context,
                          builder: (_) => AddStudentDialog(
                            routeId: routeId ?? 0,
                            stopId: provider.singleStop?.id ?? 0,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              /// ALL STOPS LIST
              Consumer<StopManagementProvider>(
                builder: (context, provider, _) {
                  final stop = provider.singleStop;

                  if (stop == null) {
                    return const SliverFillRemaining(
                      child: Center(child: Text("No data found")),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final student = stop.students?[index];

                      return StudentTile(
                        studentName: student?.name ?? "",
                        guardianName: student?.guardianName ?? "",
                      );
                    }, childCount: stop.students?.length ?? 0),
                  );
                },
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
class StopHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String stopName;
  final VoidCallback onTap;

  StopHeaderDelegate({required this.stopName, required this.onTap});

  static const double _headerHeight = 220;

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
        crossAxisAlignment: CrossAxisAlignment.start,
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

          1.5.h,

          /// HEADER
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.arrow_back),
              ),
              const Spacer(),
              Text(
                "Stop Details",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const Spacer(),
            ],
          ),
          3.h,
          Text(
            stopName,
            style: context.text.titleLarge!.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          1.h,

          /// ADD BUTTON
          CommonButton(
            title: "Add New Student",
            icon: Icons.add,
            backgroundColor: Colors.black,
            contentColor: Colors.white,
            onTap: onTap,
          ),
          2.h,
          Text(
            'All Students in this stop',
            style: context.text.titleLarge!.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
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
