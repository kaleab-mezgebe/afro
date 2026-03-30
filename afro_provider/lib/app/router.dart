import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/customers/presentation/pages/customer_management_page.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/auth/presentation/pages/auth_page.dart';
import '../features/shop/presentation/pages/shop_management_page.dart';
import '../features/staff/presentation/pages/staff_management_page.dart';
import '../features/appointments/presentation/pages/appointments_page.dart';
import '../features/services/presentation/pages/service_management_page.dart';
import '../features/analytics/presentation/pages/analytics_page.dart';
import '../features/profile/presentation/pages/provider_profile_page.dart';
import '../core/utils/app_theme.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/auth',
    routes: [
      // Authentication Routes
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthPage(),
      ),

      // Main App Routes (Shell Navigation)
      ShellRoute(
        builder: (context, state, child) {
          return MainNavigation(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/customers',
            builder: (context, state) => const CustomerManagementPage(),
          ),
          GoRoute(
            path: '/appointments',
            builder: (context, state) => const AppointmentsPage(),
          ),
          GoRoute(
            path: '/shop',
            builder: (context, state) => const ShopManagementPage(),
          ),
          GoRoute(
            path: '/staff',
            builder: (context, state) => const StaffManagementPage(),
          ),
          GoRoute(
            path: '/services',
            builder: (context, state) => const ServiceManagementPage(),
          ),
          GoRoute(
            path: '/analytics',
            builder: (context, state) => const AnalyticsPage(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProviderProfilePage(),
          ),
        ],
      ),
    ],
  );
}

class MainNavigation extends StatefulWidget {
  final Widget child;
  const MainNavigation({super.key, required this.child});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      label: 'Home',
      route: '/dashboard',
    ),
    NavigationItem(
      icon: Icons.event_note_outlined,
      selectedIcon: Icons.event_note,
      label: 'Calendar',
      route: '/appointments',
    ),
    NavigationItem(
      icon: Icons.store_outlined,
      selectedIcon: Icons.store_mall_directory_rounded,
      label: 'Salon',
      route: '/shop',
    ),
    NavigationItem(
      icon: Icons.content_cut_outlined,
      selectedIcon: Icons.content_cut_rounded,
      label: 'Salon Tools',
      route: '/services',
    ),
    NavigationItem(
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      label: 'Admin',
      route: '/profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: widget.child,
      bottomNavigationBar: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 30,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _navigationItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = _currentIndex == index;

              return InkWell(
                onTap: () {
                  setState(() => _currentIndex = index);
                  context.go(item.route);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? AppTheme.primaryYellow : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        isSelected ? item.selectedIcon : item.icon,
                        color:
                            isSelected ? AppTheme.black : AppTheme.greyMedium,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color:
                            isSelected ? AppTheme.black : AppTheme.greyMedium,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;

  NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
  });
}
