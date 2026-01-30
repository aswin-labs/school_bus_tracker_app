import 'package:flutter/material.dart';
import 'shimmer_box.dart';

class ShimmerList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final double radius;
  final double spacing;

  const ShimmerList({
    super.key,
    required this.itemHeight,
    this.itemCount = 3,
    this.radius = 16,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, __) => Padding(
          padding: EdgeInsets.only(bottom: spacing),
          child: ShimmerBox(
            height: itemHeight,
            radius: radius,
          ),
        ),
        childCount: itemCount,
      ),
    );
  }
}
