import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'core/theme/modern_theme.dart';
import 'core/navigation/modern_navigation.dart';
import 'core/widgets/modern_cards.dart';
import 'features/shop/presentation/pages/modern_shop_management_page.dart';
import 'features/services/presentation/pages/modern_service_management_page.dart';
import 'features/staff/presentation/pages/modern_staff_management_page.dart';

class ModernAfroProviderApp extends ConsumerStatefulWidget {
  const ModernAfroProviderApp({super.key});

  @override
  ConsumerState<ModernAfroProviderApp> createState() =>
      _ModernAfroProviderAppState();
}

class _ModernAfroProviderAppState extends ConsumerState<ModernAfroProviderApp>
    with TickerProviderStateMixin {
  late AnimationController _splashController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _splashController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _splashController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _splashController,
      curve: Curves.elasticOut,
    ));

    _splashController.forward().then((_) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const ModernMainScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
          transitionDuration: ModernAnimations.medium,
        ),
      );
    });
  }

  @override
  void dispose() {
    _splashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ModernTheme.lightTheme,
      darkTheme: ModernTheme.darkTheme,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: ModernTheme.primary,
        body: Center(
          child: AnimatedBuilder(
            animation: _splashController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Modern Logo
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: ModernTheme.primaryGradient,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: ModernTheme.primary.withOpacity(0.3),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.store,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'AFRO Provider',
                        style: ModernTheme.displayLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Modern Shop Management',
                        style: ModernTheme.bodyLarge.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 48),
                      ModernLoadingIndicator(
                        color: Colors.white,
                        size: 32,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class ModernMainScreen extends ConsumerStatefulWidget {
  const ModernMainScreen({super.key});

  @override
  ConsumerState<ModernMainScreen> createState() => _ModernMainScreenState();
}

class _ModernMainScreenState extends ConsumerState<ModernMainScreen> {
  final List<ModernNavItem> _navigationItems = [
    const ModernNavItem(
      label: 'Dashboard',
      icon: Icons.dashboard,
      page: ModernDashboardPage(),
      color: ModernTheme.primary,
    ),
    const ModernNavItem(
      label: 'Shops',
      icon: Icons.store,
      page: ModernShopManagementPage(),
      color: ModernTheme.primary,
    ),
    const ModernNavItem(
      label: 'Services',
      icon: Icons.content_cut,
      page: ModernServiceManagementPage(),
      color: ModernTheme.secondary,
    ),
    const ModernNavItem(
      label: 'Staff',
      icon: Icons.people,
      page: ModernStaffManagementPage(),
      color: ModernTheme.info,
    ),
    const ModernNavItem(
      label: 'Customers',
      icon: Icons.person,
      page: ModernCustomersPage(),
      color: ModernTheme.secondary,
    ),
    const ModernNavItem(
      label: 'Analytics',
      icon: Icons.analytics,
      page: ModernAnalyticsPage(),
      color: ModernTheme.info,
    ),
    const ModernNavItem(
      label: 'Settings',
      icon: Icons.settings,
      page: ModernSettingsPage(),
      color: ModernTheme.warning,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ModernAppShell(
      child: _navigationItems.first.page, // Use first page as child
      navigationItems: _navigationItems,
      initialIndex: 0,
    );
  }
}

// Modern Dashboard Page
class ModernDashboardPage extends StatelessWidget {
  const ModernDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ModernDashboardLayout(
      title: 'Dashboard',
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Notifications coming soon'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile coming soon'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            ModernGradientCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back!',
                    style: ModernTheme.headlineMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Here\'s what\'s happening with your shops today',
                    style: ModernTheme.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stats Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                ModernStatCard(
                  title: 'Total Shops',
                  value: '12',
                  icon: Icons.store,
                  iconColor: ModernTheme.primary,
                ),
                ModernStatCard(
                  title: 'Active Shops',
                  value: '8',
                  icon: Icons.check_circle,
                  iconColor: ModernTheme.success,
                ),
                ModernStatCard(
                  title: 'Services',
                  value: '25',
                  icon: Icons.content_cut,
                  iconColor: ModernTheme.secondary,
                ),
                ModernStatCard(
                  title: 'Staff',
                  value: '18',
                  icon: Icons.people,
                  iconColor: ModernTheme.info,
                ),
                ModernStatCard(
                  title: 'Customers',
                  value: '1,234',
                  icon: Icons.person,
                  iconColor: ModernTheme.secondary,
                ),
                ModernStatCard(
                  title: 'Revenue',
                  value: '\$12,345',
                  icon: Icons.monetization_on,
                  iconColor: ModernTheme.warning,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Activity
            Text(
              'Recent Activity',
              style: ModernTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            ModernGlassCard(
              child: Column(
                children: [
                  _buildActivityItem(
                    'New shop created',
                    'Afro Cuts Premium',
                    Icons.store,
                    ModernTheme.primary,
                  ),
                  const Divider(height: 1),
                  _buildActivityItem(
                    'Customer booked',
                    'John Doe - Haircut',
                    Icons.person,
                    ModernTheme.secondary,
                  ),
                  const Divider(height: 1),
                  _buildActivityItem(
                    'Payment received',
                    '\$45.00',
                    Icons.monetization_on,
                    ModernTheme.success,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
      String title, String subtitle, IconData icon, Color color) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: ModernTheme.titleMedium),
      subtitle: Text(subtitle, style: ModernTheme.bodyMedium),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}

// Modern Customers Page
class ModernCustomersPage extends StatelessWidget {
  const ModernCustomersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ModernDashboardLayout(
      title: 'Customers',
      floatingActionButton: ModernFab(
        icon: Icons.person_add,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Add customer coming soon'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
      child: const Center(
        child: ModernEmptyState(
          title: 'Customers Management',
          subtitle: 'Customer features coming soon',
          icon: Icons.people,
        ),
      ),
    );
  }
}

// Modern Analytics Page
class ModernAnalyticsPage extends StatelessWidget {
  const ModernAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: ModernEmptyState(
        title: 'Analytics Dashboard',
        subtitle: 'Advanced analytics coming soon',
        icon: Icons.analytics,
      ),
    );
  }
}

// Modern Settings Page
class ModernSettingsPage extends StatelessWidget {
  const ModernSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: ModernEmptyState(
        title: 'Settings',
        subtitle: 'Global settings coming soon',
        icon: Icons.settings,
      ),
    );
  }
}

// Main App Entry Point
void runModernApp() {
  runApp(
    const ProviderScope(
      child: ModernAfroProviderApp(),
    ),
  );
}
