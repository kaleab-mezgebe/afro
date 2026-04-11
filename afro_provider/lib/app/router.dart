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
import '../features/reviews/presentation/pages/review_management_page.dart';
import '../features/transactions/presentation/pages/transaction_management_page.dart';
import '../core/utils/modern_theme.dart';
import '../core/widgets/modern_navigation.dart';

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
            path: '/transactions',
            builder: (context, state) => const TransactionManagementPage(),
          ),
          GoRoute(
            path: '/reviews',
            builder: (context, state) => const ReviewManagementPage(),
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
      icon: Icons.reviews_outlined,
      selectedIcon: Icons.reviews,
      label: 'Reviews',
      route: '/reviews',
    ),
    NavigationItem(
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      label: 'Users',
      route: '/users',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: widget.child,
      bottomNavigationBar: ModernBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          context.go(_navigationItems[index].route!);
        },
        items: _navigationItems,
      ),
    );
  }
}
