import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_bus_tracker/core/extensions/context_extensions.dart';

class CommonPopUp extends StatefulWidget {
  final String title;
  final String subtitle;
  final String iconText;
  final bool iscancel;
  final VoidCallback? onPressed;
  final IconData? icon;
  const CommonPopUp({
    super.key,
    required this.subtitle,
    required this.title,
    required this.iconText,
    this.onPressed,
    this.iscancel = true,
    this.icon,
  });

  @override
  State<CommonPopUp> createState() => _CommonPopUpState();
}

class _CommonPopUpState extends State<CommonPopUp>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: Container(
            decoration: BoxDecoration(
              color: context.theme.canvasColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),

                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: context.theme.canvasColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(widget.icon, size: 30, color: Colors.red),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: context.text.titleLarge,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    widget.subtitle,
                    textAlign: TextAlign.center,
                    style: context.text.labelLarge,
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      if (widget.iscancel) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => context.pop(),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: context.theme.cardColor,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(
                                color: context.theme.disabledColor,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "Cancel",
                              style: context.text.labelLarge,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],

                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: widget.onPressed,
                          child: Text(
                            widget.iconText,
                            style: context.text.labelLarge,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
