import 'package:flutter/material.dart';

class MoreMenuOption {
  final String name;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? iconColor;
  final Color? textColor;

  const MoreMenuOption({
    required this.name,
    required this.onTap,
    this.icon,
    this.iconColor,
    this.textColor,
  });
}

class CustomMoreMenu extends StatelessWidget {
  final List<MoreMenuOption> options;
  final IconData icon;
  final double iconSize;
  final Color? iconColor;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double elevation;
  final Color? backgroundColor;

  const CustomMoreMenu({
    super.key,
    required this.options,
    this.icon = Icons.more_vert,
    this.iconSize = 22,
    this.iconColor,
    this.padding,
    this.width,
    this.elevation = 4,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<MoreMenuOption>(
      icon: Icon(
        icon,
        size: iconSize,
        color: iconColor,
      ),
      padding: padding ?? EdgeInsets.zero,
      elevation: elevation,
      color: backgroundColor ?? Colors.white,
      onSelected: (option) => option.onTap(),
      itemBuilder: (context) {
        return options.map((option) {
          return PopupMenuItem<MoreMenuOption>(
            value: option,
            child: SizedBox(
              width: width,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (option.icon != null) ...[
                    Icon(
                      option.icon,
                      size: 19,
                      color: option.iconColor,
                    ),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    option.name,
                    style: TextStyle(
                      color: option.textColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList();
      },
    );
  }
}