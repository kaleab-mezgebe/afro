import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../widgets/home_header.dart';
import '../widgets/promo_banner.dart';
import '../widgets/category_list.dart';
import '../widgets/specialist_card.dart';
import '../../../core/theme/app_theme.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Greeting, Notifications, Profile)
                const HomeHeader(),
                const SizedBox(height: 24),

                // Promotional Banner
                const PromoBanner(),
                const SizedBox(height: 32),

                // Categories
                const CategoryList(),
                const SizedBox(height: 32),

                // Top Specialists Section
                _buildSpecialistsGrid(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialistsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Top Specialists',
              style: TextStyle(
                color: AppTheme.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'See All',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          // Loading state
          if (controller.isLoading.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: CircularProgressIndicator(color: AppTheme.primaryYellow),
              ),
            );
          }

          // Error state with retry
          if (controller.error.value.isNotEmpty &&
              controller.allSpecialists.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Icon(
                      Icons.wifi_off_rounded,
                      size: 48,
                      color: AppTheme.grey300,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Could not load specialists',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: controller.fetchSpecialists,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Retry'),
                      style: AppTheme.primaryButton,
                    ),
                  ],
                ),
              ),
            );
          }

          final specialists = controller.filteredSpecialists;
          if (specialists.isEmpty) {
            return _buildEmptyState();
          }
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.65,
            ),
            itemCount: specialists.length,
            itemBuilder: (context, index) {
              return SpecialistCard(specialist: specialists[index]);
            },
          );
        }),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.search_off_rounded, size: 64, color: AppTheme.grey300),
          const SizedBox(height: 16),
          Text(
            'No specialists found',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
