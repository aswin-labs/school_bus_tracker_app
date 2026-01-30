import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_bus_tracker/routes/router_constants.dart';

import '../../../../core/storage/storage_services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final StorageService _storageService = StorageService.instance;

  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));

    final token = await _storageService.getToken();

    if (token != null && token.isNotEmpty) {
      if (!mounted) return;
      context.pushNamed(RouterConstants.driverHomeScreen);
    } else {
      if (!mounted) return;
      context.pushReplacementNamed(RouterConstants.loginScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'My App',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
