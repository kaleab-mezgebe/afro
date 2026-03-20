import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../home/views/home_page.dart';
import '../../search/views/search_page.dart';
import '../../profile/views/profile_page.dart';
import '../../appointments/views/booking_history_page.dart';
import '../../appointments/views/booking_service_page.dart';
import '../../favorites/views/favorites_page.dart';
import '../controllers/main_controller.dart';
import '../../../core/theme/app_theme.dart';

class MainLayoutPage extends GetView<MainController> {
  const MainLayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: [
            const HomePage(),
            const SearchPage(),
            const FavoritesPage(),
            _buildBookingTabs(),
            const ProfilePage(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBookingTabs() {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text('MY BOOKINGS', style: TextStyle(color: AppTheme.black, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
          centerTitle: true,
          bottom: TabBar(
            onTap: (index) => controller.changeBookingTab(index),
            indicatorColor: AppTheme.primaryYellow,
            indicatorWeight: 4,
            labelColor: AppTheme.black,
            unselectedLabelColor: AppTheme.greyMedium,
            labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
            tabs: const [
              Tab(text: 'HISTORY'),
              Tab(text: 'BOOK NEW'),
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

  Widget _buildBottomBar() {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Obx(() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, 'Home'),
            _buildNavItem(1, Icons.search_rounded, Icons.search_rounded, 'Search'),
            _buildNavItem(2, Icons.favorite_outline_rounded, Icons.favorite_rounded, 'Saved'),
            _buildNavItem(3, Icons.calendar_today_outlined, Icons.calendar_today_rounded, 'Book'),
            _buildNavItem(4, Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
          ],
        ),
      )),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = controller.currentIndex.value == index;
    return InkWell(
      onTap: () => controller.changePage(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryYellow : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppTheme.black : AppTheme.greyMedium,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
              color: isSelected ? AppTheme.black : AppTheme.greyMedium,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
