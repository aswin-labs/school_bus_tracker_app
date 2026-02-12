import 'package:flutter/material.dart';

import '../../core/extensions/context_extensions.dart';
import '../../core/extensions/size_extensions.dart';

class CommonButton extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? radius;
  final IconData? icon;
  final Color? contentColor;
  final bool isLoading;

  const CommonButton({
    super.key,
    required this.title,
    required this.onTap,
    this.backgroundColor,
    this.radius,
    this.icon = Icons.play_arrow_rounded,
    this.contentColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color fgColor =
        contentColor ?? context.colors.onSurface;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              backgroundColor ?? const Color.fromARGB(255, 88, 225, 133),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius ?? 12),
          ),
          padding: EdgeInsets.symmetric(vertical: 1.5.hp),
        ),
        onPressed: isLoading ? null : onTap,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isLoading
              ? SizedBox(
                  key: const ValueKey('loader'),
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                  ),
                )
              : Row(
                  key: const ValueKey('content'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: fgColor, size: 28),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      title,
                      style: context.text.bodyLarge?.copyWith(
                        color: fgColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
