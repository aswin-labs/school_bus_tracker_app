import 'package:flutter/material.dart';
import 'package:school_bus_tracker/core/extensions/context_extensions.dart';
import 'package:school_bus_tracker/core/extensions/size_extensions.dart';

class StudentTile extends StatelessWidget {
  final String studentName;
  final String guardianName;
  const StudentTile({
    super.key,
    required this.studentName,
    required this.guardianName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Color(0xFFF4F4F4),
              child: Icon(Icons.person, color: Colors.grey),
            ),
            2.w,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    studentName,
                    style: context.text.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  Row(
                    children: [
                      Icon(Icons.person_2_outlined, size: 15),
                      1.w,
                      Text(guardianName, style: context.text.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
            // CircleAvatar(
            //   backgroundColor: Color(0xFFF4F4F4),
            //   child: Icon(Icons.done, color: Colors.black),
            // ),
            // 2.w,
            // CircleAvatar(
            //   backgroundColor: Color(0xFFF4F4F4),
            //   child: Icon(Icons.close, color: Colors.black),
            // ),
          ],
        ),
      ),
    );
  }
}
