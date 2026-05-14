import 'package:flutter/material.dart';
import '../theme/modern_theme.dart';
import '../../features/shop/presentation/pages/modern_shop_management_page.dart';

// Modern Navigation Item
class ModernNavItem {
  final String label;
  final IconData icon;
  final Widget page;
  final Color? color;

  const ModernNavItem({
    required this.label,
    required this.icon,
    required this.page,
    this.color,
  });
}

// Modern Navigation Rail
class ModernNavigationRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<ModernNavItem> items;
  final bool extended;

  const ModernNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.items,
    this.extended = false,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      extended: extended,
      backgroundColor: ModernTheme.surface,
      destinations: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return NavigationRailDestination(
          icon: Icon(
            item.icon,
            color: selectedIndex == index
                ? (item.color ?? ModernTheme.primary)
                : ModernTheme.onSurfaceVariant,
          ),
          selectedIcon: Icon(
            item.icon,
            color: item.color ?? ModernTheme.primary,
          ),
          label: Text(item.label),
        );
      }).toList(),
      labelType: extended ? null : NavigationRailLabelType.all,
    );
  }
}

// Modern Bottom Navigation - Improved accessibility
class ModernBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<ModernNavItem> items;

  const ModernBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90, // Increased from default for better touch targets
      decoration: BoxDecoration(
        color: ModernTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onDestinationSelected,
        backgroundColor: ModernTheme.surface,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: ModernTheme.primary,
        unselectedItemColor: ModernTheme.onSurfaceVariant,
        selectedFontSize: 13, // Increased from default
        unselectedFontSize: 12, // Increased from default
        iconSize: 26, // Increased from default for better visibility
        items: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return BottomNavigationBarItem(
            icon: Icon(item.icon),
            activeIcon: Icon(
              item.icon,
              color: item.color ?? ModernTheme.primary,
            ),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }
}

// Modern App Shell with Adaptive Navigation
class ModernAppShell extends StatefulWidget {
  final Widget child;
  final List<ModernNavItem> navigationItems;
  final int initialIndex;

  const ModernAppShell({
    super.key,
    required this.child,
    required this.navigationItems,
    this.initialIndex = 0,
  });

  @override
  State<ModernAppShell> createState() => _ModernAppShellState();
}

class _ModernAppShellState extends State<ModernAppShell> {
  late int _selectedIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width >= 1200;
    final isMediumScreen = MediaQuery.of(context).size.width >= 800;

    if (isLargeScreen) {
      // Desktop layout with navigation rail
      return Scaffold(
        body: Row(
          children: [
            ModernNavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
                _pageController.animateToPage(
                  index,
                  duration: ModernAnimations.medium,
                  curve: ModernAnimations.smoothCurve,
                );
              },
              items: widget.navigationItems,
              extended: true,
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                children:
                    widget.navigationItems.map((item) => item.page).toList(),
              ),
            ),
          ],
        ),
      );
    } else if (isMediumScreen) {
      // Tablet layout with navigation rail
      return Scaffold(
        body: Row(
          children: [
            ModernNavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
                _pageController.animateToPage(
                  index,
                  duration: ModernAnimations.medium,
                  curve: ModernAnimations.smoothCurve,
                );
              },
              items: widget.navigationItems,
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                children:
                    widget.navigationItems.map((item) => item.page).toList(),
              ),
            ),
          ],
        ),
      );
    } else {
      // Mobile layout with bottom navigation
      return Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: widget.navigationItems.map((item) => item.page).toList(),
        ),
        bottomNavigationBar: ModernBottomNavigation(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
            _pageController.animateToPage(
              index,
              duration: ModernAnimations.medium,
              curve: ModernAnimations.smoothCurve,
            );
          },
          items: widget.navigationItems,
        ),
      );
    }
  }
}

// Modern Dashboard Layout
class ModernDashboardLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  const ModernDashboardLayout({
    super.key,
    required this.child,
    required this.title,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernTheme.background,
      appBar: AppBar(
        title: Text(
          title,
          style: ModernTheme.headlineMedium,
        ),
        actions: actions,
        backgroundColor: ModernTheme.surface,
        elevation: 0,
        centerTitle: false,
      ),
      body: child,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

// Modern Tab Bar - Improved accessibility
class ModernTabBar extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const ModernTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56, // Increased from 48 for better touch targets
      decoration: BoxDecoration(
        color: ModernTheme.surface,
        borderRadius: BorderRadius.circular(16), // Increased from 12
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(6), // Increased from 4
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 6), // Increased from 4
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onTabSelected(index),
                borderRadius: BorderRadius.circular(12),
                splashColor: ModernTheme.primary.withValues(alpha: 0.1),
                highlightColor: ModernTheme.primary.withValues(alpha: 0.05),
                child: AnimatedContainer(
                  duration: ModernAnimations.fast,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 12), // Increased padding
                  decoration: BoxDecoration(
                    color:
                        isSelected ? ModernTheme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tabs[index],
                    style: ModernTheme.labelMedium.copyWith(
                      color: isSelected
                          ? Colors.white
                          : ModernTheme.onSurfaceVariant,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 14, // Increased from default
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Modern Drawer - Improved accessibility
class ModernDrawer extends StatelessWidget {
  final List<ModernNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const ModernDrawer({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: ModernTheme.surface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header
          Container(
            height: 220, // Increased from 200
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: ModernTheme.primaryGradient,
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.store,
                    color: Colors.white,
                    size: 56, // Increased from 48
                  ),
                  SizedBox(height: 12),
                  Text(
                    'AFRO Provider',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22, // Increased from 20
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Navigation Items
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  onItemSelected(index);
                },
                splashColor: ModernTheme.primary.withValues(alpha: 0.1),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12), // Increased padding
                  leading: Icon(
                    item.icon,
                    color: selectedIndex == index
                        ? (item.color ?? ModernTheme.primary)
                        : ModernTheme.onSurfaceVariant,
                    size: 26, // Increased from default
                  ),
                  title: Text(
                    item.label,
                    style: ModernTheme.labelLarge.copyWith(
                      fontSize: 15, // Increased from default
                    ),
                  ),
                  selected: index == selectedIndex,
                  selectedTileColor:
                      (item.color ?? ModernTheme.primary).withOpacity(0.1),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
