import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';

class BookingServicePage extends StatefulWidget {
  const BookingServicePage({super.key});

  @override
  State<BookingServicePage> createState() => _BookingServicePageState();
}

class _BookingServicePageState extends State<BookingServicePage> {
  Map<String, dynamic>? _specialist;
  Map<String, dynamic>? _selectedService;
  int _selectedStep = 1;

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
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    // Get specialist from arguments
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      setState(() {
        _specialist = arguments['specialist'];
        _selectedService = arguments['service'];
      });
    }
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
          // Progress Indicator
          _buildProgressIndicator(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Specialist Info
                  if (_specialist != null) _buildSpecialistInfo(),
                  const SizedBox(height: 32),

                  // Service Selection
                  _buildServiceSelection(),
                  const SizedBox(height: 32),

                  // Selected Service Summary
                  if (_selectedService != null) _buildSelectedServiceSummary(),
                ],
              ),
            ),
          ),
          // Bottom Button
          _buildBottomButton(),
        ],
      ),
    );
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
                _specialist!['image'] as String,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
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
                  _specialist!['name'] as String,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.black,
                  ),
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
                      (_specialist!['rating'] as double).toStringAsFixed(1),
                      style: const TextStyle(
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

  Widget _buildServiceSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Service',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.black,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Choose the service you\'d like to book',
          style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 20),
        // Service List
        ..._availableServices.map((service) => _buildServiceCard(service)),
      ],
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    final isSelected = _selectedService?['id'] == service['id'];
    final isPopular = service['popular'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primaryYellow.withValues(alpha: 0.1)
            : AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppTheme.primaryYellow : AppTheme.grey200,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppTheme.primaryYellow.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _selectService(service),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Service Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryYellow.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.content_cut,
                    color: AppTheme.primaryYellow,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Service Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            service['name'] as String,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.black,
                            ),
                          ),
                          if (isPopular) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFFF6B35,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'POPULAR',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF6B35),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service['description'] as String,
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
                            service['duration'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            service['category'] as String,
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
                // Price and Selection
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      service['price'] as String,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryYellow,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Icon(
                      isSelected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: isSelected
                          ? AppTheme.primaryYellow
                          : AppTheme.grey300,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_selectedService!['duration']} • ${_selectedService!['category']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _selectedService!['price'] as String,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B35),
                ),
              ),
            ],
          ),
        ],
      ),
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

  void _selectService(Map<String, dynamic> service) {
    setState(() {
      _selectedService = service;
    });
  }
}
