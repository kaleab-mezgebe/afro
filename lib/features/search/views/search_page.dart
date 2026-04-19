import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/search_controller.dart' as search_ctrl;
import '../../../domain/entities/provider.dart';

// ─── Palette ────────────────────────────────────────────────────────────────
const _yellow = AppTheme.primaryYellow;
const _black = AppTheme.black;
const _bg = Color(0xFFF7F7F7);

class SearchPage extends GetView<search_ctrl.SearchController> {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _bg,
        floatingActionButton: Obx(
          () => FloatingActionButton.extended(
            heroTag: 'search_map_fab',
            onPressed: controller.toggleMap,
            backgroundColor: _yellow,
            foregroundColor: _black,
            elevation: 4,
            icon: Icon(
              controller.showMap.value ? Icons.list_rounded : Icons.map_rounded,
            ),
            label: Text(
              controller.showMap.value ? 'List View' : 'Map View',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              _Header(controller: controller),
              _CategoryStrip(controller: controller),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) return _LoadingSkeleton();
                  if (controller.showMap.value)
                    return _MapView(controller: controller);
                  if (controller.query.value.isEmpty &&
                      !controller.hasActiveFilters) {
                    return _DiscoverView(controller: controller);
                  }
                  if (controller.filteredProviders.isEmpty)
                    return _EmptyState(controller: controller);
                  return _ResultsList(controller: controller);
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Header ─────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final search_ctrl.SearchController controller;
  const _Header({required this.controller});

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: back button + title + filter
          Row(
            children: [
              if (canPop)
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _bg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: _black,
                    ),
                  ),
                ),
              if (canPop) const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Explore Services',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: _black,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Find your perfect specialist',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.grey500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Search bar — pixel-perfect match to home page style
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: _black, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    onChanged: controller.updateQuery,
                    onSubmitted: (_) => controller.performSearch(),
                    style: const TextStyle(fontSize: 15, color: _black),
                    decoration: const InputDecoration(
                      hintText: 'Search for salons, barbers...',
                      hintStyle: TextStyle(
                        color: AppTheme.greyMedium,
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),

                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                Obx(
                  () => GestureDetector(
                    onTap: () => _showFilterSheet(context, controller),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryYellow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.tune_rounded,
                            color: _black,
                            size: 18,
                          ),
                        ),
                        if (controller.activeFilterCount > 0)
                          Positioned(
                            top: -4,
                            right: -4,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${controller.activeFilterCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Quick chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _QuickChip(
                  label: 'Open Now',
                  icon: Icons.access_time_rounded,
                  value: controller.onlyOpenNow,
                  onTap: controller.toggleOpenNow,
                ),
                const SizedBox(width: 8),
                _QuickChip(
                  label: 'Top Rated',
                  icon: Icons.star_rounded,
                  value: controller.onlyFeatured,
                  onTap: controller.toggleFeatured,
                ),
                const SizedBox(width: 8),
                _QuickChip(
                  label: 'Verified',
                  icon: Icons.verified_rounded,
                  value: controller.onlyVerified,
                  onTap: controller.toggleVerified,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final RxBool value;
  final VoidCallback onTap;
  const _QuickChip({
    required this.label,
    required this.icon,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: value.value ? _yellow : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: value.value ? AppTheme.black : AppTheme.grey200,
            ),
            boxShadow: value.value
                ? [
                    BoxShadow(
                      color: _yellow.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: value.value ? _black : AppTheme.grey500,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: value.value ? FontWeight.w800 : FontWeight.w500,
                  color: value.value ? _black : AppTheme.grey600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Category Strip ──────────────────────────────────────────────────────────
class _CategoryStrip extends StatelessWidget {
  final search_ctrl.SearchController controller;
  const _CategoryStrip({required this.controller});

  static const _cats = [
    {'label': 'All', 'icon': Icons.grid_view_rounded},
    {'label': 'Barber', 'icon': Icons.content_cut_rounded},
    {'label': 'Hair Stylist', 'icon': Icons.face_retouching_natural_rounded},
    {'label': 'Hair Color', 'icon': Icons.palette_rounded},
    {'label': 'Nails', 'icon': Icons.front_hand_rounded},
    {'label': 'Makeup', 'icon': Icons.brush_rounded},
    {'label': 'Lashes', 'icon': Icons.remove_red_eye_rounded},
    {'label': 'Brows', 'icon': Icons.auto_fix_high_rounded},
    {'label': 'Skin Care', 'icon': Icons.spa_rounded},
    {'label': 'Massage', 'icon': Icons.self_improvement_rounded},
    {'label': 'Waxing', 'icon': Icons.waves_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _cats.length,
        itemBuilder: (context, i) {
          final cat = _cats[i];
          final label = cat['label'] as String;
          return Obx(() {
            final isSelected =
                controller.selectedCategory.value == label ||
                (label == 'All' && controller.selectedCategory.value == 'All');
            return GestureDetector(
              onTap: () => controller.updateCategory(label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isSelected ? _yellow : _bg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? _yellow : AppTheme.grey200,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      cat['icon'] as IconData,
                      size: 14,
                      color: isSelected ? _black : AppTheme.grey500,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w800
                            : FontWeight.w500,
                        color: isSelected ? _black : AppTheme.grey600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
  }
}

// ─── Discover View (initial state) ──────────────────────────────────────────
class _DiscoverView extends StatelessWidget {
  final search_ctrl.SearchController controller;
  const _DiscoverView({required this.controller});

  static const _services = [
    {
      'label': 'Haircut',
      'icon': Icons.content_cut_rounded,
      'color': Color(0xFFFFB900),
      'sub': 'Classic & Fade',
    },
    {
      'label': 'Beard',
      'icon': Icons.face_retouching_natural_rounded,
      'color': Color(0xFF4CAF50),
      'sub': 'Trim & Shape',
    },
    {
      'label': 'Hair Color',
      'icon': Icons.palette_rounded,
      'color': Color(0xFF9C27B0),
      'sub': 'Balayage & More',
    },
    {
      'label': 'Makeup',
      'icon': Icons.brush_rounded,
      'color': Color(0xFFE91E63),
      'sub': 'Bridal & Events',
    },
    {
      'label': 'Nails',
      'icon': Icons.front_hand_rounded,
      'color': Color(0xFFFF5722),
      'sub': 'Gel & Acrylic',
    },
    {
      'label': 'Lashes',
      'icon': Icons.remove_red_eye_rounded,
      'color': Color(0xFF3F51B5),
      'sub': 'Extensions & Lift',
    },
    {
      'label': 'Brows',
      'icon': Icons.auto_fix_high_rounded,
      'color': Color(0xFF795548),
      'sub': 'Threading & Tint',
    },
    {
      'label': 'Skin Care',
      'icon': Icons.spa_rounded,
      'color': Color(0xFF00BCD4),
      'sub': 'Facials & Peels',
    },
    {
      'label': 'Massage',
      'icon': Icons.self_improvement_rounded,
      'color': Color(0xFF009688),
      'sub': 'Relax & Deep Tissue',
    },
    {
      'label': 'Waxing',
      'icon': Icons.waves_rounded,
      'color': Color(0xFFFF9800),
      'sub': 'Full Body & Facial',
    },
    {
      'label': 'Threading',
      'icon': Icons.linear_scale_rounded,
      'color': Color(0xFF607D8B),
      'sub': 'Brows & Face',
    },
    {
      'label': 'Bridal',
      'icon': Icons.favorite_rounded,
      'color': Color(0xFFF44336),
      'sub': 'Full Bridal Package',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Recent searches
        SliverToBoxAdapter(
          child: Obx(() {
            if (controller.searchHistory.isEmpty)
              return const SizedBox.shrink();
            return _RecentSearches(controller: controller);
          }),
        ),

        // Hero banner
        const SliverToBoxAdapter(child: _HeroBanner()),

        // Service grid title
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Browse by Service',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: _black,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  '${_services.length} categories',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.grey500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Service grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            delegate: SliverChildBuilderDelegate((context, i) {
              final s = _services[i];
              return _ServiceTile(
                label: s['label'] as String,
                sub: s['sub'] as String,
                icon: s['icon'] as IconData,
                color: s['color'] as Color,
                onTap: () {
                  controller.updateQuery(s['label'] as String);
                  controller.performSearch();
                },
              );
            }, childCount: _services.length),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C1C1E), Color(0xFF2C2C2E)],
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _yellow.withValues(alpha: 0.15),
              ),
            ),
          ),
          Positioned(
            right: 30,
            bottom: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _yellow.withValues(alpha: 0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _yellow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'DISCOVER',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: _black,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Find the best beauty\nspecialists near you',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final String label;
  final String sub;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ServiceTile({
    required this.label,
    required this.sub,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: _black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: TextStyle(
                fontSize: 10,
                color: AppTheme.grey500,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentSearches extends StatelessWidget {
  final search_ctrl.SearchController controller;
  const _RecentSearches({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _black,
                ),
              ),
              GestureDetector(
                onTap: () => controller.clearHistory(),
                child: Text(
                  'Clear',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.grey500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.searchHistory
                .take(6)
                .map(
                  (term) => GestureDetector(
                    onTap: () {
                      controller.updateQuery(term);
                      controller.performSearch();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.grey200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.history_rounded,
                            size: 13,
                            color: AppTheme.grey400,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            term,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: _black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Results List ────────────────────────────────────────────────────────────
class _ResultsList extends StatelessWidget {
  final search_ctrl.SearchController controller;
  const _ResultsList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Results banner
        Obx(() {
          final q = controller.query.value;
          final count = controller.filteredProviders.length;
          return Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.grey100),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _yellow.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.search_rounded,
                    size: 16,
                    color: _black,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    q.isNotEmpty
                        ? '$count results for "$q"'
                        : '$count specialists found',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _black,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => controller.clearFilters(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _bg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Clear',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            physics: const BouncingScrollPhysics(),
            itemCount: controller.filteredProviders.length,
            itemBuilder: (context, index) {
              return _SpecialistCard(
                provider: controller.filteredProviders[index],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SpecialistCard extends StatelessWidget {
  final Provider provider;
  const _SpecialistCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        '/portfolio',
        arguments: {
          'id': provider.id,
          'name': provider.name,
          'image':
              provider.imageUrl ??
              'https://picsum.photos/seed/${provider.id}/200/200',
          'rating': provider.rating,
          'categories': [provider.category],
          'location': provider.location,
          'services': provider.services,
          'contact': {
            'phone': '+251 712 345 678',
            'email': 'info@salon.com',
            'address': provider.location,
          },
        },
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                bottomLeft: Radius.circular(24),
              ),
              child: SizedBox(
                width: 110,
                height: 130,
                child: Image.network(
                  provider.imageUrl ??
                      'https://picsum.photos/seed/${provider.id}/300/300',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppTheme.grey100,
                    child: const Icon(
                      Icons.person_rounded,
                      size: 40,
                      color: AppTheme.grey300,
                    ),
                  ),
                ),
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Category + rating row
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _yellow.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              provider.category.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: _black,
                                letterSpacing: 0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.star_rounded,
                          color: _yellow,
                          size: 14,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          provider.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: _black,
                          ),
                        ),
                      ],
                    ),
                    // Name
                    Text(
                      provider.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: _black,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 12,
                          color: AppTheme.grey400,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            provider.location.isNotEmpty
                                ? provider.location
                                : 'Addis Ababa',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.grey500,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    // Price + Book button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          provider.minPrice > 0
                              ? 'From \$${provider.minPrice.toInt()}'
                              : 'View Pricing',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: _black,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: _yellow,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Book',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: _black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Map View ────────────────────────────────────────────────────────────────
class _MapView extends StatelessWidget {
  final search_ctrl.SearchController controller;
  const _MapView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(9.03, 38.74),
            zoom: 13,
          ),
          markers: controller.markers,
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          mapType: MapType.normal,
          onMapCreated: (_) {},
        ),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.filteredProviders.length,
              itemBuilder: (context, index) => SizedBox(
                width: 280,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _SpecialistCard(
                    provider: controller.filteredProviders[index],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Loading Skeleton ────────────────────────────────────────────────────────
class _LoadingSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      itemCount: 5,
      itemBuilder: (_, __) => Container(
        height: 130,
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppTheme.grey100,
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}

// ─── Empty State ─────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final search_ctrl.SearchController controller;
  const _EmptyState({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppTheme.grey100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 56,
                color: AppTheme.grey300,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No results found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: _black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term or adjust your filters',
              style: TextStyle(color: AppTheme.grey500, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () => controller.clearFilters(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: _yellow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Clear Filters',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: _black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Filter Bottom Sheet ─────────────────────────────────────────────────────
void _showFilterSheet(
  BuildContext context,
  search_ctrl.SearchController controller,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _FilterBottomSheet(controller: controller),
  );
}

class _FilterBottomSheet extends StatefulWidget {
  final search_ctrl.SearchController controller;
  const _FilterBottomSheet({required this.controller});

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  search_ctrl.SearchController get c => widget.controller;

  static const _sectionStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w800,
    color: _black,
    letterSpacing: 0.5,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollCtrl) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Column(
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.grey300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Advanced Filters',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: _black,
                        ),
                      ),
                      Obx(
                        () => c.activeFilterCount > 0
                            ? GestureDetector(
                                onTap: () {
                                  c.clearFilters();
                                  setState(() {});
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.grey100,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Reset all (${c.activeFilterCount})',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.grey600,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 24),
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                children: [
                  // Sort By
                  const Text('Sort By', style: _sectionStyle),
                  const SizedBox(height: 10),
                  Obx(
                    () => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _sortChip('Rating', 'rating'),
                        _sortChip('Price', 'price'),
                        _sortChip('Distance', 'distance'),
                        _sortChip('Reviews', 'reviews'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => Row(
                      children: [
                        _orderChip('Low → High', false),
                        const SizedBox(width: 8),
                        _orderChip('High → Low', true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Min Rating
                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Minimum Rating', style: _sectionStyle),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: _yellow,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              c.minRating.value == 0
                                  ? 'Any'
                                  : c.minRating.value.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Obx(
                    () => SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: _yellow,
                        thumbColor: _yellow,
                        inactiveTrackColor: AppTheme.grey200,
                        overlayColor: _yellow.withValues(alpha: 0.2),
                      ),
                      child: Slider(
                        value: c.minRating.value,
                        min: 0,
                        max: 5,
                        divisions: 10,
                        onChanged: (v) {
                          c.updateMinRating(v);
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Price Range
                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Price Range', style: _sectionStyle),
                        Text(
                          '\$${c.minPrice.value.toInt()} – \$${c.maxPrice.value.toInt()}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Obx(
                    () => RangeSlider(
                      values: RangeValues(c.minPrice.value, c.maxPrice.value),
                      min: 0,
                      max: 500,
                      divisions: 50,
                      activeColor: _yellow,
                      inactiveColor: AppTheme.grey200,
                      onChanged: (v) {
                        c.updateMinPrice(v.start);
                        c.updateMaxPrice(v.end);
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Max Distance
                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Max Distance', style: _sectionStyle),
                        Text(
                          c.maxDistance.value >= 50
                              ? 'Any'
                              : '${c.maxDistance.value.toInt()} km',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Obx(
                    () => SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: _yellow,
                        thumbColor: _yellow,
                        inactiveTrackColor: AppTheme.grey200,
                        overlayColor: _yellow.withValues(alpha: 0.2),
                      ),
                      child: Slider(
                        value: c.maxDistance.value,
                        min: 1,
                        max: 50,
                        divisions: 49,
                        onChanged: (v) {
                          c.updateMaxDistance(v);
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Gender
                  const Text('Gender Focus', style: _sectionStyle),
                  const SizedBox(height: 10),
                  Obx(
                    () => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _genderChip('Any', 'any'),
                        _genderChip('Men', 'male'),
                        _genderChip('Women', 'female'),
                        _genderChip('Unisex', 'unisex'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Availability
                  const Text('Availability', style: _sectionStyle),
                  const SizedBox(height: 10),
                  Obx(
                    () => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _availChip('Any Time', 'any'),
                        _availChip('Today', 'today'),
                        _availChip('This Week', 'this_week'),
                        _availChip('This Month', 'this_month'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Services
                  const Text('Services', style: _sectionStyle),
                  const SizedBox(height: 10),
                  Obx(
                    () => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: c.availableServices.map(_serviceChip).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Quick Toggles
                  const Text('Quick Filters', style: _sectionStyle),
                  const SizedBox(height: 10),
                  Obx(
                    () => Column(
                      children: [
                        _toggleRow(
                          'Open Now',
                          Icons.access_time_rounded,
                          c.onlyOpenNow.value,
                          c.toggleOpenNow,
                        ),
                        const SizedBox(height: 8),
                        _toggleRow(
                          'Top Rated Only',
                          Icons.star_rounded,
                          c.onlyFeatured.value,
                          c.toggleFeatured,
                        ),
                        const SizedBox(height: 8),
                        _toggleRow(
                          'Verified Only',
                          Icons.verified_rounded,
                          c.onlyVerified.value,
                          c.toggleVerified,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            // Apply button
            Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                8,
                24,
                MediaQuery.of(context).padding.bottom + 16,
              ),
              child: GestureDetector(
                onTap: () {
                  c.applyFilters();
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _yellow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      'Apply Filters',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: _black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sortChip(String label, String value) {
    final sel = c.sortBy.value == value;
    return GestureDetector(
      onTap: () {
        c.updateSortBy(value);
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? _yellow : AppTheme.grey100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: sel ? _yellow : AppTheme.grey200),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: sel ? FontWeight.w800 : FontWeight.w500,
            color: _black,
          ),
        ),
      ),
    );
  }

  Widget _orderChip(String label, bool value) {
    final sel = c.sortOrder.value == value;
    return GestureDetector(
      onTap: () {
        c.updateSortOrder(value);
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? _black : AppTheme.grey100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
            color: sel ? Colors.white : AppTheme.grey600,
          ),
        ),
      ),
    );
  }

  Widget _genderChip(String label, String value) {
    final sel = c.gender.value == value;
    return GestureDetector(
      onTap: () {
        c.updateGender(value);
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? _yellow : AppTheme.grey100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: sel ? _yellow : AppTheme.grey200),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: sel ? FontWeight.w800 : FontWeight.w500,
            color: _black,
          ),
        ),
      ),
    );
  }

  Widget _availChip(String label, String value) {
    final sel = c.availability.value == value;
    return GestureDetector(
      onTap: () {
        c.updateAvailability(value);
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? _yellow : AppTheme.grey100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: sel ? _yellow : AppTheme.grey200),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: sel ? FontWeight.w800 : FontWeight.w500,
            color: _black,
          ),
        ),
      ),
    );
  }

  Widget _serviceChip(String svc) {
    final sel = c.selectedServices.contains(svc);
    return GestureDetector(
      onTap: () {
        c.toggleService(svc);
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: sel ? _yellow.withValues(alpha: 0.15) : AppTheme.grey100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: sel ? _yellow : AppTheme.grey200),
        ),
        child: Text(
          svc,
          style: TextStyle(
            fontSize: 12,
            fontWeight: sel ? FontWeight.w800 : FontWeight.w500,
            color: sel ? _black : AppTheme.grey600,
          ),
        ),
      ),
    );
  }

  Widget _toggleRow(
    String label,
    IconData icon,
    bool value,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: value ? _yellow.withValues(alpha: 0.08) : AppTheme.grey50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: value ? _yellow : AppTheme.grey200),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: value ? _black : AppTheme.grey500),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: value ? FontWeight.w700 : FontWeight.w500,
                  color: _black,
                ),
              ),
            ),
            Container(
              width: 44,
              height: 24,
              decoration: BoxDecoration(
                color: value ? _yellow : AppTheme.grey200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
