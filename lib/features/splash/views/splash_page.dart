import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/auth_api_service.dart';
import '../../../routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/afro_theme.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _patternController;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _patternFade;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _navigateToOnboarding();
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _patternController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    _patternFade = Tween<double>(begin: 0.0, end: 0.3).animate(
      CurvedAnimation(parent: _patternController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() async {
    await _logoController.forward();
    _patternController.forward();
  }

  void _navigateToOnboarding() async {
    // Start a 3-second timer and the SharedPreferences initialization in parallel
    final stopwatch = Stopwatch()..start();

    bool showOnboarding = true;
    try {
      final prefs = await SharedPreferences.getInstance().timeout(
        const Duration(seconds: 2),
        onTimeout: () => throw Exception('Timeout'),
      );
      showOnboarding = prefs.getBool('show_onboarding') ?? true;
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    }

    // Check if user is already logged in to Firebase
    final currentUser = FirebaseAuth.instance.currentUser;
    bool isBackendVerified = false;

    debugPrint('[DEBUG] Current Firebase User: ${currentUser?.uid}');

    if (currentUser != null && !showOnboarding) {
      try {
        debugPrint(
          '[DEBUG] Starting backend verification for existing session',
        );
        // We need to ensure the user exists in our SQL backend too
        final authApiService = Get.find<AuthApiService>();
        final idToken = (await currentUser.getIdToken(true)) ?? '';
        debugPrint('[DEBUG] ID Token obtained, verifying with backend...');
        await authApiService.verifyToken(idToken);
        isBackendVerified = true;
        debugPrint('[DEBUG] Backend verification result: $isBackendVerified');
      } catch (e) {
        debugPrint('[ERROR] Backend verification failed: $e');
        // If backend verification fails, we shouldn't proceed as verified
        isBackendVerified = false;
      }
    }

    // Ensure we wait at least 3 seconds total
    final remainingTime = 3000 - stopwatch.elapsedMilliseconds;
    if (remainingTime > 0) {
      await Future.delayed(Duration(milliseconds: remainingTime));
    }

    if (showOnboarding) {
      Get.offAllNamed(AppRoutes.onboarding);
    } else if (currentUser != null && isBackendVerified) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offAllNamed(AppRoutes.phoneAuth);
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _patternController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style for black status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(
        0xFFFFF5F5,
      ), // Light pink instead of pure white
      body: Stack(
        children: [
          // Background pattern - positioned directly in Stack
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _patternController,
              builder: (context, child) {
                return Opacity(
                  opacity: _patternFade.value,
                  child: SizedBox(
                    height: 150,
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 20,
                      runSpacing: 15,
                      children: [
                        _buildPatternIcon(Icons.content_cut),
                        _buildPatternIcon(Icons.brush),
                        _buildPatternIcon(Icons.face),
                        _buildPatternIcon(Icons.spa),
                        _buildPatternIcon(Icons.auto_fix_high),
                        _buildPatternIcon(Icons.style),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Main content
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),

                  // Animated Logo
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _logoFade,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: _buildBarberLogo(),
                        ),
                      );
                    },
                  ),

                  const Spacer(flex: 3),

                  // Design credit
                  _buildDesignCredit(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarberLogo() {
    return SizedBox(
      width: 200,
      height: 200,
      child: Image.asset(
        'assets/images/logo.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Logo asset error: $error');
          // Fallback to text logo if image fails
          return Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: AfroTheme.primaryColor,
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Center(
              child: Text(
                'AFRO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPatternIcon(IconData icon) {
    return Icon(
      icon,
      size: 24,
      color: AppTheme.primaryYellow.withValues(alpha: 0.15),
    );
  }

  Widget _buildDesignCredit() {
    return Text(
      'Design by Kaleab M.',
      style: AppTheme.caption.copyWith(
        color: AppTheme.textSecondary,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
