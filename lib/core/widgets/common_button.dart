import 'package:flutter/material.dart';

import '../../core/extensions/context_extensions.dart';
import '../../core/extensions/size_extensions.dart';

class CommonButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final double? radius;
  final IconData? icon;
  final Color? contentColor;

  const CommonButton({
    super.key,
    required this.title,
    required this.onTap,
    this.backgroundColor,
    this.radius,
    this.icon = Icons.play_arrow_rounded,
    this.contentColor
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Color.fromARGB(255, 88, 225, 133),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius ?? 12),
          ),
          padding: EdgeInsets.symmetric(vertical: 1.5.hp),
        ),
        onPressed: onTap,
        icon: Icon(
          icon,
          color: contentColor??context.colors.onSurface,
          size: 28,
        ),
        label: Text(
          title,
          style: context.text.bodyLarge?.copyWith(
            color:  contentColor??context.colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
