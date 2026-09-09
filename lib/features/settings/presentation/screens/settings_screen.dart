import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:school_bus_tracker/core/extensions/context_extensions.dart';
import 'package:school_bus_tracker/core/extensions/size_extensions.dart';
import 'package:school_bus_tracker/core/theme/app_colors.dart';
import 'package:school_bus_tracker/core/theme/theme_provider.dart';
import 'package:school_bus_tracker/core/utils/snackbar_helper.dart';
import 'package:school_bus_tracker/features/auth/presentation/provider/auth_provider.dart';
import 'package:school_bus_tracker/core/widgets/common_pop_up.dart';
import 'package:school_bus_tracker/routes/router_constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _handleLogout() async {
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();

    final error = await authProvider.logout();

    if (!mounted) return;

    if (error != null) {
      SnackbarHelper.showError(context, message: error);
    } else {
      context.goNamed(RouterConstants.loginScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: EdgeInsets.all(4.wp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColors.primaryColors,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Driver Account', style: context.text.bodyLarge),
                        const SizedBox(height: 4),
                        Text(
                          'School Bus Tracker',
                          style: context.text.labelLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Theme toggle
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Dark Mode', style: context.text.bodyLarge),
                      Switch(
                        trackColor: WidgetStatePropertyAll(
                          context.theme.secondaryHeaderColor,
                        ),
                        value: themeProvider.mode == ThemeMode.dark,
                        onChanged: (val) => themeProvider.toggleTheme(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Divider(
                    thickness: 2,
                    color: context.theme.focusColor,
                    radius: BorderRadius.circular(20),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Notification', style: context.text.bodyLarge),
                      const Icon(Icons.arrow_forward_ios),
                    ],
                  ),
                ],
              ),
            ),
            4.h,

            // Logout
            GestureDetector(
              onTap: () {
                // authProvider.isLoading ? null : _handleLogout();
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => CommonPopUp(
                    icon: Icons.logout,
                    subtitle: "Are you sure want to logout?",
                    title: "Logout",
                    iconText: "logout",
                    onPressed: () {
                      authProvider.isLoading ? null : _handleLogout();
                    },
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.theme.canvasColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.logout, color: AppColors.error),
                    SizedBox(width: 10),
                    Text(
                      "Logout",
                      style: TextStyle(color: AppColors.error, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
