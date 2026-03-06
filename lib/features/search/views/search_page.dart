import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/search_controller.dart' as search_ctrl;
import '../../../domain/entities/provider.dart';

class SearchPage extends GetView<search_ctrl.SearchController> {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.grey50,
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.grey100,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryYellow.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
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
              Obx(() => _buildSortDropdown()),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _showFilterSheet(context),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryYellow,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryYellow.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: AppTheme.black,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
          _buildQuickActions(),
          _buildNearbyPreview(),
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

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildActionItem(
                'Top Rated',
                Icons.star_rounded,
                AppTheme.primaryYellow,
                () => controller.updateMinRating(4.5),
              ),
              const SizedBox(width: 12),
              _buildActionItem(
                'Nearby',
                Icons.location_on_rounded,
                AppTheme.info,
                () {},
              ),
              const SizedBox(width: 12),
              _buildActionItem(
                'Deals',
                Icons.local_offer_rounded,
                AppTheme.success,
                () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.grey200),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.black,
                ),
              ),
            ],
          ),
        ),
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
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: controller.filteredProviders.length,
      itemBuilder: (context, index) {
        return _buildSpecialistCard(controller.filteredProviders[index]);
      },
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
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.black.withValues(alpha: 0.05),
              blurRadius: 15,
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryYellow.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              provider.category.capitalizeFirst!,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.black,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                provider.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        provider.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            color: AppTheme.grey400,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            provider.location,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.grey500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            provider.minPrice > 0
                                ? 'From \$${provider.minPrice.toInt()}'
                                : 'Variable pricing',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.black,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 12,
                            color: AppTheme.black,
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

  Widget _buildProviderImage(Provider provider) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ),
        image: DecorationImage(
          image: NetworkImage(
            provider.imageUrl ??
                'https://picsum.photos/seed/${provider.id}/200/200',
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
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppTheme.grey50,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: AppTheme.grey200,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {
                  widget.controller.clearFilters();
                  Navigator.pop(context);
                },
                child: Text(
                  'Reset All',
                  style: TextStyle(
                    color: AppTheme.primaryYellow,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),

                  // Sort Options
                  _buildSectionHeader('Sort By'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(
                          () => _buildDropdown(
                            'Sort by',
                            _tempSortBy,
                            widget.controller.sortOptions,
                            (value) => setState(() => _tempSortBy = value),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _tempSortOrder = !_tempSortOrder),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: _tempSortOrder
                                ? AppTheme.primaryYellow
                                : AppTheme.grey50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.grey200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _tempSortOrder
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                color: _tempSortOrder
                                    ? AppTheme.black
                                    : AppTheme.textSecondary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _tempSortOrder ? 'Desc' : 'Asc',
                                style: TextStyle(
                                  color: _tempSortOrder
                                      ? AppTheme.black
                                      : AppTheme.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Price Range
                  _buildSectionHeader('Price Range'),
                  const SizedBox(height: 12),
                  _buildPriceRange(),

                  const SizedBox(height: 30),

                  // Rating & Distance
                  Row(
                    children: [
                      Expanded(child: _buildRatingSlider()),
                      const SizedBox(width: 20),
                      Expanded(child: _buildDistanceSlider()),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Availability & Gender
                  Row(
                    children: [
                      Expanded(child: _buildAvailabilityFilter()),
                      const SizedBox(width: 20),
                      Expanded(child: _buildGenderFilter()),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Toggle Options
                  _buildSectionHeader('Quick Filters'),
                  const SizedBox(height: 12),
                  _buildToggleFilters(),

                  const SizedBox(height: 30),

                  // Services
                  _buildSectionHeader('Services'),
                  const SizedBox(height: 12),
                  _buildServiceFilters(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
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
                backgroundColor: AppTheme.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Apply Filters',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for advanced filter UI
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppTheme.black,
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> options,
    Function(String) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.grey200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: options.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(
                option.capitalizeFirst ?? option,
                style: const TextStyle(fontSize: 14, color: AppTheme.black),
              ),
            );
          }).toList(),
          onChanged: (newValue) => onChanged(newValue!),
        ),
      ),
    );
  }

  Widget _buildPriceRange() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Min Price',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.grey50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.grey200),
                    ),
                    child: Text(
                      '\$${_tempMinPrice.toInt()}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Max Price',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.grey50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.grey200),
                    ),
                    child: Text(
                      '\$${_tempMaxPrice.toInt()}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Slider(
          value: _tempMaxPrice,
          min: 0,
          max: 500,
          activeColor: AppTheme.primaryYellow,
          inactiveColor: AppTheme.grey200,
          label: '\$${_tempMaxPrice.toInt()}',
          onChanged: (v) => setState(() => _tempMaxPrice = v),
        ),
      ],
    );
  }

  Widget _buildRatingSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Min Rating',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),
        Slider(
          value: _tempMinRating,
          min: 0,
          max: 5,
          divisions: 10,
          activeColor: AppTheme.primaryYellow,
          inactiveColor: AppTheme.grey200,
          label: '${_tempMinRating.toStringAsFixed(1)} ⭐',
          onChanged: (v) => setState(() => _tempMinRating = v),
        ),
        Text(
          '${_tempMinRating.toStringAsFixed(1)} stars and up',
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildDistanceSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Max Distance',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),
        Slider(
          value: _tempMaxDistance,
          min: 1,
          max: 100,
          activeColor: AppTheme.primaryYellow,
          inactiveColor: AppTheme.grey200,
          label: '${_tempMaxDistance.toInt()} km',
          onChanged: (v) => setState(() => _tempMaxDistance = v),
        ),
        Text(
          'Within ${_tempMaxDistance.toInt()} km',
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildAvailabilityFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Availability',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),
        ...widget.controller.availabilityOptions.map((option) {
          final isSelected = _tempAvailability == option;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => setState(() => _tempAvailability = option),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryYellow : AppTheme.grey50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryYellow
                        : AppTheme.grey200,
                  ),
                ),
                child: Text(
                  option.capitalizeFirst ?? option,
                  style: TextStyle(
                    color: isSelected ? AppTheme.black : AppTheme.textSecondary,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildGenderFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender Preference',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),
        ...widget.controller.genderOptions.map((option) {
          final isSelected = _tempGender == option;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => setState(() => _tempGender = option),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryYellow : AppTheme.grey50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryYellow
                        : AppTheme.grey200,
                  ),
                ),
                child: Text(
                  option.capitalizeFirst ?? option,
                  style: TextStyle(
                    color: isSelected ? AppTheme.black : AppTheme.textSecondary,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildToggleFilters() {
    return Column(
      children: [
        _buildToggleOption(
          'Open Now',
          _tempOnlyOpenNow,
          (value) => setState(() => _tempOnlyOpenNow = value),
        ),
        const SizedBox(height: 8),
        _buildToggleOption(
          'Featured Only',
          _tempOnlyFeatured,
          (value) => setState(() => _tempOnlyFeatured = value),
        ),
        const SizedBox(height: 8),
        _buildToggleOption(
          'Verified Only',
          _tempOnlyVerified,
          (value) => setState(() => _tempOnlyVerified = value),
        ),
      ],
    );
  }

  Widget _buildToggleOption(
    String label,
    bool value,
    Function(bool) onChanged,
  ) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: value ? AppTheme.primaryYellow : AppTheme.grey50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? AppTheme.primaryYellow : AppTheme.grey200,
          ),
        ),
        child: Row(
          children: [
            Icon(
              value ? Icons.check_circle : Icons.circle_outlined,
              color: value ? AppTheme.black : AppTheme.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: value ? AppTheme.black : AppTheme.textSecondary,
                fontWeight: value ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceFilters() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: widget.controller.availableServices.map((service) {
        final isSelected = _tempServices.contains(service);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _tempServices.remove(service);
              } else {
                _tempServices.add(service);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryYellow : AppTheme.grey50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppTheme.primaryYellow : AppTheme.grey200,
              ),
            ),
            child: Text(
              service,
              style: TextStyle(
                color: isSelected ? AppTheme.black : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
