import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';

class HomeHeader extends GetView<HomeController> {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Good Morning,',
                  style: TextStyle(
                    color: AppTheme.greyMedium,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kaleab Mezgebe',
                  style: const TextStyle(
                    color: AppTheme.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                _buildCircularButton(
                  Icons.notifications_none_rounded,
                  () => Get.toNamed(AppRoutes.notifications),
                ),
                const SizedBox(width: 12),
                _buildCircularButton(
                  Icons.favorite_outline_rounded,
                  () => Get.toNamed(AppRoutes.favorites),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Modern Premium Search Bar
        GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.search),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  color: AppTheme.black,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Search for salons, barbers...',
                    style: TextStyle(color: AppTheme.greyMedium, fontSize: 16),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryYellow,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: AppTheme.black,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCircularButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        splashColor: AppTheme.primaryYellow.withValues(alpha: 0.2),
        highlightColor: AppTheme.primaryYellow.withValues(alpha: 0.1),
        child: Container(
          width: 52, // Increased from 48 for better touch target
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFEEEEEE)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: AppTheme.black, size: 24),
        ),
      ),
    );
  }
}
