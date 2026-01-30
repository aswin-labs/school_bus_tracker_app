import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:school_bus_tracker/core/extensions/context_extensions.dart';
import 'package:school_bus_tracker/core/extensions/size_extensions.dart';
import 'package:school_bus_tracker/core/theme/theme_provider.dart';
import 'package:school_bus_tracker/features/auth/presentation/provider/auth_provider.dart';
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
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
            // Theme toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Dark Mode', style: context.text.bodyLarge),
                Switch(
                  value: themeProvider.mode == ThemeMode.dark,
                  onChanged: (val) => themeProvider.toggleTheme(),
                ),
              ],
            ),
            4.h,

            // Logout
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text('Logout', style: context.text.bodyLarge),
              trailing: authProvider.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
              onTap: authProvider.isLoading ? null : _handleLogout,
            ),
          ],
        ),
      ),
    );
  }
}
