import 'package:flutter/material.dart';
import 'package:school_bus_tracker/core/extensions/context_extensions.dart';
import 'package:school_bus_tracker/core/extensions/size_extensions.dart';
import 'package:school_bus_tracker/core/widgets/common_button.dart';

class DriverRouteCard extends StatelessWidget {
  final String routeName;
  final String timeRange;
  final VoidCallback onButtonTap;
  final String buttonTitle;
  final bool isLive;

  const DriverRouteCard({
    super.key,
    required this.routeName,
    required this.timeRange,
    required this.onButtonTap,
    this.buttonTitle = 'Resume Trip',
    this.isLive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Container(
        padding: EdgeInsets.all(4.wp),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isLive ? Colors.green : Colors.grey,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live indicator and icon
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isLive ? Colors.green : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                2.w,
                Text(
                  isLive ? 'Live' : 'Upcoming',
                  style: context.text.bodyMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            1.h,

            // Route info
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(0xFF333333),
                  radius: 25,
                  child: Image.asset('assets/icons/route_icon.png', width: 20),
                ),
                2.w,
                Expanded(
                  child: _routeNameWidget(
                    context: context,
                    routeName: routeName,
                  ),
                ),
              ],
            ),
            1.h,
            _timeInfoWidget(context: context, time: timeRange),

            // Time range
            1.h,
            Image.asset('assets/icons/map.png'),

            1.h,

            // Button
            CommonButton(
              title: buttonTitle,
              onTap: onButtonTap,
              backgroundColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}

Widget _routeNameWidget({
  required BuildContext context,
  required String routeName,
}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 8.wp, vertical: .8.hp),
    decoration: BoxDecoration(
      color: Color(0xFFE8E8E8),
      borderRadius: BorderRadius.circular(30),
    ),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Image.asset('assets/icons/home.png', width: 20),
          3.w,
          Icon(Icons.arrow_forward_rounded),
          3.w,
          Text(
            routeName,
            style: context.text.titleMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}

Widget _timeInfoWidget({required BuildContext context, required String time}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 4.wp, vertical: .5.hp),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
    ),
    child: Text(
      time,
      style: context.text.labelMedium,
      overflow: TextOverflow.ellipsis,
    ),
  );
}
