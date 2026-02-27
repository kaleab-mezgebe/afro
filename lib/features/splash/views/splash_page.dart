import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';

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

  void _navigateToOnboarding() {
    Future.delayed(const Duration(seconds: 3), () {
      Get.offAllNamed(AppRoutes.onboarding);
    });
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
        statusBarColor: AppTheme.black,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: AppTheme.white,
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
                  child: Container(
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
    return Container(
      width: 200,
      height: 200,
      decoration: const BoxDecoration(
        color: AppTheme.primaryYellow,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.content_cut, size: 80, color: AppTheme.white),
    );
  }

  Widget _buildBackgroundPattern() {
    return Positioned(
      bottom: 100,
      left: 0,
      right: 0,
      child: Container(
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
  }

  Widget _buildPatternIcon(IconData icon) {
    return Icon(icon, size: 24, color: AppTheme.primaryYellow.withOpacity(0.2));
  }

  Widget _buildDesignCredit() {
    return Text(
      'Design by Addbrain',
      style: AppTheme.caption.copyWith(
        color: AppTheme.textMuted,
        fontWeight: FontWeight.w300,
      ),
    );
  }
}
