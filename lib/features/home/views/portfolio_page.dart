import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';

class PortfolioPage extends StatefulWidget {
  final Map<String, dynamic>? specialist;

  const PortfolioPage({super.key, required this.specialist});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  int _selectedServiceIndex = 0;
  bool _isFavorite = false;

  // Sample services data
  List<Map<String, dynamic>> get _services {
    final category =
        widget.specialist?['categories'] as List? ?? ['Hairdressing'];
    List<Map<String, dynamic>> services = [];

    // Add services based on specialist categories
    if (category.contains('Hairdressing')) {
      services.addAll([
        {
          'name': 'Basic Haircut',
          'description': 'Professional haircut with styling',
          'price': '\$25.00',
          'duration': '30 min',
          'category': 'Hairdressing',
        },
        {
          'name': 'Premium Haircut',
          'description': 'Deluxe haircut with wash and styling',
          'price': '\$45.00',
          'duration': '60 min',
          'category': 'Hairdressing',
        },
      ]);
    }

    if (category.contains('Hair Color')) {
      services.addAll([
        {
          'name': 'Full Color',
          'description': 'Complete hair coloring service',
          'price': '\$75.00',
          'duration': '120 min',
          'category': 'Hair Color',
        },
        {
          'name': 'Highlights',
          'description': 'Partial highlights and styling',
          'price': '\$55.00',
          'duration': '90 min',
          'category': 'Hair Color',
        },
      ]);
    }

    if (category.contains('Beard & Mustache')) {
      services.addAll([
        {
          'name': 'Beard Trim',
          'description': 'Professional beard shaping and trimming',
          'price': '\$15.00',
          'duration': '20 min',
          'category': 'Beard & Mustache',
        },
        {
          'name': 'Hot Towel Shave',
          'description': 'Traditional hot towel shave experience',
          'price': '\$35.00',
          'duration': '45 min',
          'category': 'Beard & Mustache',
        },
      ]);
    }

    if (category.contains('Makeup')) {
      services.addAll([
        {
          'name': 'Daily Makeup',
          'description': 'Natural everyday makeup application',
          'price': '\$40.00',
          'duration': '45 min',
          'category': 'Makeup',
        },
        {
          'name': 'Event Makeup',
          'description': 'Professional makeup for special events',
          'price': '\$85.00',
          'duration': '90 min',
          'category': 'Makeup',
        },
      ]);
    }

    if (category.contains('Nail Care')) {
      services.addAll([
        {
          'name': 'Manicure',
          'description': 'Classic manicure with nail polish',
          'price': '\$30.00',
          'duration': '45 min',
          'category': 'Nail Care',
        },
        {
          'name': 'Pedicure',
          'description': 'Complete pedicure treatment',
          'price': '\$45.00',
          'duration': '60 min',
          'category': 'Nail Care',
        },
      ]);
    }

    if (category.contains('Facial')) {
      services.addAll([
        {
          'name': 'Basic Facial',
          'description': 'Rejuvenating facial treatment',
          'price': '\$60.00',
          'duration': '60 min',
          'category': 'Facial',
        },
        {
          'name': 'Deep Cleansing',
          'description': 'Deep pore cleansing facial',
          'price': '\$85.00',
          'duration': '75 min',
          'category': 'Facial',
        },
      ]);
    }

    if (category.contains('Hair Treatment')) {
      services.addAll([
        {
          'name': 'Hair Mask',
          'description': 'Deep conditioning hair treatment',
          'price': '\$35.00',
          'duration': '30 min',
          'category': 'Hair Treatment',
        },
        {
          'name': 'Keratin Treatment',
          'description': 'Professional keratin smoothing treatment',
          'price': '\$150.00',
          'duration': '180 min',
          'category': 'Hair Treatment',
        },
      ]);
    }

    if (category.contains('Waxing')) {
      services.addAll([
        {
          'name': 'Eyebrow Wax',
          'description': 'Professional eyebrow shaping and waxing',
          'price': '\$20.00',
          'duration': '15 min',
          'category': 'Waxing',
        },
        {
          'name': 'Full Body Wax',
          'description': 'Complete body waxing service',
          'price': '\$120.00',
          'duration': '120 min',
          'category': 'Waxing',
        },
      ]);
    }

    return services.isNotEmpty
        ? services
        : [
            {
              'name': 'Consultation',
              'description': 'Personal consultation for custom services',
              'price': '\$25.00',
              'duration': '30 min',
              'category': 'General',
            },
          ];
  }

