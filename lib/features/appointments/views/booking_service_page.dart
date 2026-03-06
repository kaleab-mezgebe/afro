import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';

class BookingServicePage extends StatefulWidget {
  const BookingServicePage({super.key});

  @override
  State<BookingServicePage> createState() => _BookingServicePageState();
}

class _BookingServicePageState extends State<BookingServicePage>
    with TickerProviderStateMixin {
  Map<String, dynamic>? _specialist;
  Map<String, dynamic>? _selectedService;
  DateTime? _selectedDate;
  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();

    // Get specialist from arguments
    _specialist = Get.arguments?['specialist'];

    // Initialize animations for amazing customer experience
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Start entrance animations after a short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeController.forward();
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // Sample services based on specialist categories
  List<Map<String, dynamic>> get _availableServices {
    if (_specialist == null) return [];

    final categories = _specialist!['categories'] as List;
    List<Map<String, dynamic>> services = [];

    if (categories.contains('Hairdressing')) {
      services.addAll([
        {
          'id': 'haircut_basic',
          'name': 'Basic Haircut',
          'description': 'Professional haircut with styling',
          'price': '\$25.00',
          'duration': '30 min',
          'category': 'Hairdressing',
          'popular': true,
        },
        {
          'id': 'haircut_premium',
          'name': 'Premium Haircut',
          'description': 'Deluxe haircut with wash and styling',
          'price': '\$45.00',
          'duration': '60 min',
          'category': 'Hairdressing',
        },
        {
          'id': 'haircut_kids',
          'name': 'Kids Haircut',
          'description': 'Gentle haircut for children',
          'price': '\$20.00',
          'duration': '25 min',
          'category': 'Hairdressing',
        },
      ]);
    }

    if (categories.contains('Hair Color')) {
      services.addAll([
        {
          'id': 'color_full',
          'name': 'Full Color',
          'description': 'Complete hair coloring service',
          'price': '\$75.00',
          'duration': '120 min',
          'category': 'Hair Color',
          'popular': true,
        },
        {
          'id': 'color_highlights',
          'name': 'Highlights',
          'description': 'Partial highlights and styling',
          'price': '\$55.00',
          'duration': '90 min',
          'category': 'Hair Color',
        },
        {
          'id': 'color_root_touchup',
          'name': 'Root Touch-up',
          'description': 'Root color retouch service',
          'price': '\$45.00',
          'duration': '60 min',
          'category': 'Hair Color',
        },
      ]);
    }

    if (categories.contains('Beard & Mustache')) {
      services.addAll([
        {
          'id': 'beard_trim',
          'name': 'Beard Trim',
          'description': 'Professional beard shaping and trimming',
          'price': '\$15.00',
          'duration': '20 min',
          'category': 'Beard & Mustache',
          'popular': true,
        },
        {
          'id': 'beard_hot_towel',
          'name': 'Hot Towel Shave',
          'description': 'Traditional hot towel shave experience',
          'price': '\$35.00',
          'duration': '45 min',
          'category': 'Beard & Mustache',
        },
        {
          'id': 'beard_design',
          'name': 'Beard Design',
          'description': 'Custom beard shaping and styling',
          'price': '\$25.00',
          'duration': '30 min',
          'category': 'Beard & Mustache',
        },
      ]);
    }

    if (categories.contains('Makeup')) {
      services.addAll([
        {
          'id': 'makeup_daily',
          'name': 'Daily Makeup',
          'description': 'Natural everyday makeup application',
          'price': '\$40.00',
          'duration': '45 min',
          'category': 'Makeup',
          'popular': true,
        },
        {
          'id': 'makeup_event',
          'name': 'Event Makeup',
          'description': 'Professional makeup for special events',
          'price': '\$85.00',
          'duration': '90 min',
          'category': 'Makeup',
        },
        {
          'id': 'makeup_bridal',
          'name': 'Bridal Makeup',
          'description': 'Complete bridal makeup package',
          'price': '\$150.00',
          'duration': '120 min',
          'category': 'Makeup',
        },
      ]);
    }

    if (categories.contains('Nail Care')) {
      services.addAll([
        {
          'id': 'nails_manicure',
          'name': 'Manicure',
          'description': 'Classic manicure with nail polish',
          'price': '\$30.00',
          'duration': '45 min',
          'category': 'Nail Care',
          'popular': true,
        },
        {
          'id': 'nails_pedicure',
          'name': 'Pedicure',
          'description': 'Complete pedicure treatment',
          'price': '\$45.00',
          'duration': '60 min',
          'category': 'Nail Care',
        },
        {
          'id': 'nails_gel',
          'name': 'Gel Nails',
          'description': 'Gel nail application and design',
          'price': '\$55.00',
          'duration': '75 min',
          'category': 'Nail Care',
        },
      ]);
    }

    if (categories.contains('Facial')) {
      services.addAll([
        {
          'id': 'facial_basic',
          'name': 'Basic Facial',
          'description': 'Rejuvenating facial treatment',
          'price': '\$60.00',
          'duration': '60 min',
          'category': 'Facial',
          'popular': true,
        },
        {
          'id': 'facial_deep',
          'name': 'Deep Cleansing',
          'description': 'Deep pore cleansing facial',
          'price': '\$85.00',
          'duration': '75 min',
          'category': 'Facial',
        },
        {
          'id': 'facial_anti_aging',
          'name': 'Anti-Aging Facial',
          'description': 'Anti-aging treatment with premium products',
          'price': '\$120.00',
          'duration': '90 min',
          'category': 'Facial',
        },
      ]);
    }

    if (categories.contains('Hair Treatment')) {
      services.addAll([
        {
          'id': 'treatment_mask',
          'name': 'Hair Mask',
          'description': 'Deep conditioning hair treatment',
          'price': '\$35.00',
          'duration': '30 min',
          'category': 'Hair Treatment',
          'popular': true,
        },
        {
          'id': 'treatment_keratin',
          'name': 'Keratin Treatment',
          'description': 'Professional keratin smoothing treatment',
          'price': '\$150.00',
          'duration': '180 min',
          'category': 'Hair Treatment',
        },
        {
          'id': 'treatment_scalp',
          'name': 'Scalp Treatment',
          'description': 'Deep scalp cleansing and treatment',
          'price': '\$45.00',
          'duration': '45 min',
          'category': 'Hair Treatment',
        },
      ]);
    }

    if (categories.contains('Waxing')) {
      services.addAll([
        {
          'id': 'wax_eyebrow',
          'name': 'Eyebrow Wax',
          'description': 'Professional eyebrow shaping and waxing',
          'price': '\$20.00',
          'duration': '15 min',
          'category': 'Waxing',
          'popular': true,
        },
        {
          'id': 'wax_full_body',
          'name': 'Full Body Wax',
          'description': 'Complete body waxing service',
          'price': '\$120.00',
          'duration': '120 min',
          'category': 'Waxing',
        },
        {
          'id': 'wax_brazilian',
          'name': 'Brazilian Wax',
          'description': 'Professional Brazilian waxing',
          'price': '\$65.00',
          'duration': '45 min',
          'category': 'Waxing',
        },
      ]);
    }

    return services.isNotEmpty
        ? services
        : [
            {
              'id': 'consultation',
              'name': 'Consultation',
              'description': 'Personal consultation for custom services',
              'price': '\$25.00',
              'duration': '30 min',
              'category': 'General',
              'popular': true,
            },
          ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Book Appointment',
          style: TextStyle(color: AppTheme.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress Indicator (only if specialist selected)
          if (_specialist != null) _buildProgressIndicator(),
          
          Expanded(
            child: _specialist == null 
              ? _buildDiscoveryView()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSpecialistInfo(),
                      const SizedBox(height: 32),
                      if (_selectedService != null) ...[
                        _buildServiceProvidersList(),
                        _buildDateSelector(),
                        _buildServiceTimeTable(),
                        _buildSelectedServiceSummary(),
                      ] else ...[
                        _buildCategorySection(),
                        const SizedBox(height: 24),
                        _buildServiceGrid(),
                      ],
                    ],
                  ),
                ),
          ),
          // Bottom Button (only if specialist selected)
          if (_specialist != null) _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildDiscoveryView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ready for a new look?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose a service and find the perfect specialist.',
            style: TextStyle(color: AppTheme.grey600, fontSize: 16),
          ),
          const SizedBox(height: 32),
          
          _buildDiscoveryCategory('Popular Services', [
            {'icon': Icons.content_cut, 'label': 'Haircut'},
            {'icon': Icons.brush, 'label': 'Color'},
            {'icon': Icons.face, 'label': 'Beard'},
            {'icon': Icons.spa, 'label': 'Spa'},
          ]),
          
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Top Rated Specialists',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.search),
                child: const Text('See All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSpecialistPreviewList(),
        ],
      ),
    );
  }

  Widget _buildDiscoveryCategory(String title, List<Map<String, dynamic>> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.8,
          children: categories.map((cat) => _buildCategoryItem(cat['icon'], cat['label'])).toList(),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.grey50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.grey100),
          ),
          child: Icon(icon, color: AppTheme.primaryYellow),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildSpecialistPreviewList() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [AppTheme.softShadow],
              border: Border.all(color: AppTheme.grey100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.grey100,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: const Center(child: Icon(Icons.person, size: 40, color: AppTheme.grey300)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Premium Barbers',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, color: AppTheme.primaryYellow, size: 12),
                          SizedBox(width: 4),
                          Text('4.9', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategorySection() {
    return const Text('Select a Service', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
  }

  Widget _buildServiceGrid() {
    return Column(
      children: _availableServices.map((service) => _buildServiceRow(service)).toList(),
    );
  }

  Widget _buildServiceRow(Map<String, dynamic> service) {
    final isSelected = _selectedService?['id'] == service['id'];
    return GestureDetector(
      onTap: () => setState(() => _selectedService = service),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryYellow.withValues(alpha: 0.05) : AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryYellow : AppTheme.grey100,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(service['duration'], style: const TextStyle(color: AppTheme.grey600, fontSize: 14)),
                ],
              ),
            ),
            Text(
              service['price'],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryYellow),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildServiceProviderCards() {
    final providers = [
      {
        'id': 'provider1',
        'name': 'Afro Cuts Salon',
        'rating': 4.8,
        'image': 'https://picsum.photos/seed/afro_cuts/200/150.jpg',
        'services': ['Hairdressing', 'Hair Color'],
        'location': 'Nairobi CBD',
        'distance': '0.5 km',
        'isOpen': true,
      },
      {
        'id': 'provider2',
        'name': 'Style Studio',
        'rating': 4.9,
        'image': 'https://picsum.photos/seed/style_studio/200/150.jpg',
        'services': ['Hairdressing', 'Hair Color'],
        'location': 'Westlands',
        'distance': '0.8 km',
        'isOpen': true,
      },
      {
        'id': 'provider3',
        'name': 'Gentle Cuts',
        'rating': 4.6,
        'image': 'https://picsum.photos/seed/gentle_cuts/200/150.jpg',
        'services': ['Beard & Mustache'],
        'location': 'Kilimani',
        'distance': '1.2 km',
        'isOpen': false,
      },
    ];

    return providers
        .map((provider) => _buildServiceProviderCard(provider))
        .toList();
  }

  Widget _buildServiceProvidersList() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Service Providers',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 12),
          // Service Provider Cards
          ..._buildServiceProviderCards(),
        ],
      ),
    );
  }

  Widget _buildServiceProviderCard(Map<String, dynamic> provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Provider Image and Info
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppTheme.grey100,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    provider['image'] as String,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppTheme.grey100,
                        child: const Icon(
                          Icons.person,
                          size: 30,
                          color: AppTheme.primaryYellow,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider['name'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: AppTheme.primaryYellow,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          provider['rating'].toStringAsFixed(1),
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          provider['location'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          provider['isOpen'] as bool
                              ? Icons.access_time
                              : Icons.access_time,
                          color: provider['isOpen'] as bool
                              ? Colors.green
                              : Colors.grey,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          provider['isOpen'] as bool ? 'Open Now' : 'Closed',
                          style: TextStyle(
                            fontSize: 12,
                            color: provider['isOpen'] as bool
                                ? Colors.green
                                : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Services Offered
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Services Offered:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: (provider['services'] as List)
                    .map<Widget>(
                      (service) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryYellow.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          service as String,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          SizedBox(height: 12),
          // Action Button
          GestureDetector(
            onTap: () => _bookWithProvider(provider),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryYellow,
                    AppTheme.primaryYellow.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryYellow.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: AppTheme.black,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Book Now',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward,
                    color: AppTheme.black,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          // Additional Info Row
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // View Profile Button
              GestureDetector(
                onTap: () => _viewProviderProfile(provider),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.primaryYellow),
                  ),
                  child: const Text(
                    'View Profile',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryYellow,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              // Distance Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.grey100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 12,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      provider['distance'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _bookWithProvider(Map<String, dynamic> provider) {
    // Navigate to time selection with provider data
    final providerData = {
      'id': provider['id'],
      'name': provider['name'],
      'image': provider['image'],
      'rating': provider['rating'],
      'categories': provider['services'] as List,
      'gender': 'all',
      'services': [
        {
          'id': 'consultation',
          'name': 'Consultation',
          'price': '\$25.00',
          'duration': '30 min',
          'category': 'General',
          'popular': true,
        },
        {
          'id': 'basic_haircut',
          'name': 'Basic Haircut',
          'price': '\$35.00',
          'duration': '45 min',
          'category': 'Hairdressing',
        },
        {
          'id': 'premium_haircut',
          'name': 'Premium Haircut',
          'price': '\$55.00',
          'duration': '60 min',
          'category': 'Hairdressing',
          'popular': true,
        },
        {
          'id': 'beard_trim',
          'name': 'Beard Trim',
          'price': '\$20.00',
          'duration': '20 min',
          'category': 'Beard & Mustache',
        },
      ],
      'portfolio': [
        'https://picsum.photos/seed/${provider['name']}/300/200.jpg',
        'https://picsum.photos/seed/${provider['name']}2/300/200.jpg',
        'https://picsum.photos/seed/${provider['name']}3/300/200.jpg',
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
            '${provider['name'].toString().toLowerCase().replaceAll(' ', '')}@email.com',
        'address': '123 Main St, City, Country',
      },
    };

    // Navigate to time selection with provider as specialist
    Get.toNamed(
      AppRoutes.bookingTime,
      arguments: {
        'specialist': providerData,
        'service': {
          'id': 'consultation',
          'name': 'Consultation',
          'price': '\$25.00',
          'duration': '30 min',
          'category': 'General',
        },
      },
    );
  }

  void _viewProviderProfile(Map<String, dynamic> provider) {
    // Navigate to provider portfolio with complete data
    final providerData = {
      'id': provider['id'],
      'name': provider['name'],
      'image': provider['image'],
      'rating': provider['rating'],
      'categories': provider['services'] as List,
      'gender': 'all',
      'services': [
        {
          'id': 'consultation',
          'name': 'Consultation',
          'price': '\$25.00',
          'duration': '30 min',
          'category': 'General',
        },
        {
          'id': 'basic_haircut',
          'name': 'Basic Haircut',
          'price': '\$35.00',
          'duration': '45 min',
          'category': 'Hairdressing',
        },
        {
          'id': 'premium_haircut',
          'name': 'Premium Haircut',
          'price': '\$55.00',
          'duration': '60 min',
          'category': 'Hairdressing',
        },
        {
          'id': 'beard_trim',
          'name': 'Beard Trim',
          'price': '\$20.00',
          'duration': '20 min',
          'category': 'Beard & Mustache',
        },
      ],
      'portfolio': [
        'https://picsum.photos/seed/${provider['name']}/300/200.jpg',
        'https://picsum.photos/seed/${provider['name']}2/300/200.jpg',
        'https://picsum.photos/seed/${provider['name']}3/300/200.jpg',
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
            '${provider['name'].toString().toLowerCase().replaceAll(' ', '')}@email.com',
        'address': '123 Main St, City, Country',
      },
    };

    Get.toNamed('/portfolio', arguments: {'specialist': providerData});
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _buildProgressStep(1, 'Service', true),
          _buildProgressLine(),
          _buildProgressStep(2, 'Time', false),
          _buildProgressLine(),
          _buildProgressStep(3, 'Details', false),
        ],
      ),
    );
  }

  Widget _buildProgressStep(int step, String title, bool isActive) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryYellow : AppTheme.grey100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              '$step',
              style: TextStyle(
                color: isActive ? AppTheme.black : AppTheme.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            color: isActive ? AppTheme.black : AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine() {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.grey200,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }

  Widget _buildSpecialistInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.grey50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.grey200),
      ),
      child: Row(
        children: [
          // Specialist Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppTheme.grey100,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                _specialist?['image'] as String? ??
                    'https://picsum.photos/seed/specialist/200/150.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.person,
                      size: 30,
                      color: AppTheme.primaryYellow,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Specialist Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _specialist?['name'] as String? ?? 'Specialist',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.black,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: AppTheme.primaryYellow,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      (_specialist!['rating'] as double?)?.toStringAsFixed(1) ??
                          '0.0',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _specialist!['gender'] == 'male'
                            ? Colors.blue.withValues(alpha: 0.1)
                            : Colors.pink.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _specialist!['gender'] == 'male' ? 'Male' : 'Female',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _specialist!['gender'] == 'male'
                              ? Colors.blue
                              : Colors.pink,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedServiceSummary() {
    if (_selectedService == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFFFF6B35)),
              const SizedBox(width: 8),
              const Text(
                'Selected Service',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B35),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedService!['name'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedService!['description'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _selectedService!['duration'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          _selectedService!['category'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryYellow,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _selectedService!['price'] as String,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryYellow,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Icon(
                    Icons.check_circle,
                    color: AppTheme.primaryYellow,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Time Table
          _buildServiceTimeTable(),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Date',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 16),
          // Calendar Grid
          SizedBox(
            height: 280,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 30, // Show next 30 days
              itemBuilder: (context, index) {
                final date = DateTime.now().add(Duration(days: index));
                final isSelected =
                    _selectedDate?.year == date.year &&
                    _selectedDate?.month == date.month &&
                    _selectedDate?.day == date.day;
                final isToday =
                    DateTime.now().year == date.year &&
                    DateTime.now().month == date.month &&
                    DateTime.now().day == date.day;
                final isWeekend =
                    date.weekday == DateTime.saturday ||
                    date.weekday == DateTime.sunday;

                return GestureDetector(
                  onTap: () => _selectDate(date),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryYellow
                          : isToday
                          ? AppTheme.primaryYellow.withValues(alpha: 0.2)
                          : isWeekend
                          ? Colors.grey[300]
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryYellow
                            : isToday
                            ? AppTheme.primaryYellow
                            : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppTheme.primaryYellow.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected || isToday
                                ? Colors.white
                                : isWeekend
                                ? Colors.grey[600]
                                : AppTheme.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getWeekdayAbbreviation(date.weekday),
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected || isToday
                                ? Colors.white
                                : isWeekend
                                ? Colors.grey[500]
                                : AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getMonthAbbreviation(date.month),
                          style: TextStyle(
                            fontSize: 9,
                            color: isSelected || isToday
                                ? Colors.white
                                : isWeekend
                                ? Colors.grey[500]
                                : AppTheme.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Selected Date Display
          if (_selectedDate != null)
            Container(
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
                  Icon(
                    Icons.calendar_today,
                    color: AppTheme.primaryYellow,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Selected: ${_selectedDate!.day} ${_getMonthAbbreviation(_selectedDate!.month)} ${_selectedDate!.year}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryYellow,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _getWeekdayAbbreviation(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _getMonthAbbreviation(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  Widget _buildServiceTimeTable() {
    // Sample time data - in real app this would come from API
    final timeSlots = [
      {'time': '09:00 - 10:00', 'available': true, 'slots': 4},
      {'time': '10:00 - 11:00', 'available': true, 'slots': 3},
      {'time': '11:00 - 12:00', 'available': false, 'slots': 2},
      {'time': '12:00 - 13:00', 'available': true, 'slots': 5},
      {'time': '13:00 - 14:00', 'available': true, 'slots': 4},
      {'time': '14:00 - 15:00', 'available': false, 'slots': 1},
      {'time': '15:00 - 16:00', 'available': true, 'slots': 3},
      {'time': '16:00 - 17:00', 'available': true, 'slots': 2},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Time Slots',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.black,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.grey200),
          ),
          child: Column(
            children: [
              // Table header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryYellow.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Time',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryYellow,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryYellow,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Slots',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryYellow,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Action',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryYellow,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Table rows
              ...timeSlots.asMap().entries.map((entry) {
                final index = entry.key;
                final timeSlot = entry.value;

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: index % 2 == 0
                        ? Colors.grey[50]
                        : Colors.transparent,
                    border: Border(
                      bottom: BorderSide(color: AppTheme.grey200, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Time column
                      Expanded(
                        flex: 3,
                        child: Text(
                          timeSlot['time'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: timeSlot['available'] as bool
                                ? AppTheme.black
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                      // Status column
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: timeSlot['available'] as bool
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                timeSlot['available'] as bool
                                    ? Icons.check_circle_outline
                                    : Icons.lock_outline,
                                size: 12,
                                color: timeSlot['available'] as bool
                                    ? Colors.green[600]
                                    : Colors.grey[500],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                timeSlot['available'] as bool
                                    ? 'Available'
                                    : 'Full',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: timeSlot['available'] as bool
                                      ? Colors.green[600]
                                      : Colors.grey[500],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Slots column
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Text(
                            '${timeSlot['slots']} slots',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: timeSlot['available'] as bool
                                  ? AppTheme.black
                                  : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      // Action column
                      Expanded(
                        flex: 3,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: timeSlot['available'] as bool
                                  ? AppTheme.primaryYellow
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              timeSlot['available'] as bool
                                  ? 'Select Time'
                                  : 'Unavailable',
                              style: TextStyle(
                                fontSize: 11,
                                color: timeSlot['available'] as bool
                                    ? Colors.white
                                    : Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        boxShadow: [
          BoxShadow(
            color: AppTheme.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _selectedService != null
              ? () {
                  Get.toNamed(
                    AppRoutes.bookingTime,
                    arguments: {
                      'specialist': _specialist,
                      'service': _selectedService,
                    },
                  );
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryYellow,
            foregroundColor: AppTheme.black,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            disabledBackgroundColor: AppTheme.grey100,
            disabledForegroundColor: AppTheme.textSecondary,
          ),
          child: Text(
            _selectedService != null
                ? 'Continue to Time Selection'
                : 'Select a Service',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

}
