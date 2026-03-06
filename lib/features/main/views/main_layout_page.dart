import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../home/views/home_page.dart';
import '../../search/views/search_page.dart';
import '../../profile/views/settings_page.dart';
import '../../booking/views/booking_history_page.dart';
import '../../booking/views/booking_service_page.dart';
import '../controllers/main_controller.dart';
import '../../../core/theme/app_theme.dart';

class MainLayoutPage extends GetView<MainController> {
  const MainLayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: [
            HomePage(),
            SearchPage(),
            BookingHistoryPage(),
            BookingServicePage(),
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
                color: AppTheme.grey300.withOpacity(0.5),
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
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history),
                  label: 'Bookings',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today),
                  label: 'Book',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