  // Sample portfolio images
  List<String> get _portfolioImages => [
    'https://picsum.photos/seed/${widget.specialist?['name'] ?? 'specialist'}/400/300.jpg',
    'https://picsum.photos/seed/${widget.specialist?['name'] ?? 'specialist'}2/400/300.jpg',
    'https://picsum.photos/seed/${widget.specialist?['name'] ?? 'specialist'}3/400/300.jpg',
    'https://picsum.photos/seed/${widget.specialist?['name'] ?? 'specialist'}4/400/300.jpg',
    'https://picsum.photos/seed/${widget.specialist?['name'] ?? 'specialist'}5/400/300.jpg',
    'https://picsum.photos/seed/${widget.specialist?['name'] ?? 'specialist'}6/400/300.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppointmentsController>(
      init: Get.find<AppointmentsController>(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppTheme.white,
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // Custom Header with Image
                  SliverAppBar(
                    expandedHeight: 300,
                    pinned: true,
                    backgroundColor: Colors.transparent,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            widget.specialist?['image'] as String? ??
                                'https://picsum.photos/seed/${widget.specialist?['name'] ?? 'specialist'}/400/300.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppTheme.grey100,
                                child: const Center(
                                  child: Icon(
                                    Icons.person,
                                    size: 80,
                                    color: AppTheme.primaryYellow,
                                  ),
                                ),
                              );
                            },
                          ),
                          // Gradient overlay for better text visibility
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.3),
                                  Colors.black.withValues(alpha: 0.7),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    leading: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    actions: [
                      Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            _isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _isFavorite = !_isFavorite;
                            });
                            _showFavoriteToast();
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.share, color: Colors.white),
                          onPressed: () {
                            _shareProfile();
                          },
                        ),
                      ),
                    ],
                  ),
                  // Content
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildSpecialistInfo(),
                        const SizedBox(height: 32),
                        _buildServicesSection(controller),
                        const SizedBox(height: 32),
                        _buildPortfolioGallery(),
                        const SizedBox(height: 32),
                        _buildReviewsSection(),
                        const SizedBox(height: 32),
                        _buildContactSection(),
                        const SizedBox(height: 120), // Bottom padding for sticky button
                      ]),
                    ),
                  ),
                ],
              ),
              _buildStickyBookButton(controller),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStickyBookButton(AppointmentsController controller) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                if (widget.specialist != null) {
                  controller.startBookingFromPortfolio(widget.specialist!);
                }
              },
              style: AppTheme.primaryButton,
              child: const Text('Book Appointment Now'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialistInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.specialist?['name'] as String? ?? 'Default Specialist',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.black,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: widget.specialist?['gender'] == 'male'
                    ? Colors.blue.withValues(alpha: 0.1)
                    : Colors.pink.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.specialist?['gender']?.toString() == 'male'
                      ? Colors.blue
                      : Colors.pink,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.specialist?['gender'] == 'male'
                        ? Icons.male
                        : Icons.female,
                    size: 16,
                    color: widget.specialist?['gender']?.toString() == 'male'
                        ? Colors.blue
                        : Colors.pink,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.specialist?['gender']?.toString() == 'male'
                        ? 'Male'
                        : 'Female',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: widget.specialist?['gender']?.toString() == 'male'
                          ? Colors.blue
                          : Colors.pink,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            // Rating
            Row(
              children: [
                const Icon(Icons.star, color: AppTheme.primaryYellow, size: 20),
                const SizedBox(width: 4),
                Text(
                  (widget.specialist?['rating'] as double? ?? 4.5)
                      .toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.black,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(127 reviews)',
                  style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                ),
              ],
            ),
            const SizedBox(width: 24),
            // Categories
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: (widget.specialist?['categories'] as List? ?? [])
                    .map<Widget>(
                      (category) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryYellow.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          category as String,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.primaryYellow,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Professional ${(widget.specialist?['categories'] as List? ?? ['Hairdressing']).join(' & ')} specialist with over 8 years of experience. Passionate about creating the perfect look for every client using the latest techniques and premium products.',
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildServicesSection(AppointmentsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Services & Pricing',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.black,
          ),
        ),
        const SizedBox(height: 20),
        // Service Categories Tabs
        SliverToBoxAdapter(
          child: SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _services.length > 5 ? 5 : _services.length,
              itemBuilder: (context, index) {
                final service = _services[index];
                final isSelected = _selectedServiceIndex == index;
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedServiceIndex = index;
                      });
                    },
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
                    child: Text(service['name'] as String),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Selected Service Detail Highlight
        GestureDetector(
          onTap: () {
            if (widget.specialist != null) {
              controller.startBookingFromPortfolio(widget.specialist!, _services[_selectedServiceIndex]);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.grey50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primaryYellow, width: 1.5),
              boxShadow: [AppTheme.softShadow],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _services[_selectedServiceIndex]['name'] as String,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.black,
                        ),
                      ),
                    ),
                    Text(
                      _services[_selectedServiceIndex]['price'] as String,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryYellow,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _services[_selectedServiceIndex]['description'] as String,
                  style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          _services[_selectedServiceIndex]['duration'] as String,
                          style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                    Text(
                      'Tap to Book',
                      style: TextStyle(
                        color: AppTheme.primaryYellow,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        // All Services Section Header
        const Text(
          'All Services',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // All Services List
        ..._services.map(
          (service) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                if (widget.specialist != null) {
                  controller.startBookingFromPortfolio(widget.specialist!, service);
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.grey200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service['name'] as String,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            service['description'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          service['price'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryYellow,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          service['duration'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPortfolioGallery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Portfolio',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.black,
          ),
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.0,
          ),
          itemCount: _portfolioImages.length,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _portfolioImages[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppTheme.grey100,
                      child: const Center(
                        child: Icon(
                          Icons.image,
                          size: 40,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Reviews',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.black,
              ),
            ),
            TextButton(
              onPressed: () {
                // Show all reviews
              },
              child: const Text(
                'See All',
                style: TextStyle(
                  color: AppTheme.primaryYellow,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Sample Reviews
        ...[
          {
            'name': 'Sarah Johnson',
            'rating': 5.0,
            'date': '2 days ago',
            'comment':
                'Amazing service! Very professional and attentive to detail. Will definitely come back.',
          },
          {
            'name': 'Mike Chen',
            'rating': 4.5,
            'date': '1 week ago',
            'comment':
                'Great experience. The haircut was exactly what I wanted. Highly recommend!',
          },
          {
            'name': 'Emma Davis',
            'rating': 5.0,
            'date': '2 weeks ago',
            'comment':
                'Perfect color and styling. The specialist really knows what they\'re doing!',
          },
        ].map(
          (review) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.grey50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      review['name'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.black,
                      ),
                    ),
                    Text(
                      review['date'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < (review['rating'] as double)
                              ? Icons.star
                              : Icons.star_border,
                          size: 16,
                          color: AppTheme.primaryYellow,
                        );
                      }),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      (review['rating'] as double).toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  review['comment'] as String,
                  style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact & Location',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.black,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.grey50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Location
              Row(
                children: [
                  const Icon(Icons.location_on, color: AppTheme.primaryYellow),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '123 Beauty Street, Downtown District,\nNew York, NY 10001',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Phone
              Row(
                children: [
                  const Icon(Icons.phone, color: AppTheme.primaryYellow),
                  const SizedBox(width: 12),
                  Text(
                    '(555) 123-4567',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Email
              Row(
                children: [
                  const Icon(Icons.email, color: AppTheme.primaryYellow),
                  const SizedBox(width: 12),
                  Text(
                    'contact@salon.com',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Hours
              Row(
                children: [
                  const Icon(Icons.access_time, color: AppTheme.primaryYellow),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Mon-Fri: 9:00 AM - 8:00 PM\nSat-Sun: 10:00 AM - 6:00 PM',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookButton() {
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
          onPressed: () {
            Get.toNamed(
              AppRoutes.bookingService,
              arguments: {
                'specialist': widget.specialist,
                'service': _services[_selectedServiceIndex],
              },
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryYellow,
            foregroundColor: AppTheme.black,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: const Text(
            'Book Appointment',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  void _showFavoriteToast() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorite
              ? '${widget.specialist?['name'] ?? 'Specialist'} added to favorites'
              : '${widget.specialist?['name'] ?? 'Specialist'} removed from favorites',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: _isFavorite ? Colors.green : Colors.grey,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _shareProfile() {
    // Create share content
    final String shareContent =
        '''
Check out ${widget.specialist?['name'] ?? 'Specialist'} - Professional ${(widget.specialist?['categories'] as List? ?? ['Hairdressing']).join(' & ')} Specialist
⭐ Rating: ${(widget.specialist?['rating'] as double? ?? 4.5)}/5.0
📍 Available for appointments

Download the app and book your appointment today!
    ''';

    // Show share dialog (in real app, you'd use share package)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Share this specialist profile:'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.grey50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(shareContent, style: const TextStyle(fontSize: 12)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile link copied to clipboard!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Copy Link'),
          ),
        ],
      ),
    );
  }
}
