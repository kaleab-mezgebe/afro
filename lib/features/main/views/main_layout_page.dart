import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../home/views/home_page.dart';
import '../../search/views/search_page.dart';
import '../../profile/views/settings_page.dart';
import '../../appointments/views/booking_history_page.dart';
import '../../appointments/views/booking_service_page.dart';
import '../../favorites/views/favorites_page.dart';
import '../controllers/main_controller.dart';
import '../../../core/theme/app_theme.dart';

class MainLayoutPage extends GetView<MainController> {
  const MainLayoutPage({super.key});

  Widget _buildBookingTabs() {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.grey50,
          elevation: 0,
          bottom: TabBar(
            onTap: (index) => controller.changeBookingTab(index),
            indicatorColor: AppTheme.primaryYellow,
            labelColor: AppTheme.textSecondary,
            unselectedLabelColor: AppTheme.textMuted,
            tabs: const [
              Tab(icon: Icon(Icons.history, size: 20), text: 'History'),
              Tab(icon: Icon(Icons.calendar_today, size: 20), text: 'Book'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            BookingHistoryPage(),
            BookingServicePage(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: [
            const HomePage(),
            const SearchPage(),
            const FavoritesPage(),
            _buildBookingTabs(),
            SettingsPage(),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: AppTheme.grey300.withValues(alpha: 0.5),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: BottomNavigationBar(
              currentIndex: controller.currentIndex.value,
              onTap: (index) {
                controller.changePage(index);
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              selectedItemColor: AppTheme.primaryYellow,
              unselectedItemColor: AppTheme.grey500,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              elevation: 0,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search_outlined),
                  activeIcon: Icon(Icons.search),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite_outline),
                  activeIcon: Icon(Icons.favorite),
                  label: 'Favorites',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today_outlined),
                  activeIcon: Icon(Icons.calendar_today),
                  label: 'Bookings',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
