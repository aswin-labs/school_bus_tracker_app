import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_bus_tracker/core/network/app_update_service.dart';
import 'package:school_bus_tracker/core/responsive/responsive.dart';
import 'package:school_bus_tracker/core/theme/app_theme.dart';
import 'package:school_bus_tracker/core/theme/theme_provider.dart';
import 'package:school_bus_tracker/core/utils/providers.dart';
import 'package:school_bus_tracker/routes/router_config.dart';

void main() {
  runApp(MultiProvider(providers: getProviders(), child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
   @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppUpdateService.checkForUpdate();
    });
  }
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp.router(
      title: 'Acadobs Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeProvider.mode,
      routerConfig: appRouter,
      builder: (context, child) {
        Responsive.init(context);
        return child!;
      },
    );
  }
}
