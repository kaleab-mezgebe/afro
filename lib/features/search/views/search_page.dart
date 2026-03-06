import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/shegabet_theme.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // Sample data for demonstration
  final List<Map<String, dynamic>> _allSalons = [
    {
      'id': '1',
      'name': 'Afro Cuts Salon',
      'category': 'Hairdressing',
      'rating': 4.9,
      'distance': 2.3,
      'priceRange': '\$30-\$80',
      'image': 'https://picsum.photos/seed/salon1/100/100.jpg',
      'services': ['Haircut', 'Styling', 'Coloring'],
      'location': 'Nairobi CBD',
    },
    {
      'id': '2',
      'name': 'Barber Joe',
      'category': 'Beard & Mustache',
      'rating': 4.8,
      'distance': 1.5,
      'priceRange': '\$25-\$60',
      'image': 'https://picsum.photos/seed/salon2/100/100.jpg',
      'services': ['Beard Trim', 'Shave', 'Haircut'],
      'location': 'Westlands',
    },
    {
      'id': '3',
      'name': 'Style Studio',
      'category': 'Full Service',
      'rating': 4.7,
      'distance': 3.1,
      'priceRange': '\$40-\$120',
      'image': 'https://picsum.photos/seed/salon3/100/100.jpg',
      'services': ['Haircut', 'Styling', 'Treatment', 'Coloring'],
      'location': 'Kilimani',
    },
    {
      'id': '4',
      'name': 'Gentle Cuts',
      'category': 'Men\'s Grooming',
      'rating': 4.6,
      'distance': 4.2,
      'priceRange': '\$20-\$50',
      'image': 'https://picsum.photos/seed/salon4/100/100.jpg',
      'services': ['Haircut', 'Beard Trim', 'Shave'],
      'location': 'Karen',
    },
    {
      'id': '5',
      'name': 'Urban Styles',
      'category': 'Trendy Cuts',
      'rating': 4.5,
      'distance': 2.8,
      'priceRange': '\$35-\$90',
      'image': 'https://picsum.photos/seed/salon5/100/100.jpg',
      'services': ['Modern Cut', 'Styling', 'Coloring'],
      'location': 'Lavington',
    },
  ];

  List<Map<String, dynamic>> _filteredSalons = [];
  String _searchQuery = '';
  String _selectedGender = 'all'; // all, male, female
  double _minPrice = 0;
  double _maxPrice = 100;
  double _minRating = 0;
  double _maxDistance = 10; // Maximum distance in km
  bool _filtersApplied = false;
  bool _showMap = false;

  // Mock providers for map view
  final List<Map<String, dynamic>> _mockProviders = [
    {
      'id': '1',
      'name': 'Afro Cuts Salon',
      'location': 'Nairobi CBD',
      'image': 'https://picsum.photos/seed/afro_cuts/400/300.jpg',
      'rating': 4.8,
      'category': 'salon',
    },
    {
      'id': '2',
      'name': 'Barber Joe',
      'location': 'Westlands',
      'image': 'https://picsum.photos/seed/barber_joe/400/300.jpg',
      'rating': 4.9,
      'category': 'barber',
    },
    {
      'id': '3',
      'name': 'Style Studio',
      'location': 'Kilimani',
      'image': 'https://picsum.photos/seed/style_studio/400/300.jpg',
      'rating': 4.7,
      'category': 'salon',
    },
  ];

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
  ];

  @override
  void initState() {
    super.initState();
    _filteredSalons = List.from(_allSalons);
  }

  void _updateSearch(String query) {
    setState(() {
      _searchQuery = query;
      _filterSalons();
    });
  }

  void _filterSalons() {
    List<Map<String, dynamic>> results = List.from(_allSalons);

    // Apply search query
    if (_searchQuery.isNotEmpty) {
      results = results.where((salon) {
        final name = salon['name'].toString().toLowerCase();
        final category = salon['category'].toString().toLowerCase();
        final services = salon['services'].join(' ').toString().toLowerCase();
        final query = _searchQuery.toLowerCase();

        return name.contains(query) ||
            category.contains(query) ||
            services.contains(query);
      }).toList();
    }

    // Apply gender filter
    if (_selectedGender != 'all') {
      results = results.where((salon) {
        final category = salon['category'].toString().toLowerCase();
        if (_selectedGender == 'male') {
          return category.contains('beard') ||
              category.contains('shaving') ||
              category.contains('men\'s') ||
              category.contains('barber');
        }
        if (_selectedGender == 'female') {
          return category.contains('makeup') ||
              category.contains('hair color') ||
              category.contains('styling');
        }
        return true;
      }).toList();
    }

    // Apply price filter
    if (_minPrice > 0 || _maxPrice < 100) {
      results = results.where((salon) {
        final priceRange = salon['priceRange'].toString();
        final priceMatch = RegExp(r'\$(\d+)').firstMatch(priceRange);
        if (priceMatch != null) {
          final minPrice = double.tryParse(priceMatch.group(1) ?? '0') ?? 0;
          return minPrice >= _minPrice && minPrice <= _maxPrice;
        }
        return false;
      }).toList();
    }

    // Apply rating filter
    if (_minRating > 0) {
      results = results
          .where((salon) => salon['rating'] >= _minRating)
          .toList();
    }

    // Apply distance filter
    if (_maxDistance < 10) {
      results = results
          .where((salon) => salon['distance'] <= _maxDistance)
          .toList();
    }

    setState(() {
      _filteredSalons = results;
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
    double? maxDistance,
  }) {
    setState(() {
      if (gender != null) _selectedGender = gender;
      if (minPrice != null) _minPrice = minPrice;
      if (maxPrice != null) _maxPrice = maxPrice;
      if (minRating != null) _minRating = minRating;
      if (maxDistance != null) _maxDistance = maxDistance;
      _filtersApplied = true;
      _filterSalons();
    });
    Navigator.pop(context);
  }

  void _clearFilters() {
    setState(() {
      _selectedGender = 'all';
      _minPrice = 0;
      _maxPrice = 100;
      _minRating = 0;
      _maxDistance = 10;
      _filtersApplied = false;
      _filterSalons();
    });
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
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

    if (_maxDistance < 10) {
      filters.add('≤${_maxDistance.toInt()} km');
    }

    if (_searchQuery.isNotEmpty) {
      filters.add('"$_searchQuery"');
    }

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
            // Search Bar
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: _buildSearchBar(context),
            ),

            // Content Area
            Expanded(
              child: Column(
                children: [
                  // Show filter summary when searching or filtering
                  if (_hasActiveFilters) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildFilterSummaryBar(context),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Scrollable Content - Results or Default
                  Expanded(
                    child: _hasActiveFilters
                        ? _buildSearchResults(context)
                        : _buildDefaultContent(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.grey100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        onChanged: _updateSearch,
        decoration: InputDecoration(
          hintText: 'Search for a barber or salon...',
          hintStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          border: InputBorder.none,
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppTheme.black,
            size: 22,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.tune_rounded,
              color: _filtersApplied ? AppTheme.primaryYellow : AppTheme.black,
              size: 22,
            ),
            onPressed: _showFilterModal,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSummaryBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryYellow.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _filterSummary,
              style: const TextStyle(
                color: AppTheme.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: _clearFilters,
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
    );
  }

  Widget _buildFilterModal() {
    String tempGender = _selectedGender;
    double tempMinPrice = _minPrice;
    double tempMaxPrice = _maxPrice;
    double tempMinRating = _minRating;
    double tempMaxDistance = _maxDistance;

    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
                      setModalState(() {
                        tempGender = value;
                      });
                    }),
                    const SizedBox(width: 12),
                    _buildGenderChip('Male', 'male', tempGender, (value) {
                      setModalState(() {
                        tempGender = value;
                      });
                    }),
                    const SizedBox(width: 12),
                    _buildGenderChip('Female', 'female', tempGender, (value) {
                      setModalState(() {
                        tempGender = value;
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
                        Text(
                          '\$${tempMinPrice.toInt()}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.black,
                          ),
                        ),
                        Text(
                          '\$${tempMaxPrice.toInt()}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppTheme.primaryYellow,
                        inactiveTrackColor: AppTheme.grey100,
                        thumbColor: AppTheme.primaryYellow,
                      ),
                      child: Slider(
                        value: tempMinPrice,
                        min: 0,
                        max: 100,
                        divisions: 20,
                        onChanged: (value) {
                          setModalState(() {
                            tempMinPrice = value;
                          });
                        },
                      ),
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppTheme.primaryYellow,
                        inactiveTrackColor: AppTheme.grey100,
                        thumbColor: AppTheme.primaryYellow,
                      ),
                      child: Slider(
                        value: tempMaxPrice,
                        min: 0,
                        max: 100,
                        divisions: 20,
                        onChanged: (value) {
                          setModalState(() {
                            tempMaxPrice = value;
                          });
                        },
                      ),
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
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppTheme.primaryYellow,
                    inactiveTrackColor: AppTheme.grey100,
                    thumbColor: AppTheme.primaryYellow,
                  ),
                  child: Slider(
                    value: tempMinRating,
                    min: 0,
                    max: 5,
                    divisions: 10,
                    onChanged: (value) {
                      setModalState(() {
                        tempMinRating = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${tempMinRating.toStringAsFixed(1)}+ stars',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.black,
                  ),
                ),

                const SizedBox(height: 24),

                // Distance Filter
                const Text(
                  'Maximum Distance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.black,
                  ),
                ),
                const SizedBox(height: 12),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppTheme.primaryYellow,
                    inactiveTrackColor: AppTheme.grey100,
                    thumbColor: AppTheme.primaryYellow,
                  ),
                  child: Slider(
                    value: tempMaxDistance,
                    min: 1,
                    max: 20,
                    divisions: 19,
                    onChanged: (value) {
                      setModalState(() {
                        tempMaxDistance = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '≤${tempMaxDistance.toInt()} km',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.black,
                  ),
                ),

                const SizedBox(height: 32),

                // Apply Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _applyFilters(
                        gender: tempGender,
                        minPrice: tempMinPrice,
                        maxPrice: tempMaxPrice,
                        minRating: tempMinRating,
                        maxDistance: tempMaxDistance,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryYellow,
                      foregroundColor: AppTheme.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryYellow : AppTheme.grey100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryYellow : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.black : AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    if (_filteredSalons.isEmpty) {
      return _buildEmptyResults(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _filteredSalons.length,
      itemBuilder: (context, index) {
        final salon = _filteredSalons[index];
        return _buildSpecialistCard(salon);
      },
    );
  }

  Widget _buildFilterResultsSection(BuildContext context) {
    final specialists = _filteredSalons;
    final isSearchingOrFiltered = _hasActiveFilters;

    if (isSearchingOrFiltered) {
      // Apply filters to the data
      List<Map<String, dynamic>> filteredResults = List.from(_allSalons);

      if (_searchQuery.isNotEmpty) {
        filteredResults = filteredResults.where((salon) {
          final name = salon['name'].toString().toLowerCase();
          final category = salon['category'].toString().toLowerCase();
          final services = salon['services'].join(' ').toString().toLowerCase();
          final query = _searchQuery.toLowerCase();

          return name.contains(query) ||
              category.contains(query) ||
              services.contains(query);
        }).toList();
      }

      if (_selectedGender != 'all') {
        filteredResults = filteredResults.where((salon) {
          // Filter by gender based on category
          final category = salon['category'].toString().toLowerCase();
          if (_selectedGender == 'male' &&
              (category.contains('beard') ||
                  category.contains('shaving') ||
                  category.contains('men\'s'))) {
            return true;
          }
          if (_selectedGender == 'female' &&
              (category.contains('makeup') ||
                  category.contains('hair color'))) {
            return true;
          }
          return _selectedGender == 'all';
        }).toList();
      }

      if (_minPrice > 0 || _maxPrice < 100) {
        filteredResults = filteredResults.where((salon) {
          // Extract min price from price range
          final priceRange = salon['priceRange'].toString();
          final priceMatch = RegExp(r'\$(\d+)-\$').firstMatch(priceRange);
          if (priceMatch != null) {
            final minPrice = double.tryParse(priceMatch.group(1) ?? '');
            if (minPrice != null &&
                minPrice >= _minPrice &&
                minPrice <= _maxPrice) {
              return true;
            }
          }
          return false;
        }).toList();
      }

      if (_minRating > 0) {
        filteredResults = filteredResults
            .where((salon) => salon['rating'] >= _minRating)
            .toList();
      }

      if (_maxDistance < 10) {
        filteredResults = filteredResults
            .where((salon) => salon['distance'] <= _maxDistance)
            .toList();
      }

      if (filteredResults.isEmpty) {
        return _buildEmptyResults(context);
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filteredResults.length,
        itemBuilder: (context, index) {
          final salon = filteredResults[index];
          return _buildSpecialistCard(salon);
        },
      );
    }

    // Show default content when no filters
    return _buildDefaultContent(context);
  }

  Widget _buildEmptyResults(BuildContext context) {
    final isSearchingOrFiltered = _hasActiveFilters;

    return Container(
      height: 300,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.grey100),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: AppTheme.textSecondary),
          const SizedBox(height: 16),
          Text(
            'No salons found',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Access Section
          const Text(
            'Quick Access',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickAccessCard(
                  'Book Now',
                  Icons.calendar_today,
                  () => Get.toNamed('/booking/service'),
                  isPrimary: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAccessCard(
                  'Nearby',
                  Icons.location_on,
                  _showNearbySalonsMap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickAccessCard(
                  'Services',
                  Icons.content_cut,
                  _showServicesDialog,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAccessCard(
                  'Top Rated',
                  Icons.star,
                  _showTopRatedDialog,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Featured Section
          const Text(
            'Featured Salons',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _allSalons.take(3).length,
              itemBuilder: (context, index) {
                return _buildFeaturedSalonCard(_allSalons[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessCard(
    String title,
    IconData icon,
    Function onTap, {
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: isPrimary ? AppTheme.primaryYellow : AppTheme.grey100,
          borderRadius: BorderRadius.circular(16),
          border: isPrimary ? null : Border.all(color: AppTheme.grey300),
          boxShadow: [
            if (isPrimary)
              BoxShadow(
                color: AppTheme.primaryYellow.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            if (!isPrimary)
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isPrimary
                    ? Colors.white
                    : AppTheme.primaryYellow.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isPrimary
                    ? AppTheme.primaryYellow
                    : AppTheme.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isPrimary
                    ? AppTheme.textSecondary
                    : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedSalonCard(Map<String, dynamic> salon) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryYellow.withValues(alpha: 0.2),
                  AppTheme.primaryYellow.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryYellow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          color: AppTheme.textSecondary,
                          size: 10,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          salon['rating'].toStringAsFixed(1),
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.spa,
                      color: AppTheme.primaryYellow,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        salon['name'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        salon['category'],
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryYellow.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Book Now',
                      style: const TextStyle(
                        fontSize: 8,
                        color: AppTheme.primaryYellow,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialistCard(Map<String, dynamic> specialist) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: AppTheme.primaryYellow,
          child: Text(
            specialist['name'][0],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        title: Text(
          specialist['name'],
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.textSecondary,
          ),
        ),
        subtitle: Text(
          specialist['category'],
          style: TextStyle(fontSize: 10, color: AppTheme.textSecondary),
        ),
      ),
    );
  }

  void _showTopRatedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Top Rated Salons',
          style: TextStyle(color: AppTheme.black),
        ),
        content: const Text(
          'Our top-rated salons:\n1. Afro Cuts Salon - 4.9⭐\n2. Style Studio - 4.8⭐\n3. Urban Styles - 4.7⭐',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: AppTheme.primaryYellow),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Filter Options',
          style: TextStyle(color: Colors.black),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.location_on, color: Colors.black),
              title: const Text(
                'Distance',
                style: TextStyle(color: Colors.black),
              ),
              subtitle: const Text('Within 5 km'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.star, color: Colors.black),
              title: const Text(
                'Rating',
                style: TextStyle(color: Colors.black),
              ),
              subtitle: const Text('4+ stars'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.attach_money, color: Colors.black),
              title: const Text(
                'Price Range',
                style: TextStyle(color: Colors.black),
              ),
              subtitle: const Text('\$25 - \$100'),
              onTap: () {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildTopRatedItem(String name, double rating, String category) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.amber,
        child: Text(name[0], style: const TextStyle(color: Colors.black)),
      ),
      title: Text(name, style: const TextStyle(color: Colors.black)),
      subtitle: Text(category, style: const TextStyle(color: Colors.black)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 16),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(color: Colors.black),
          ),
        ],
      ),
      onTap: () {
        Navigator.pop(context);
        // Navigate to portfolio
      },
    );
  }

  Widget _buildCleanSearchContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Featured Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.textSecondary),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.textSecondary.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Featured Salons',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 120,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.textSecondary.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppTheme.textSecondary.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(8),
                                ),
                              ),
                              child: const Icon(
                                Icons.spa,
                                size: 32,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Salon ${index + 1}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: AppTheme.textSecondary,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '4.${8 - index}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
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

          const SizedBox(height: 20),

          // Quick Actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.textSecondary),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.textSecondary.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionCard(
                        'Book Now',
                        Icons.calendar_today,
                        AppTheme.textSecondary,
                        () => Get.toNamed('/booking/service'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickActionCard(
                        'Nearby',
                        Icons.location_on,
                        Colors.orange,
                        _showNearbySalonsMap,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionCard(
                        'Services',
                        Icons.content_cut,
                        Colors.purple,
                        _showServicesDialog,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickActionCard(
                        'Top Rated',
                        Icons.star,
                        Colors.amber,
                        _showTopRatedDialog,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Recent Searches
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.textSecondary),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.textSecondary.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Searches',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      [
                            'Haircut',
                            'Beard Trim',
                            'Hair Coloring',
                            'Facial',
                            'Manicure',
                            'Pedicure',
                          ]
                          .map(
                            (tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.textSecondary.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppTheme.textSecondary.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: Text(
                                tag,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    Function onTap,
  ) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      child: Row(
        children: [
          const Text(
            'Category:',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButton<String>(
              value: 'All',
              hint: const Text('Select category'),
              items: const [],
              onChanged: (value) {},
              style: const TextStyle(color: ShegabetTheme.ethiopianGold),
              dropdownColor: ShegabetTheme.ethiopianGold,
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersRow() {
    return Container(
      height: 80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating Filter
          Row(
            children: [
              const Text(
                'Min Rating:',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Slider(
                  value: 0.0,
                  min: 0.0,
                  max: 5.0,
                  divisions: 10,
                  activeColor: ShegabetTheme.ethiopianGold,
                  inactiveColor: Colors.white.withOpacity(0.7),
                  onChanged: (value) {},
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Price Range
          Row(
            children: [
              const Text(
                'Price Range:',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: 0.0,
                        min: 0.0,
                        max: 100.0,
                        divisions: 20,
                        activeColor: ShegabetTheme.ethiopianGold,
                        inactiveColor: Colors.white.withOpacity(0.7),
                        onChanged: (value) {},
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('\$0', style: const TextStyle(color: Colors.white)),
                    Expanded(
                      child: Slider(
                        value: 100.0,
                        min: 0.0,
                        max: 100.0,
                        divisions: 20,
                        activeColor: ShegabetTheme.ethiopianGold,
                        inactiveColor: Colors.white.withOpacity(0.7),
                        onChanged: (value) {},
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Location Filter
          Row(
            children: [
              const Text(
                'Location:',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  onChanged: (value) {},
                  decoration: InputDecoration(
                    hintText: 'Enter location',
                    prefixIcon: const Icon(
                      Icons.location_on,
                      color: ShegabetTheme.textLight,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: ShegabetTheme.ethiopianGold,
                      ),
                    ),
                    hintStyle: const TextStyle(color: ShegabetTheme.textLight),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),

          // Clear Filters Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: ShegabetTheme.ethiopianGold,
                elevation: 0,
              ),
              child: const Text(
                'Apply Filters',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showMap = false;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_showMap
                      ? ShegabetTheme.ethiopianGold
                      : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: const Text(
                  'List View',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showMap = true;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _showMap
                      ? ShegabetTheme.ethiopianGold
                      : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: const Text(
                  'Map View',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_showMap) {
      return _buildMapView();
    } else {
      return _buildListView();
    }
  }

  Widget _buildListView() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        itemCount: _mockProviders.length,
        itemBuilder: (context, index) {
          final provider = _mockProviders[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                radius: 25,
                backgroundColor: ShegabetTheme.ethiopianGold,
                child: Text(
                  provider['name'][0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              title: Text(
                provider['name'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                provider['category'].toUpperCase(),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star,
                    color: ShegabetTheme.ethiopianGold,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    provider['rating'].toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              onTap: () {
                // Navigate to provider details
                final providerData = {
                  'id': provider['id'],
                  'name': provider['name'],
                  'image': provider['image'],
                  'rating': provider['rating'],
                  'categories': [
                    provider['category'] == 'salon'
                        ? 'Hairdressing'
                        : 'Beard & Mustache',
                  ],
                  'gender': provider['category'] == 'salon' ? 'female' : 'male',
                  'services': [
                    {
                      'id': 'basic_service',
                      'name': 'Basic Service',
                      'price': '\$25.00',
                      'duration': '30 min',
                    },
                    {
                      'id': 'premium_service',
                      'name': 'Premium Service',
                      'price': '\$45.00',
                      'duration': '60 min',
                    },
                  ],
                  'portfolio': [
                    'https://picsum.photos/seed/${provider['name']}/300/200.jpg',
                    'https://picsum.photos/seed/${provider['name']}2/300/200.jpg',
                    'https://picsum.photos/seed/${provider['name']}3/300/200.jpg',
                  ],
                  'reviews': [
                    {
                      'name': 'Kaleab.',
                      'rating': 5.0,
                      'comment': 'Amazing service! Very professional.',
                      'date': '2 days ago',
                    },
                    {
                      'name': 'Sarah M.',
                      'rating': 4.5,
                      'comment': 'Great experience, will come back!',
                      'date': '1 week ago',
                    },
                  ],
                  'contact': {
                    'phone': '+251 712 345 678',
                    'email':
                        '${provider['name'].toString().toLowerCase().replaceAll(' ', '')}@email.com',
                    'address': '123 Main St, City, Country',
                  },
                };
                Get.toNamed(
                  '/portfolio',
                  arguments: {'specialist': providerData},
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMapView() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 300,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.grey[100]!, Colors.grey[300]!],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map, size: 48, color: Colors.grey[600]),
                SizedBox(height: 16),
                Text(
                  'Map View',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Use search or tap the map icon to see nearby locations',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showServicesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Salon Services'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildServiceItem(
              'Haircut & Styling',
              'Professional haircuts and styling',
            ),
            _buildServiceItem(
              'Hair Coloring',
              'Full and partial coloring services',
            ),
            _buildServiceItem('Beard & Mustache', 'Grooming services for men'),
            _buildServiceItem(
              'Makeup Services',
              'Professional makeup application',
            ),
            _buildServiceItem('Nail Care', 'Manicure and pedicure services'),
            _buildServiceItem(
              'Facial Treatments',
              'Rejuvenating facial treatments',
            ),
            _buildServiceItem(
              'Waxing Services',
              'Professional waxing services',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: ShegabetTheme.deepRoyalPurple,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _showBookingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('My Bookings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildBookingItem(
              'Haircut with Sarah',
              'Today, 2:00 PM',
              'Confirmed',
            ),
            _buildBookingItem(
              'Beard Trim with Joe',
              'Tomorrow, 10:00 AM',
              'Confirmed',
            ),
            _buildBookingItem(
              'Full Color with Style Studio',
              'Friday, 3:00 PM',
              'Pending',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening booking history...'),
                  backgroundColor: ShegabetTheme.ethiopianGold,
                ),
              );
            },
            child: const Text('View All'),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingItem(String service, String time, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            service,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: ShegabetTheme.deepRoyalPurple,
            ),
          ),
          const SizedBox(height: 4),
          Text(time, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: status == 'Confirmed' ? Colors.green : Colors.orange,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNearbySalonsMap() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey, width: 1),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: ShegabetTheme.deepRoyalPurple,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Nearby Salons & Barbers',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // Map with Circular Avatars
            Expanded(
              child: Stack(
                children: [
                  // Map Background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.grey[100]!, Colors.grey[200]!],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Map View',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ),

                  // Circular Avatar Overlays
                  Positioned.fill(child: _buildNearbySalonsOverlay()),
                ],
              ),
            ),

            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey, width: 1)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showNearbyList();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ShegabetTheme.deepRoyalPurple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'View List',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbySalonsOverlay() {
    // Define positions for circular avatars
    final List<Map<String, dynamic>> nearbySalons = [
      {
        'name': 'Afro Cuts Salon',
        'category': 'salon',
        'rating': 4.8,
        'distance': '0.5 km',
        'position': const Offset(0.2, 0.3),
        'image': 'https://picsum.photos/seed/salon1/100/100.jpg',
      },
      {
        'name': 'Barber Joe',
        'category': 'barber',
        'rating': 4.9,
        'distance': '0.8 km',
        'position': const Offset(0.7, 0.2),
        'image': 'https://picsum.photos/seed/barber1/100/100.jpg',
      },
      {
        'name': 'Style Studio',
        'category': 'salon',
        'rating': 4.7,
        'distance': '1.2 km',
        'position': const Offset(0.4, 0.6),
        'image': 'https://picsum.photos/seed/salon2/100/100.jpg',
      },
      {
        'name': 'Gentle Cuts',
        'category': 'barber',
        'rating': 4.6,
        'distance': '1.5 km',
        'position': const Offset(0.8, 0.7),
        'image': 'https://picsum.photos/seed/barber2/100/100.jpg',
      },
      {
        'name': 'Urban Styles',
        'category': 'salon',
        'rating': 4.9,
        'distance': '2.0 km',
        'position': const Offset(0.3, 0.8),
        'image': 'https://picsum.photos/seed/salon3/100/100.jpg',
      },
    ];

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.6,
      child: Stack(
        children: nearbySalons.map((salon) {
          final screenWidth = MediaQuery.of(context).size.width;
          final screenHeight =
              MediaQuery.of(context).size.height * 0.6; // Available map height

          final left = salon['position'] as Offset;
          final x = left.dx * screenWidth;
          final y = left.dy * screenHeight;

          return Positioned(
            left: x,
            top: y,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _showSalonPortfolio(salon);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Circular Avatar
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: salon['category'] == 'salon'
                          ? Colors.pink.withValues(alpha: 0.9)
                          : Colors.blue.withValues(alpha: 0.9),
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.network(
                        salon['image'] as String,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            salon['category'] == 'salon'
                                ? Icons.spa
                                : Icons.content_cut,
                            color: Colors.white,
                            size: 24,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Info Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          salon['name'] as String,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Container(
                          width: 120,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 10,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                (salon['rating'] as double).toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          salon['distance'] as String,
                          style: const TextStyle(
                            fontSize: 8,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showSalonPortfolio(Map<String, dynamic> salon) {
    // Navigate to portfolio page with salon details
    final salonData = {
      'id': salon['name'].toString().toLowerCase().replaceAll(' ', '_'),
      'name': salon['name'],
      'image': salon['image'],
      'rating': salon['rating'],
      'categories': [
        salon['category'] == 'salon' ? 'Hairdressing' : 'Beard & Mustache',
      ],
      'gender': salon['category'] == 'salon' ? 'female' : 'male',
      'services': [
        {
          'id': 'basic_service',
          'name': 'Basic Service',
          'price': '\$25.00',
          'duration': '30 min',
        },
        {
          'id': 'premium_service',
          'name': 'Premium Service',
          'price': '\$45.00',
          'duration': '60 min',
        },
      ],
      'portfolio': [
        'https://picsum.photos/seed/${salon['name']}/300/200.jpg',
        'https://picsum.photos/seed/${salon['name']}2/300/200.jpg',
        'https://picsum.photos/seed/${salon['name']}3/300/200.jpg',
      ],
      'reviews': [
        {
          'name': 'John D.',
          'rating': 5.0,
          'comment': 'Amazing service! Very professional.',
          'date': '2 days ago',
        },
        {
          'name': 'Sarah M.',
          'rating': 4.5,
          'comment': 'Great experience, will come back!',
          'date': '1 week ago',
        },
      ],
      'contact': {
        'phone': '+251 712 345 678',
        'email':
            '${salon['name'].toString().toLowerCase().replaceAll(' ', '')}@email.com',
        'address': '123 Main St, City, Country',
      },
    };

    Get.toNamed('/portfolio', arguments: {'specialist': salonData});
  }

  void _navigateToSalonPortfolio(Map<String, dynamic> salon) {
    // Navigate to portfolio page with salon details
    final salonData = {
      'id': salon['id'],
      'name': salon['name'],
      'image': salon['image'],
      'rating': salon['rating'],
      'categories': [
        salon['category'] == 'salon' ? 'Hairdressing' : 'Beard & Mustache',
      ],
      'gender': salon['category'] == 'salon' ? 'female' : 'male',
      'services': [
        {
          'id': 'basic_service',
          'name': 'Basic Service',
          'price': '\$25.00',
          'duration': '30 min',
        },
        {
          'id': 'premium_service',
          'name': 'Premium Service',
          'price': '\$45.00',
          'duration': '60 min',
        },
      ],
      'portfolio': [
        'https://picsum.photos/seed/${salon['name']}/300/200.jpg',
        'https://picsum.photos/seed/${salon['name']}2/300/200.jpg',
        'https://picsum.photos/seed/${salon['name']}3/300/200.jpg',
      ],
      'reviews': [
        {
          'name': 'John D.',
          'rating': 5.0,
          'comment': 'Amazing service! Very professional.',
          'date': '2 days ago',
        },
        {
          'name': 'Sarah M.',
          'rating': 4.5,
          'comment': 'Great experience, will come back!',
          'date': '1 week ago',
        },
      ],
      'contact': {
        'phone': '+251 712 345 678',
        'email':
            '${salon['name'].toString().toLowerCase().replaceAll(' ', '')}@email.com',
        'address': '123 Main St, City, Country',
      },
    };
    Get.toNamed('/portfolio', arguments: {'specialist': salonData});
  }

  void _showNearbyList() {
    // Show list view of nearby salons
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nearby Salons & Barbers'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: const Column(
            children: [
              Text('List view coming soon!'),
              SizedBox(height: 20),
              Text(
                'This will show a detailed list of all nearby salons and barbers with filtering options.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
