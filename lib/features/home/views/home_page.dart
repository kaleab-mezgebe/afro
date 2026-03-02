import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  String _selectedCategory = 'Hairdressing';
  String _searchQuery = '';
  late AnimationController _bannerController;

  @override
  void initState() {
    super.initState();
    _bannerController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  // Sample notification data
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 1,
      'title': 'Booking Confirmed',
      'message':
          'Your appointment with Sarah Johnson is confirmed for tomorrow at 2:00 PM',
      'time': '2 hours ago',
      'isRead': false,
    },
    {
      'id': 2,
      'title': 'Special Offer',
      'message': 'Get 20% off on your next haircut this weekend!',
      'time': '5 hours ago',
      'isRead': false,
    },
    {
      'id': 3,
      'title': 'Appointment Reminder',
      'message': 'Don\'t forget your appointment tomorrow at 2:00 PM',
      'time': '1 day ago',
      'isRead': true,
    },
  ];
  bool _hasNotifications = false;
  int _notificationCount = 3;
  String _selectedGender = 'all'; // all, male, female
  double _minPrice = 0;
  double _maxPrice = 100;
  double _minRating = 0;
  bool _filtersApplied = false;

  // Comprehensive salon categories for male and female
  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Hairdressing',
      'icon': Icons.content_cut,
      'selected': true,
      'gender': 'all',
    },
    {
      'name': 'Hair Color',
      'icon': Icons.color_lens,
      'selected': false,
      'gender': 'all',
    },
    {
      'name': 'Beard & Mustache',
      'icon': Icons.face,
      'selected': false,
      'gender': 'male',
    },
    {
      'name': 'Makeup',
      'icon': Icons.brush,
      'selected': false,
      'gender': 'female',
    },
    {
      'name': 'Shaving',
      'icon': Icons.content_cut,
      'selected': false,
      'gender': 'male',
    },
    {
      'name': 'Makeup',
      'icon': Icons.face_retouching_natural,
      'selected': false,
      'gender': 'female',
    },
    {
      'name': 'Nail Care',
      'icon': Icons.back_hand,
      'selected': false,
      'gender': 'female',
    },
    {'name': 'Waxing', 'icon': Icons.spa, 'selected': false, 'gender': 'all'},
    {'name': 'Facial', 'icon': Icons.face, 'selected': false, 'gender': 'all'},
  ];

  // Specialists data with categories and gender
  final List<Map<String, dynamic>> _specialists = [
    {
      'name': 'David Marcomin',
      'price': '\$49.32',
      'image': 'https://picsum.photos/seed/david/200/200.jpg',
      'categories': ['Hairdressing', 'Beard & Mustache'],
      'gender': 'male',
      'rating': 4.8,
    },
    {
      'name': 'Richard Anderson',
      'price': '\$28.48',
      'image': 'https://picsum.photos/seed/richard/200/200.jpg',
      'categories': ['Hairdressing', 'Styling'],
      'gender': 'male',
      'rating': 4.6,
    },
    {
      'name': 'Sarah Johnson',
      'price': '\$65.00',
      'image': 'https://picsum.photos/seed/sarah/200/200.jpg',
      'categories': ['Hairdressing', 'Hair Color', 'Styling'],
      'gender': 'female',
      'rating': 4.9,
    },
    {
      'name': 'Emma Wilson',
      'price': '\$55.75',
      'image': 'https://picsum.photos/seed/emma/200/200.jpg',
      'categories': ['Hair Color', 'Hair Treatment'],
      'gender': 'female',
      'rating': 4.7,
    },
    {
      'name': 'Michael Brown',
      'price': '\$35.50',
      'image': 'https://picsum.photos/seed/michael/200/200.jpg',
      'categories': ['Beard & Mustache', 'Shaving'],
      'gender': 'male',
      'rating': 4.5,
    },
    {
      'name': 'Lisa Davis',
      'price': '\$75.00',
      'image': 'https://picsum.photos/seed/lisa/200/200.jpg',
      'categories': ['Makeup', 'Facial'],
      'gender': 'female',
      'rating': 4.8,
    },
    {
      'name': 'Jennifer Martinez',
      'price': '\$45.25',
      'image': 'https://picsum.photos/seed/jennifer/200/200.jpg',
      'categories': ['Nail Care', 'Waxing'],
      'gender': 'female',
      'rating': 4.6,
    },
    {
      'name': 'Robert Taylor',
      'price': '\$40.00',
      'image': 'https://picsum.photos/seed/robert/200/200.jpg',
      'categories': ['Hairdressing', 'Hair Treatment'],
      'gender': 'male',
      'rating': 4.4,
    },
  ];

  List<Map<String, dynamic>> get _filteredSpecialists {
    List<Map<String, dynamic>> filtered = _specialists.where((specialist) {
      // Category filter
      bool categoryMatch = specialist['categories'].contains(_selectedCategory);

      // Search filter
      bool searchMatch =
          _searchQuery.isEmpty ||
          specialist['name'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

      // Gender filter
      bool genderMatch =
          _selectedGender == 'all' || specialist['gender'] == _selectedGender;

      // Price filter
      double price = double.parse(
        specialist['price'].toString().replaceAll('\$', ''),
      );
      bool priceMatch = price >= _minPrice && price <= _maxPrice;

      // Rating filter
      bool ratingMatch = (specialist['rating'] as double) >= _minRating;

      // Debug output (remove in production)
      if (_filtersApplied || _searchQuery.isNotEmpty) {
        print(
          'Filtering ${specialist['name']}: category=$categoryMatch, search=$searchMatch, gender=$genderMatch, price=$priceMatch, rating=$ratingMatch',
        );
      }

      return categoryMatch &&
          searchMatch &&
          genderMatch &&
          priceMatch &&
          ratingMatch;
    }).toList();

    return filtered;
  }

  void _selectCategory(String categoryName) {
    setState(() {
      _selectedCategory = categoryName;
      // Update selected state for all categories
      for (var category in _categories) {
        category['selected'] = category['name'] == categoryName;
      }
    });
  }

  void _updateSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildFilterModal(),
    );
  }

  void _applyFilters({
    String? gender,
    double? minPrice,
    double? maxPrice,
    double? minRating,
  }) {
    print(
      'Applying filters: gender=$gender, minPrice=$minPrice, maxPrice=$maxPrice, minRating=$minRating',
    );
    setState(() {
      if (gender != null) _selectedGender = gender;
      if (minPrice != null) _minPrice = minPrice;
      if (maxPrice != null) _maxPrice = maxPrice;
      if (minRating != null) _minRating = minRating;
      _filtersApplied = true;
    });
    print(
      'Filters applied: _selectedGender=$_selectedGender, _minPrice=$_minPrice, _maxPrice=$_maxPrice, _minRating=$_minRating',
    );
    Navigator.pop(context);
  }

  void _clearFilters() {
    setState(() {
      _selectedGender = 'all';
      _minPrice = 0;
      _maxPrice = 100;
      _minRating = 0;
      _filtersApplied = false;
    });
    Navigator.pop(context);
  }

  String get _filterSummary {
    List<String> filters = [];

    if (_selectedGender != 'all') {
      filters.add(_selectedGender == 'male' ? 'Male' : 'Female');
    }

    if (_minPrice > 0 || _maxPrice < 100) {
      filters.add('\$${_minPrice.toInt()}-\$${_maxPrice.toInt()}');
    }

    if (_minRating > 0) {
      filters.add('${_minRating.toStringAsFixed(1)}+ stars');
    }

    if (_searchQuery.isNotEmpty) {
      filters.add('"$_searchQuery"');
    }

    // Debug info
    print(
      'Filter summary: $filters (gender: $_selectedGender, price: $_minPrice-$_maxPrice, rating: $_minRating)',
    );

    return filters.isNotEmpty ? filters.join(' • ') : '';
  }

  bool get _hasActiveFilters {
    return _filtersApplied || _searchQuery.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Header and Search
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 16),
                  _buildSearchBar(context),
                ],
              ),
            ),

            // Fixed Content Area (non-scrollable)
            Expanded(
              child: Column(
                children: [
                  // Fixed Promotional Banner (never scrolls)
                  if (!_hasActiveFilters) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildPromotionalBanner(context),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Fixed Filter Summary Bar (never scrolls)
                  if (_hasActiveFilters) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildFilterSummaryBar(context),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Fixed Categories (never scrolls)
                  if (_searchQuery.isEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildCategories(context),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Only Scrollable Card Lists
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildFilterResultsSection(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good Morning!',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Jacob Thomas',
              style: TextStyle(
                color: AppTheme.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Row(
          children: [
            // Notification Bell
            GestureDetector(
              onTap: _handleNotificationTap,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.grey100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        _hasNotifications
                            ? Icons.notifications
                            : Icons.notifications_none,
                        color: AppTheme.black,
                        size: 20,
                      ),
                    ),
                    if (_notificationCount > 0)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B35),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '$_notificationCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
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
            const SizedBox(width: 12),
            // Profile Picture
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryYellow,
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://picsum.photos/seed/profile/100/100.jpg',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppTheme.grey100,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          const SizedBox(width: 20),
          Expanded(
            child: TextField(
              onChanged: _updateSearch,
              decoration: InputDecoration(
                hintText: 'Search Salon, Specialist',
                hintStyle: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              style: TextStyle(color: AppTheme.black, fontSize: 16),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _showFilterModal,
            child: Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: _filtersApplied
                    ? const Color(0xFFFF6B35)
                    : AppTheme.primaryYellow,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(Icons.tune, color: AppTheme.black, size: 20),
                  ),
                  if (_filtersApplied)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  Widget _buildPromotionalBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: AppTheme.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Animated Background
          AnimatedBuilder(
            animation: _bannerController,
            builder: (context, child) {
              return Positioned.fill(
                child: FractionallySizedBox(
                  alignment: Alignment(_bannerController.value - 0.5, 0.5),
                  child: Container(
                    width: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFF6B35),
                          const Color(0xFFFFA500),
                          AppTheme.primaryYellow,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              );
            },
          ),
          // Background Image
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                'https://picsum.photos/seed/barber/400/180.jpg',
                fit: BoxFit.cover,
                opacity: AlwaysStoppedAnimation(0.6),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Get 20% Off Your Next Haircut!',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 120,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () => Get.toNamed(AppRoutes.bookingService),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35), // Orange color
                      foregroundColor: AppTheme.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Book Now',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(
            color: AppTheme.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = category['selected'] as bool;
              return Container(
                margin: const EdgeInsets.only(right: 12),
                child: ElevatedButton(
                  onPressed: () => _selectCategory(category['name'] as String),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected
                        ? AppTheme.primaryYellow
                        : AppTheme.grey100,
                    foregroundColor: isSelected
                        ? AppTheme.black
                        : AppTheme.textSecondary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(category['icon'] as IconData, size: 16),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          category['name'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSummaryBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryYellow.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryYellow.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.filter_list,
                      size: 16,
                      color: AppTheme.primaryYellow,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Active Filters',
                      style: const TextStyle(
                        color: AppTheme.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (_filterSummary.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _filterSummary,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          TextButton(
            onPressed: _clearAllFiltersAndSearch,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Clear',
              style: TextStyle(
                color: AppTheme.primaryYellow,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterResultsSection(BuildContext context) {
    final specialists = _filteredSpecialists;
    final isSearchingOrFiltered = _hasActiveFilters;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fixed Section Header (never scrolls)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isSearchingOrFiltered ? 'Search Results' : _selectedCategory,
              style: const TextStyle(
                color: AppTheme.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isSearchingOrFiltered)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryYellow.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${specialists.length} found',
                  style: const TextStyle(
                    color: AppTheme.primaryYellow,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              GestureDetector(
                onTap: () => _showAllSpecialists(),
                child: const Text(
                  'See All',
                  style: TextStyle(
                    color: AppTheme.primaryYellow,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Only Scrollable Card Lists
        Expanded(
          child: specialists.isEmpty
              ? _buildEmptyResults(context)
              : SingleChildScrollView(
                  child: _buildSpecialistsGrid(context, specialists),
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyResults(BuildContext context) {
    final isSearchingOrFiltered = _hasActiveFilters;

    return Container(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.grey100,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                isSearchingOrFiltered ? Icons.search_off : Icons.person_search,
                size: 40,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isSearchingOrFiltered
                  ? 'No specialists found'
                  : 'No specialists available',
              style: const TextStyle(
                color: AppTheme.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearchingOrFiltered
                  ? 'Try adjusting your filters or search terms'
                  : 'Check back later for new specialists',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            if (isSearchingOrFiltered) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _clearAllFiltersAndSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryYellow,
                  foregroundColor: AppTheme.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Clear Filters',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialistsGrid(
    BuildContext context,
    List<Map<String, dynamic>> specialists,
  ) {
    return Column(
      children: [
        // Grid View for better layout - 3 cards per row
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Changed from 2 to 3
            crossAxisSpacing: 12, // Reduced spacing
            mainAxisSpacing: 12, // Reduced spacing
            childAspectRatio: 0.65, // Adjusted aspect ratio for smaller cards
          ),
          itemCount: specialists.length,
          itemBuilder: (context, index) {
            final specialist = specialists[index];
            return _buildSpecialistCard(context, specialist);
          },
        ),

        // Show more indicator if there are many results
        if (specialists.length > 9) ...[
          // Changed from 6 to 9 for 3x3 grid
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => _showAllSpecialists(),
              child: const Text(
                'Load More Results',
                style: TextStyle(
                  color: AppTheme.primaryYellow,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSpecialistCard(
    BuildContext context,
    Map<String, dynamic> specialist,
  ) {
    return GestureDetector(
      onTap: () => _navigateToSpecialistDetail(specialist),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(12), // Reduced from 16
          border: Border.all(color: AppTheme.grey300, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppTheme.black.withValues(alpha: 0.05),
              blurRadius: 8, // Reduced from 10
              offset: const Offset(0, 3), // Reduced from 5
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section - Fixed height
            Container(
              height: 80, // Fixed height instead of Expanded
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                color: AppTheme.grey50,
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Stack(
                  children: [
                    Image.network(
                      specialist['image'] as String,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppTheme.grey50,
                          child: const Center(
                            child: Icon(
                              Icons.person,
                              size: 30, // Reduced from 40
                              color: AppTheme.primaryYellow,
                            ),
                          ),
                        );
                      },
                    ),
                    // Gender indicator - smaller
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: 18, // Reduced from 24
                        height: 18, // Reduced from 24
                        decoration: BoxDecoration(
                          color: specialist['gender'] == 'male'
                              ? Colors.blue
                              : Colors.pink,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Icon(
                          specialist['gender'] == 'male'
                              ? Icons.male
                              : Icons.female,
                          color: Colors.white,
                          size: 10, // Reduced from 14
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Content Section - Flexible but constrained
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8), // Reduced from 12
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name - smaller font
                    Text(
                      specialist['name'] as String,
                      style: const TextStyle(
                        fontSize: 12, // Reduced from 14
                        fontWeight: FontWeight.bold,
                        color: AppTheme.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2), // Reduced from 4
                    // Categories - smaller
                    Text(
                      (specialist['categories'] as List).first,
                      style: const TextStyle(
                        fontSize: 10, // Reduced from 12
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2), // Reduced from 4
                    // Rating and Price - smaller
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 10, // Reduced from 12
                              color: AppTheme.primaryYellow,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              (specialist['rating'] as double).toStringAsFixed(
                                1,
                              ),
                              style: const TextStyle(
                                fontSize: 10, // Reduced from 12
                                fontWeight: FontWeight.w600,
                                color: AppTheme.black,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          specialist['price'] as String,
                          style: const TextStyle(
                            fontSize: 10, // Reduced from 12
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryYellow,
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

  void _navigateToSpecialistDetail(Map<String, dynamic> specialist) {
    // Navigate to portfolio page with specialist details
    Get.toNamed(AppRoutes.portfolio, arguments: specialist);
  }

  void _bookSpecialist(Map<String, dynamic> specialist) {
    // Navigate directly to booking with pre-selected specialist
    Get.toNamed(
      AppRoutes.bookingService,
      arguments: {
        'specialist': specialist,
        'category': _selectedCategory,
        'directBooking': true,
      },
    );
  }

  // Notification handler
  void _handleNotificationTap() {
    print('Notification bell tapped!');
    _showNotificationPanel();
  }

  void _showNotificationPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.black,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      for (var notification in _notifications) {
                        notification['isRead'] = true;
                      }
                    });
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Mark all as read',
                    style: TextStyle(
                      color: AppTheme.primaryYellow,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Notification List
            Expanded(
              child: ListView.builder(
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  final isRead = notification['isRead'] as bool;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isRead
                          ? AppTheme.grey100
                          : AppTheme.primaryYellow.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isRead
                            ? AppTheme.grey300
                            : AppTheme.primaryYellow.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification['title'] as String,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isRead
                                      ? FontWeight.w500
                                      : FontWeight.bold,
                                  color: AppTheme.black,
                                ),
                              ),
                            ),
                            if (!isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF6B35),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          notification['message'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          notification['time'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearAllFiltersAndSearch() {
    setState(() {
      _searchQuery = '';
      _selectedGender = 'all';
      _minPrice = 0;
      _maxPrice = 100;
      _minRating = 0;
      _filtersApplied = false;
    });
  }

  void _showAllSpecialists() {
    // Navigate to search page with all specialists for current category
    Get.toNamed(
      AppRoutes.search,
      arguments: {'category': _selectedCategory, 'showAll': true},
    );
  }

  Widget _buildHairdressingSection(BuildContext context) {
    final specialists = _filteredSpecialists;
    final isSearchingOrFiltered = _searchQuery.isNotEmpty || _filtersApplied;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isSearchingOrFiltered ? 'Results' : _selectedCategory,
              style: const TextStyle(
                color: AppTheme.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isSearchingOrFiltered)
              Text(
                '${specialists.length} found',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              )
            else
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'See All',
                  style: TextStyle(
                    color: AppTheme.primaryYellow,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (specialists.isEmpty)
          Container(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSearchingOrFiltered
                        ? Icons.search_off
                        : Icons.person_search,
                    size: 48,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isSearchingOrFiltered
                        ? 'No specialists found matching your criteria'
                        : 'No specialists available for this category',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (isSearchingOrFiltered)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: TextButton(
                        onPressed: _clearFilters,
                        child: const Text(
                          'Clear Filters',
                          style: TextStyle(
                            color: AppTheme.primaryYellow,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 240,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: specialists.length,
              itemBuilder: (context, index) {
                final specialist = specialists[index];
                return Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.grey300, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      Expanded(
                        flex: 3,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            color: AppTheme.grey50,
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            child: Stack(
                              children: [
                                Image.network(
                                  specialist['image'] as String,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: AppTheme.grey50,
                                      child: const Center(
                                        child: Icon(
                                          Icons.person,
                                          size: 40,
                                          color: AppTheme.primaryYellow,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                // Gender indicator
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: specialist['gender'] == 'male'
                                          ? Colors.blue
                                          : Colors.pink,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      specialist['gender'] == 'male'
                                          ? Icons.male
                                          : Icons.female,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Content
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                specialist['name'] as String,
                                style: const TextStyle(
                                  color: AppTheme.black,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 10,
                                    color: AppTheme.primaryYellow,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${specialist['rating']}',
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    specialist['price'] as String,
                                    style: const TextStyle(
                                      color: AppTheme.primaryYellow,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryYellow,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: AppTheme.black,
                                      size: 16,
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
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildFilterModal() {
    String tempGender = _selectedGender;
    double tempMinPrice = _minPrice;
    double tempMaxPrice = _maxPrice;
    double tempMinRating = _minRating;

    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.black,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _clearFilters(),
                    child: const Text(
                      'Clear All',
                      style: TextStyle(
                        color: AppTheme.primaryYellow,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Gender Filter
              const Text(
                'Gender',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.black,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildGenderChip('All', 'all', tempGender, (value) {
                    print('Gender selected in modal: $value');
                    setModalState(() {
                      tempGender = value;
                      print('tempGender updated to: $tempGender');
                    });
                  }),
                  const SizedBox(width: 12),
                  _buildGenderChip('Male', 'male', tempGender, (value) {
                    print('Gender selected in modal: $value');
                    setModalState(() {
                      tempGender = value;
                      print('tempGender updated to: $tempGender');
                    });
                  }),
                  const SizedBox(width: 12),
                  _buildGenderChip('Female', 'female', tempGender, (value) {
                    print('Gender selected in modal: $value');
                    setModalState(() {
                      tempGender = value;
                      print('tempGender updated to: $tempGender');
                    });
                  }),
                ],
              ),

              const SizedBox(height: 24),

              // Price Range Filter
              const Text(
                'Price Range',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.black,
                ),
              ),
              const SizedBox(height: 12),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$${tempMinPrice.toInt()}'),
                      Text('\$${tempMaxPrice.toInt()}'),
                    ],
                  ),
                  RangeSlider(
                    values: RangeValues(tempMinPrice, tempMaxPrice),
                    min: 0,
                    max: 100,
                    divisions: 20,
                    activeColor: AppTheme.primaryYellow,
                    inactiveColor: AppTheme.grey300,
                    onChanged: (values) {
                      setModalState(() {
                        tempMinPrice = values.start;
                        tempMaxPrice = values.end;
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Rating Filter
              const Text(
                'Minimum Rating',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.black,
                ),
              ),
              const SizedBox(height: 12),
              Slider(
                value: tempMinRating,
                min: 0,
                max: 5,
                divisions: 10,
                activeColor: AppTheme.primaryYellow,
                inactiveColor: AppTheme.grey300,
                label: '${tempMinRating.toStringAsFixed(1)} stars',
                onChanged: (value) {
                  setModalState(() => tempMinRating = value);
                },
              ),

              const Spacer(),

              // Apply Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _applyFilters(
                    gender: tempGender,
                    minPrice: tempMinPrice,
                    maxPrice: tempMaxPrice,
                    minRating: tempMinRating,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryYellow,
                    foregroundColor: AppTheme.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
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
      },
    );
  }

  Widget _buildGenderChip(
    String label,
    String value,
    String selectedValue,
    Function(String) onTap,
  ) {
    final isSelected = selectedValue == value;
    print(
      'Building gender chip: $label, isSelected: $isSelected, selectedValue: $selectedValue',
    );
    return GestureDetector(
      onTap: () {
        print('Gender chip tapped: $label ($value)');
        onTap(value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryYellow : AppTheme.grey100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryYellow : AppTheme.grey300,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.black : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppTheme.black,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              icon: Icons.home,
              label: 'Home',
              isSelected: true,
              onTap: () {},
            ),
            _buildNavItem(
              icon: Icons.search,
              label: 'Search',
              isSelected: false,
              onTap: () => Get.toNamed(AppRoutes.search),
            ),
            _buildNavItem(
              icon: Icons.favorite_border,
              label: 'Favorites',
              isSelected: false,
              onTap: () {
                _showFavoritesPage();
              },
            ),
            _buildNavItem(
              icon: Icons.settings,
              label: 'Settings',
              isSelected: false,
              onTap: () {
                _showSettingsPage();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppTheme.primaryYellow : AppTheme.grey400,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppTheme.primaryYellow : AppTheme.grey400,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  void _showFavoritesPage() {
    // Show favorites page (for now, show a toast)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Favorites page coming soon!'),
        backgroundColor: AppTheme.primaryYellow,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    );
  }

  void _showSettingsPage() {
    // Navigate to settings page
    Get.toNamed('/settings', arguments: {'fromHome': true});
  }
}
