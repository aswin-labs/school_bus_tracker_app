import 'package:flutter/material.dart';

class StopTile extends StatelessWidget {
  final String stopName;
  final int studentsCount;
  final String time;
  final VoidCallback? onTap;

  const StopTile({
    super.key,
    required this.stopName,
    required this.studentsCount,
    required this.time,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2),
      child: Material(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              /// LEFT ICON
              Container(
                height: 44,
                width: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFE0E0E0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: Colors.black54,
                ),
              ),
        
              const SizedBox(width: 14),
        
              /// TEXT CONTENT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stopName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.groups_outlined,
                          size: 16,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$studentsCount Students',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          time,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
        
              /// RIGHT ARROW
              GestureDetector(
                onTap: onTap,
                child: Container(
                  height: 36,
                  width: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0E0E0),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chevron_right, color: Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
