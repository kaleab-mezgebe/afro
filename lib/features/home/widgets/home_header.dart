import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';

class HomeHeader extends GetView<HomeController> {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good Morning!',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Kaleab Mezgebe',
              style: TextStyle(
                color: AppTheme.primaryYellow,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Row(
          children: [
            _buildFavoritesButton(),
            const SizedBox(width: 12),
            Obx(() => _buildNotificationBell()),
            const SizedBox(width: 12),
          ],
        ),
      ],
    );
  }

  Widget _buildNotificationBell() {
    return InkWell(
      onTap: () => Get.toNamed(AppRoutes.notifications),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.grey100,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Stack(
          children: [
            const Center(
              child: Icon(
                Icons.notifications_none_rounded,
                color: AppTheme.black,
                size: 24,
              ),
            ),
            if (controller.notificationCount > 0)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesButton() {
    return InkWell(
      onTap: () => Get.toNamed(AppRoutes.favorites),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.grey100,
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Center(
          child: Icon(
            Icons.favorite_outline_rounded,
            color: AppTheme.black,
            size: 24,
          ),
        ),
      ),
    );
  }
}