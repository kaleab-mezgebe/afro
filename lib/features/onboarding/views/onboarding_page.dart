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

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: "Being a Barber is about taking care of the People",
      description:
          "Our skilled barbers are dedicated to providing exceptional grooming experiences that make you look and feel your best.",
      image:
          "https://images.unsplash.com/photo-1621605815971-fbc98d665033?w=1080",
    ),
    OnboardingData(
      title: "Crafting the Perfect Look is an Art Form",
      description:
          "From classic cuts to modern styles, our barbers master the latest techniques to deliver personalized results.",
      image:
          "https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=1080",
    ),
    OnboardingData(
      title: "Every Cut Tells a Unique Story",
      description:
          "Your style is your identity. We help you express it with precision cuts and expert care tailored just for you.",
      image:
          "https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=1080",
    ),
  ];

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
      body: PageView.builder(
        controller: _controller,
        itemCount: _pages.length,
        onPageChanged: (index) {
          setState(() => _currentPage = index);
        },
        itemBuilder: (_, index) {
          return _buildPage(_pages[index]);
        },
      ),
    );
  }

  Widget _buildPage(OnboardingData data) {
    return Column(
      children: [
        /// Top Half - Image
        Expanded(
          flex: 1,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            child: ColorFiltered(
              colorFilter: const ColorFilter.matrix(<double>[
                0.2126,
                0.7152,
                0.0722,
                0,
                0,
                0.2126,
                0.7152,
                0.0722,
                0,
                0,
                0.2126,
                0.7152,
                0.0722,
                0,
                0,
                0,
                0,
                0,
                1,
                0,
              ]),
              child: Stack(
                children: [
                  Image.network(
                    data.image,
                    key: ValueKey(data.image),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),

                  /// Skip button at top right
                  Positioned(
                    top: MediaQuery.of(Get.context!).padding.top + 16,
                    right: 16,
                    child: TextButton(
                      onPressed: _completeOnboarding,
                      child: const Text(
                        "Skip",
                        style: TextStyle(
                          color: AppTheme.primaryYellow, // Yellow color
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        /// Bottom Half - White Content Area
        Expanded(
          flex: 1,
          child: Container(
            color: AppTheme.white,
            child: Padding(
              padding: EdgeInsets.only(
                top: 16,
                bottom: MediaQuery.of(Get.context!).padding.bottom + 8,
              ),
              child: Column(
                children: [
                  /// Title with highlighted words
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: _buildHighlightedTitle(data.title),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// Description
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        data.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// Pagination Indicator
                  _buildPaginationIndicator(),

                  const SizedBox(height: 24),

                  /// Circular Next Button
                  _buildCircularButton(),

                  const SizedBox(height: 8),
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
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
          height: 1.2,
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
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? AppTheme
                      .primaryYellow // Yellow
                : AppTheme.grey300, // Light grey
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildCircularButton() {
    return GestureDetector(
      onTap: () {
        if (_currentPage == _pages.length - 1) {
          _completeOnboarding();
        } else {
          _controller.nextPage(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: const BoxDecoration(
          color: AppTheme.primaryYellow, // Yellow
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.arrow_forward, color: AppTheme.white, size: 32),
      ),
    );
  }

  void _completeOnboarding() {
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
