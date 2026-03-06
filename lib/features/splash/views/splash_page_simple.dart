import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../routes/app_routes.dart';
import '../../../core/theme/afro_theme.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    // Wait only 1 second for splash effect (reduced from 2)
    await Future.delayed(const Duration(seconds: 1));

    try {
      final prefs = await SharedPreferences.getInstance();
      final showOnboarding = prefs.getBool('show_onboarding') ?? true;

      if (showOnboarding) {
        Get.offAllNamed(AppRoutes.onboarding);
      } else {
        Get.offAllNamed(AppRoutes.phoneAuth);
      }
    } catch (e) {
      debugPrint('Error loading preferences: $e');
      // Fallback to onboarding if there's an error
      Get.offAllNamed(AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F5), // Light pink background
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AfroTheme.primaryColor,
                  borderRadius: BorderRadius.circular(60),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.content_cut,
                  color: Colors.white,
                  size: 60,
                ),
              ),
              const SizedBox(height: 30),

              // App name
              const Text(
                'AFRO',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D1B69), // Deep purple
                ),
              ),
              const SizedBox(height: 10),

              const Text(
                'Premium Barber Booking',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6C757D), // Gray
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 50),

              // Loading indicator
              Container(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AfroTheme.primaryColor,
                  ),
                  backgroundColor: Colors.transparent,
                ),
              ),
              const SizedBox(height: 20),

              // Loading text
              const Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6C757D), // Gray
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
