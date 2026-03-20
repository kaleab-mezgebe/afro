import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/search_controller.dart' as search_ctrl;
import '../../../domain/entities/provider.dart';
// Assuming this exists or using local

class SearchPage extends GetView<search_ctrl.SearchController> {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Obx(() => FloatingActionButton.extended(
        heroTag: 'search_map_fab',
        onPressed: controller.toggleMap,
        backgroundColor: AppTheme.primaryYellow,
        foregroundColor: AppTheme.black,
        icon: Icon(controller.showMap.value ? Icons.list_rounded : Icons.map_rounded),
        label: Text(controller.showMap.value ? 'Show List' : 'Show Map'),
      )),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildCategoryFilters(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return _buildLoadingState();
                }

                if (controller.showMap.value) {
                  return _buildMapView();
                }

                if (controller.query.value.isEmpty &&
                    !controller.hasActiveFilters) {
                  return _buildInitialState();
                }

                if (controller.filteredProviders.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildResultsList();
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Explore Services',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.grey100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.grey200),
                  ),
                  child: TextField(
                    onChanged: controller.updateQuery,
                    onSubmitted: (_) => controller.performSearch(),
                    decoration: InputDecoration(
                      hintText: 'Search for salons, barbers...',
                      hintStyle: TextStyle(
                        color: AppTheme.grey400,
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      icon: const Icon(
                        Icons.search_rounded,
                        color: AppTheme.black,
                        size: 24,
                      ),
                      suffixIcon: Obx(
                        () => controller.query.value.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, size: 20),
                                onPressed: () => controller.clearFilters(),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Obx(() => _buildFilterButton(context)),
            ],
          ),
          const SizedBox(height: 16),
          _buildQuickFilterRow(),
        ],
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFilterSheet(context),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.black,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: AppTheme.white,
              size: 28,
            ),
          ),
          if (controller.activeFilterCount > 0)
            Positioned(
              top: -5,
              right: -5,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryYellow,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${controller.activeFilterCount}',
                  style: const TextStyle(
                    color: AppTheme.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickFilterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Obx(() => _buildSortDropdown()),
          const SizedBox(width: 8),
          _buildQuickChip('Open Now', controller.onlyOpenNow, controller.toggleOpenNow),
          const SizedBox(width: 8),
          _buildQuickChip('Featured', controller.onlyFeatured, controller.toggleFeatured),
          const SizedBox(width: 8),
          _buildQuickChip('Verified', controller.onlyVerified, controller.toggleVerified),
        ],
      ),
    );
  }

  Widget _buildQuickChip(String label, RxBool value, VoidCallback onTap) {
    return Obx(() => GestureDetector(
      onTap: onTap,
      child: Chip(
        label: Text(label),
        backgroundColor: value.value ? AppTheme.primaryYellow : AppTheme.white,
        labelStyle: TextStyle(
          color: AppTheme.black,
          fontSize: 12,
          fontWeight: value.value ? FontWeight.bold : FontWeight.normal,
        ),
        side: BorderSide(color: value.value ? AppTheme.primaryYellow : AppTheme.grey200),
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
    ));
  }

  Widget _buildCategoryFilters() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: controller.categories.length,
        itemBuilder: (context, index) {
          final category = controller.categories[index];
          return Obx(() {
            final isSelected = controller.selectedCategory.value == category;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () => controller.updateCategory(category),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryYellow
                        : AppTheme.grey50,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryYellow
                          : AppTheme.grey200,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: AppTheme.primaryYellow.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Text(
                    category.capitalizeFirst!,
                    style: TextStyle(
                      color: isSelected
                          ? AppTheme.white
                          : AppTheme.textSecondary,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildInitialState() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchHistory(),
          _buildServiceCategories(),
          _buildNearbyPreview(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSearchHistory() {
    return Obx(() {
      if (controller.searchHistory.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Searches',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.black,
                  ),
                ),
                GestureDetector(
                  onTap: () => controller.clearHistory(),
                  child: Text(
                    'Clear All',
                    style: TextStyle(
                      color: AppTheme.grey500,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: controller.searchHistory.length,
              itemBuilder: (context, index) {
                final term = controller.searchHistory[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ActionChip(
                    label: Text(term),
                    onPressed: () {
                      controller.updateQuery(term);
                      controller.performSearch();
                    },
                    backgroundColor: AppTheme.grey100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    side: BorderSide.none,
                    labelStyle: const TextStyle(
                      color: AppTheme.black,
                      fontSize: 13,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  /// Replaces Quick Actions — shows service category tiles that search properly
  Widget _buildServiceCategories() {
    final categories = [
      {'label': 'Haircut', 'icon': Icons.content_cut_rounded, 'color': const Color(0xFFFFB900)},
      {'label': 'Beard', 'icon': Icons.face_retouching_natural, 'color': const Color(0xFF4CAF50)},
      {'label': 'Color', 'icon': Icons.palette_rounded, 'color': const Color(0xFF9C27B0)},
      {'label': 'Makeup', 'icon': Icons.brush_rounded, 'color': const Color(0xFFE91E63)},
      {'label': 'Facial', 'icon': Icons.spa_rounded, 'color': const Color(0xFF00BCD4)},
      {'label': 'Nails', 'icon': Icons.front_hand_rounded, 'color': const Color(0xFFFF5722)},
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Browse by Service',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: categories.length,
            itemBuilder: (context, i) {
              final cat = categories[i];
              return GestureDetector(
                onTap: () {
                  controller.updateQuery(cat['label'] as String);
                  controller.performSearch();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.grey200),
                    boxShadow: [
                      BoxShadow(
                        color: (cat['color'] as Color).withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (cat['color'] as Color).withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          cat['icon'] as IconData,
                          color: cat['color'] as Color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat['label'] as String,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyPreview() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Popular Near You',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: const DecorationImage(
                image: NetworkImage('https://picsum.photos/seed/map/800/400'),
                fit: BoxFit.cover,
                opacity: 0.7,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppTheme.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
              child: Center(
                child: GestureDetector(
                  onTap: () => controller.toggleMap(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.grey50,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'View Map',
                      style: TextStyle(
                        color: AppTheme.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 5,
      itemBuilder: (context, index) => _buildShimmerCard(),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      height: 120,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.grey100,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: AppTheme.grey300),
          const SizedBox(height: 20),
          const Text(
            'No results found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Try adjusting your filters or search term',
            style: TextStyle(color: AppTheme.grey500),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => controller.clearFilters(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryYellow,
              foregroundColor: AppTheme.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Clear All Filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return Column(
      children: [
        // Active filter / search banner with back option
        Obx(() {
          final q = controller.query.value;
          final hasFilter = controller.hasActiveFilters;
          if (q.isEmpty && !hasFilter) return const SizedBox.shrink();
          return Container(
            margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.primaryYellow.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryYellow.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.filter_list_rounded, size: 18, color: AppTheme.primaryYellow),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    q.isNotEmpty ? 'Results for "$q"' : 'Filtered results',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => controller.clearFilters(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryYellow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.close_rounded, size: 14, color: AppTheme.black),
                        SizedBox(width: 4),
                        Text('Clear', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.black)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            itemCount: controller.filteredProviders.length,
            itemBuilder: (context, index) {
              return _buildSpecialistCard(controller.filteredProviders[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialistCard(Provider provider) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        '/portfolio',
        arguments: {'specialist': _mapProviderToMap(provider)},
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              _buildProviderImage(provider),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryYellow.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              provider.category.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.black,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: AppTheme.primaryYellow, size: 16),
                              const SizedBox(width: 2),
                              Text(
                                provider.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        provider.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.black,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, color: AppTheme.greyMedium, size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              provider.location,
                              style: const TextStyle(fontSize: 12, color: AppTheme.greyMedium, fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            provider.minPrice > 0 ? 'FROM \$${provider.minPrice.toInt()}' : 'VIEW PRICING',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.black,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.black,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Colors.white),
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
      ),
    );
  }
  Widget _buildMapView() {
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
          onMapCreated: (mapController) {
            // Optional: Store map controller
          },
        ),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: controller.filteredProviders.length,
              itemBuilder: (context, index) {
                final provider = controller.filteredProviders[index];
                return Container(
                  width: 300,
                  margin: const EdgeInsets.only(right: 12),
                  child: _buildSpecialistCard(provider),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProviderImage(Provider provider) {
    return Container(
      width: 110,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          bottomLeft: Radius.circular(24),
        ),
        image: DecorationImage(
          image: NetworkImage(
            provider.imageUrl ?? 'https://picsum.photos/seed/${provider.id}/300/300',
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Map<String, dynamic> _mapProviderToMap(Provider provider) {
    return {
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
    };
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterBottomSheet(controller: controller),
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.grey200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: controller.sortBy.value,
          isDense: true,
          items: controller.sortOptions.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getSortIcon(option),
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getSortLabel(option),
                    style: const TextStyle(fontSize: 14, color: AppTheme.black),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              controller.updateSortBy(value);
              controller.applyFilters();
            }
          },
        ),
      ),
    );
  }

  IconData _getSortIcon(String sortBy) {
    switch (sortBy) {
      case 'rating':
        return Icons.star_rounded;
      case 'price':
        return Icons.attach_money_rounded;
      case 'distance':
        return Icons.location_on_rounded;
      case 'reviews':
        return Icons.chat_rounded;
      default:
        return Icons.sort_rounded;
    }
  }

  String _getSortLabel(String sortBy) {
    switch (sortBy) {
      case 'rating':
        return 'Rating';
      case 'price':
        return 'Price';
      case 'distance':
        return 'Distance';
      case 'reviews':
        return 'Reviews';
      default:
        return 'Sort';
    }
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final search_ctrl.SearchController controller;
  const _FilterBottomSheet({required this.controller});

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late double _tempMinRating;
  late double _tempMaxPrice;
  late double _tempMinPrice;
  late double _tempMaxDistance;
  late String _tempSortBy;
  late bool _tempSortOrder;
  late String _tempAvailability;
  late String _tempGender;
  late bool _tempOnlyOpenNow;
  late bool _tempOnlyFeatured;
  late bool _tempOnlyVerified;
  late List<String> _tempServices;

  @override
  void initState() {
    super.initState();
    _tempMinRating = widget.controller.minRating.value;
    _tempMaxPrice = widget.controller.maxPrice.value;
    _tempMinPrice = widget.controller.minPrice.value;
    _tempMaxDistance = widget.controller.maxDistance.value;
    _tempSortBy = widget.controller.sortBy.value;
    _tempSortOrder = widget.controller.sortOrder.value;
    _tempAvailability = widget.controller.availability.value;
    _tempGender = widget.controller.gender.value;
    _tempOnlyOpenNow = widget.controller.onlyOpenNow.value;
    _tempOnlyFeatured = widget.controller.onlyFeatured.value;
    _tempOnlyVerified = widget.controller.onlyVerified.value;
    _tempServices = List.from(widget.controller.selectedServices);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          _buildDragHandle(),
          _buildSheetHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildSectionHeader('Sort & Order'),
                  _buildSortSection(),
                  const Divider(height: 40, color: AppTheme.grey100),
                  _buildSectionHeader('Price Range'),
                  _buildPriceSection(),
                  const Divider(height: 40, color: AppTheme.grey100),
                  _buildSectionHeader('Filters'),
                  _buildQuickToggleSection(),
                  const Divider(height: 40, color: AppTheme.grey100),
                  _buildSectionHeader('Availability & Distance'),
                  _buildAvailabilityAndDistanceSection(),
                  const Divider(height: 40, color: AppTheme.grey100),
                  _buildSectionHeader('Gender Preference'),
                  _buildGenderSection(),
                  const Divider(height: 40, color: AppTheme.grey100),
                  _buildSectionHeader('Services'),
                  _buildServiceSection(),
                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ),
          _buildApplyButton(context),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppTheme.grey200,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildSheetHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Filter',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          TextButton(
            onPressed: () {
              widget.controller.clearFilters();
              Navigator.pop(context);
            },
            child: const Text(
              'Reset All',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppTheme.black,
        ),
      ),
    );
  }

  Widget _buildSortSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppTheme.grey50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _tempSortBy,
              isExpanded: true,
              items: widget.controller.sortOptions.map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(
                    option.capitalizeFirst ?? option,
                    style: const TextStyle(fontSize: 15, color: AppTheme.black),
                  ),
                );
              }).toList(),
              onChanged: (val) => setState(() => _tempSortBy = val!),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildRadioButton('Ascending', !_tempSortOrder, () => setState(() => _tempSortOrder = false)),
            const SizedBox(width: 16),
            _buildRadioButton('Descending', _tempSortOrder, () => setState(() => _tempSortOrder = true)),
          ],
        ),
      ],
    );
  }

  Widget _buildRadioButton(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryYellow : AppTheme.grey50,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppTheme.black : AppTheme.grey600,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '\$${_tempMinPrice.toInt()} - \$${_tempMaxPrice.toInt()}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.black,
                fontSize: 15,
              ),
            ),
            const Text(
              'Max \$500',
              style: TextStyle(color: AppTheme.grey400, fontSize: 13),
            ),
          ],
        ),
        RangeSlider(
          values: RangeValues(_tempMinPrice, _tempMaxPrice),
          min: 0,
          max: 500,
          divisions: 50,
          activeColor: AppTheme.primaryYellow,
          inactiveColor: AppTheme.grey100,
          labels: RangeLabels(
            '\$${_tempMinPrice.toInt()}',
            '\$${_tempMaxPrice.toInt()}',
          ),
          onChanged: (values) {
            setState(() {
              _tempMinPrice = values.start;
              _tempMaxPrice = values.end;
            });
          },
        ),
      ],
    );
  }

  Widget _buildQuickToggleSection() {
    return Column(
      children: [
        _buildSectionToggle('Open Now', _tempOnlyOpenNow, (v) => setState(() => _tempOnlyOpenNow = v)),
        _buildSectionToggle('Featured Providers', _tempOnlyFeatured, (v) => setState(() => _tempOnlyFeatured = v)),
        _buildSectionToggle('Verified Experts', _tempOnlyVerified, (v) => setState(() => _tempOnlyVerified = v)),
      ],
    );
  }

  Widget _buildSectionToggle(String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.grey700, fontSize: 15)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.primaryYellow,
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityAndDistanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Search Area', style: TextStyle(color: AppTheme.grey600, fontSize: 14)),
        Slider(
          value: _tempMaxDistance,
          min: 1,
          max: 100,
          divisions: 20,
          activeColor: AppTheme.primaryYellow,
          inactiveColor: AppTheme.grey100,
          label: '${_tempMaxDistance.toInt()} km',
          onChanged: (v) => setState(() => _tempMaxDistance = v),
        ),
        const SizedBox(height: 16),
        const Text('When', style: TextStyle(color: AppTheme.grey600, fontSize: 14)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: widget.controller.availabilityOptions.map((option) {
            final isSelected = _tempAvailability == option;
            return ChoiceChip(
              label: Text(option.capitalizeFirst ?? option),
              selected: isSelected,
              onSelected: (val) => setState(() => _tempAvailability = option),
              selectedColor: AppTheme.primaryYellow,
              backgroundColor: AppTheme.grey50,
              labelStyle: TextStyle(
                color: AppTheme.black,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGenderSection() {
    return Wrap(
      spacing: 8,
      children: widget.controller.genderOptions.map((option) {
        final isSelected = _tempGender == option;
        return ChoiceChip(
          label: Text(option.capitalizeFirst ?? option),
          selected: isSelected,
          onSelected: (val) => setState(() => _tempGender = option),
          selectedColor: AppTheme.primaryYellow,
          backgroundColor: AppTheme.grey50,
          labelStyle: TextStyle(
            color: AppTheme.black,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          side: BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        );
      }).toList(),
    );
  }

  Widget _buildServiceSection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.controller.availableServices.map((service) {
        final isSelected = _tempServices.contains(service);
        return FilterChip(
          label: Text(service),
          selected: isSelected,
          onSelected: (val) {
            setState(() {
              if (val) {
                _tempServices.add(service);
              } else {
                _tempServices.remove(service);
              }
            });
          },
          selectedColor: AppTheme.primaryYellow.withValues(alpha: 0.2),
          backgroundColor: AppTheme.white,
          checkmarkColor: AppTheme.black,
          labelStyle: TextStyle(
            color: AppTheme.black,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          side: BorderSide(color: isSelected ? AppTheme.primaryYellow : AppTheme.grey200),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        );
      }).toList(),
    );
  }

  Widget _buildApplyButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.white,
        boxShadow: [
          BoxShadow(
            color: AppTheme.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            widget.controller.updateMinRating(_tempMinRating);
            widget.controller.updateMaxPrice(_tempMaxPrice);
            widget.controller.updateMinPrice(_tempMinPrice);
            widget.controller.updateMaxDistance(_tempMaxDistance);
            widget.controller.updateSortBy(_tempSortBy);
            widget.controller.updateSortOrder(_tempSortOrder);
            widget.controller.updateAvailability(_tempAvailability);
            widget.controller.updateGender(_tempGender);
            widget.controller.onlyOpenNow.value = _tempOnlyOpenNow;
            widget.controller.onlyFeatured.value = _tempOnlyFeatured;
            widget.controller.onlyVerified.value = _tempOnlyVerified;
            widget.controller.selectedServices.assignAll(_tempServices);
            widget.controller.applyFilters();
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryYellow,
            foregroundColor: AppTheme.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Apply Filters',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
