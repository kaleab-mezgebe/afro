import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: "Being a Barber is about taking care of People",
      description:
          "Experience the art of grooming in a premium salon environment designed for your comfort and style.",
      image:
          "https://images.unsplash.com/photo-1585747860715-2ba37e788b70?q=80&w=800&auto=format&fit=crop",
    ),
    OnboardingData(
      title: "Crafting the Perfect Look is an Art Form",
      description:
          "Our master barbers use precision techniques to deliver personalized results that define your unique identity.",
      image:
          "https://images.unsplash.com/photo-1621605815971-fbc98d665033?q=80&w=800&auto=format&fit=crop",
    ),
    OnboardingData(
      title: "Every Cut Tells a Unique Story",
      description:
          "Your journey to a better look starts here. Book your next appointment with just a few taps.",
      image:
          "https://images.unsplash.com/photo-1503951914875-452162b0f3f1?q=80&w=800&auto=format&fit=crop",
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
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity == null) return;

          // Swipe Left (Go Next)
          if (details.primaryVelocity! < -500) {
            HapticFeedback.lightImpact();
            if (_currentPage == _pages.length - 1) {
              _completeOnboarding();
            } else {
              setState(() {
                _currentPage++;
              });
            }
          }

          // Swipe Right (Go Previous)
          if (details.primaryVelocity! > 500) {
            HapticFeedback.lightImpact();
            if (_currentPage > 0) {
              setState(() {
                _currentPage--;
              });
            }
          }
        },
        child: _buildPage(_pages[_currentPage]),
      ),
    );
  }

  Widget _buildPage(OnboardingData data) {
    return Column(
      children: [
        /// Top Half - Enhanced Image with Transition
        Expanded(
          flex: 1,
          child: Stack(
            children: [
              // Hero image with CrossFade/Switcher + Scale Effect
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 1200),
                transitionBuilder: (child, animation) {
                  final scaleAnimation = Tween<double>(begin: 1.1, end: 1.0)
                      .animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      );
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: scaleAnimation, child: child),
                  );
                },
                child: SizedBox(
                  key: ValueKey(data.image),
                  width: double.infinity,
                  height: double.infinity,
                  child: data.image.startsWith('http')
                      ? Image.network(
                          data.image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildImagePlaceholder(),
                        )
                      : Image.asset(
                          data.image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildImagePlaceholder(),
                        ),
                ),
              ),

              /// Skip button
              Positioned(
                top: MediaQuery.of(context).padding.top + 20,
                right: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
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
                    child: const Text(
                      "Skip",
                      style: TextStyle(
                        color: AppTheme.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
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
                  /// Title with premium transition
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 800),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position:
                                  Tween<Offset>(
                                    begin: const Offset(0, 0.1),
                                    end: Offset.zero,
                                  ).animate(
                                    CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOutBack,
                                    ),
                                  ),
                              child: ScaleTransition(
                                scale: Tween<double>(begin: 0.95, end: 1.0)
                                    .animate(
                                      CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOutBack,
                                      ),
                                    ),
                                child: child,
                              ),
                            ),
                          );
                        },
                        child: _buildHighlightedTitle(
                          data.title,
                          key: ValueKey(data.title),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// Description with premium transition
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 800),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position:
                                  Tween<Offset>(
                                    begin: const Offset(0, 0.1),
                                    end: Offset.zero,
                                  ).animate(
                                    CurvedAnimation(
                                      parent: animation,
                                      curve: const Interval(
                                        0.2,
                                        1.0,
                                        curve: Curves.easeOut,
                                      ),
                                    ),
                                  ),
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          data.description,
                          key: ValueKey(data.description),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppTheme.textSecondary,
                            height: 1.5,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  /// Pagination Indicator
                  _buildPaginationIndicator(),

                  const SizedBox(height: 40),

                  /// Circular Next Button
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

  Widget _buildHighlightedTitle(String title, {Key? key}) {
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
      key: key,
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(
          fontSize: 28,
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
            text: '$word ',
            style: TextStyle(
              color: isHighlighted
                  ? AppTheme.primaryYellow
                  : AppTheme.textPrimary,
              fontSize: isHighlighted ? 30 : 28,
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
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (_currentPage == _pages.length - 1) {
          _completeOnboarding();
        } else {
          setState(() {
            _currentPage++;
          });
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
          ],
        ),
        child: const Icon(
          Icons.arrow_forward_rounded,
          color: AppTheme.black,
          size: 28,
        ),
      ),
    );
  }

  void _completeOnboarding() async {
    HapticFeedback.mediumImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_onboarding', false);
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
