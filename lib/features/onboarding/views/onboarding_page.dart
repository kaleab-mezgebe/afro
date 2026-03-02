import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  final PageController _controller = PageController();
  int _currentPage = 0;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: "Being a Barber is about taking care of the People",
      description:
          "Our skilled barbers are dedicated to providing exceptional grooming experiences that make you look and feel your best.",
      image: "https://picsum.photos/seed/barber1/400/600.jpg",
    ),
    OnboardingData(
      title: "Crafting the Perfect Look is an Art Form",
      description:
          "From classic cuts to modern styles, our barbers master the latest techniques to deliver personalized results.",
      image: "https://picsum.photos/seed/barber2/400/600.jpg",
    ),
    OnboardingData(
      title: "Every Cut Tells a Unique Story",
      description:
          "Your style is your identity. We help you express it with precision cuts and expert care tailored just for you.",
      image: "https://picsum.photos/seed/barber3/400/600.jpg",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              // gradient: LinearGradient(
              //   begin: Alignment.topCenter,
              //   end: Alignment.bottomCenter,
              //   colors: [AppTheme.white, AppTheme.grey100, AppTheme.white],
              //   stops: [0.0, 0.1, 1.0],
              // ),
            ),
          ),

          // Main content
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
              _fadeController.reset();
              _scaleController.reset();
              _fadeController.forward();
              _scaleController.forward();
            },
            itemBuilder: (_, index) {
              return _buildPage(_pages[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingData data) {
    return Column(
      children: [
        /// Top Half - Enhanced Image
        Expanded(
          flex: 1,
          child: Stack(
            children: [
              // Hero image without overlay
              Container(
                width: double.infinity,
                height: double.infinity,
                child: data.image.startsWith('http')
                    ? Image.network(
                        data.image,
                        key: ValueKey(data.image),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImagePlaceholder();
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return _buildImagePlaceholder();
                        },
                      )
                    : Image.asset(
                        data.image,
                        key: ValueKey(data.image),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImagePlaceholder();
                        },
                      ),
              ),

              /// Skip button with glassmorphism effect
              Positioned(
                top: MediaQuery.of(context).padding.top + 20,
                right: 20,
                child: AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: TextButton(
                          onPressed: _completeOnboarding,
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                          ),
                          child: Text(
                            "Skip",
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        /// Bottom Half - Enhanced Content Area
        Expanded(
          flex: 1,
          child: Container(
            decoration: const BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                top: 32,
                bottom: MediaQuery.of(context).padding.bottom + 24,
              ),
              child: Column(
                children: [
                  /// Title with enhanced highlighting
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: AnimatedBuilder(
                        animation: _scaleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: _buildHighlightedTitle(data.title),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// Description with fade-in
                  Expanded(
                    flex: 1,
                    child: AnimatedBuilder(
                      animation: _fadeAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeAnimation.value,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              data.description,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppTheme.textSecondary,
                                height: 1.5,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  /// Enhanced Pagination Indicator
                  _buildPaginationIndicator(),

                  const SizedBox(height: 40),

                  /// Enhanced Circular Next Button
                  _buildCircularButton(),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightedTitle(String title) {
    final List<String> words = title.split(' ');
    final List<String> highlightWords = [
      'Being',
      'People',
      'Crafting',
      'Art',
      'Every',
      'Story',
    ];

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
          height: 1.3,
          letterSpacing: -0.5,
        ),
        children: words.map((word) {
          final isHighlighted = highlightWords.any(
            (highlight) => word.toLowerCase().contains(highlight.toLowerCase()),
          );
          return TextSpan(
            text: word + ' ',
            style: TextStyle(
              color: isHighlighted
                  ? AppTheme.primaryYellow
                  : AppTheme.textPrimary,
              fontSize: isHighlighted ? 36 : 32,
              fontWeight: isHighlighted ? FontWeight.w900 : FontWeight.bold,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPaginationIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            gradient: _currentPage == index ? AppTheme.yellowGradient : null,
            color: _currentPage == index ? null : AppTheme.grey300,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryYellow.withValues(alpha: 0.8),
            AppTheme.primaryYellow.withValues(alpha: 0.6),
          ],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.content_cut, size: 80, color: AppTheme.white),
            SizedBox(height: 16),
            Text(
              'Professional Barber Services',
              style: TextStyle(
                color: AppTheme.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularButton() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              if (_currentPage == _pages.length - 1) {
                _completeOnboarding();
              } else {
                _controller.nextPage(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOutCubic,
                );
              }
            },
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: AppTheme.yellowGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryYellow.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: AppTheme.primaryYellow.withValues(alpha: 0.2),
                    blurRadius: 40,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: AppTheme.black,
                size: 28,
              ),
            ),
          ),
        );
      },
    );
  }

  void _completeOnboarding() {
    HapticFeedback.mediumImpact();
    Get.offAllNamed(AppRoutes.phoneAuth);
  }
}

class OnboardingData {
  final String title;
  final String description;
  final String image;

  OnboardingData({
    required this.title,
    required this.description,
    required this.image,
  });
}
