import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/services/barber_api_service.dart';
import '../../../core/services/service_api_service.dart';
import '../../../core/services/review_api_service.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/app_empty_state.dart';
import 'package:customer_app/features/appointments/controllers/appointments_controller.dart';

class PortfolioPage extends StatefulWidget {
  final Map<String, dynamic>? specialist;

  const PortfolioPage({super.key, required this.specialist});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  final BarberApiService _barberService = Get.find<BarberApiService>();
  final ServiceApiService _serviceService = Get.find<ServiceApiService>();
  final ReviewApiService _reviewService = Get.find<ReviewApiService>();

  int _selectedServiceIndex = 0;
  bool _isFavorite = false;
  bool _isLoading = true;
  String? _error;

  List<Map<String, dynamic>> _services = [];
  List<Map<String, dynamic>> _reviews = [];
  List<String> _portfolioImages = [];

  @override
  void initState() {
    super.initState();
    _loadBarberData();
  }

  Future<void> _loadBarberData() async {
    if (widget.specialist == null) {
      setState(() {
        _error = 'No specialist data provided';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Safe barberId — never hard-cast dynamic to String
    final barberId = widget.specialist!['id']?.toString() ?? '';

    if (barberId.isEmpty || barberId == 'default') {
      // No real backend ID — use whatever came from the list
      setState(() {
        _isLoading = false;
        _services = _extractServicesFromSpecialist();
      });
      return;
    }

    try {
      List<Map<String, dynamic>> services = [];
      List<Map<String, dynamic>> reviews = [];
      List<String> portfolioImages = [];

      // 1. Services — barber-specific endpoint, then fallback chain
      try {
        final raw = await _serviceService.getServicesByBarber(barberId);
        services = raw.cast<Map<String, dynamic>>();
      } catch (_) {
        try {
          final all = await _serviceService.getServices();
          services = all
              .cast<Map<String, dynamic>>()
              .where(
                (s) =>
                    s['barberId']?.toString() == barberId ||
                    s['barber_id']?.toString() == barberId,
              )
              .toList();
        } catch (_) {
          services = _extractServicesFromSpecialist();
        }
      }

      // 2. Barber details for portfolio images (non-critical)
      try {
        final details = await _barberService.getBarber(barberId);
        final rawImages = details['portfolioImages'];
        if (rawImages is List) {
          portfolioImages = rawImages
              .map((e) => e?.toString() ?? '')
              .where((e) => e.isNotEmpty)
              .toList();
        }
      } catch (_) {}

      // 3. Reviews (non-critical)
      try {
        final raw = await _reviewService.getBarberReviews(barberId, limit: 10);
        reviews = raw.cast<Map<String, dynamic>>();
      } catch (_) {}

      setState(() {
        _services = services;
        _reviews = reviews;
        _portfolioImages = portfolioImages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load barber data. Please try again.';
        _isLoading = false;
      });
    }
  }

  /// Extract services from the specialist map passed from the home page
  List<Map<String, dynamic>> _extractServicesFromSpecialist() {
    final rawServices = widget.specialist!['services'];
    if (rawServices is List) {
      return rawServices.map((s) {
        if (s is Map<String, dynamic>) return s;
        return <String, dynamic>{
          'name': s?.toString() ?? 'Service',
          'priceCents': 0,
          'durationMinutes': 30,
        };
      }).toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.specialist?['name'] ?? 'Loading...')),
        body: const Center(child: AppLoading()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: AppEmptyState(
            icon: Icons.error_outline,
            title: 'Error Loading Data',
            message: _error!,
            actionText: 'Retry',
            onAction: _loadBarberData,
          ),
        ),
      );
    }

    final controller = Get.find<AppointmentsController>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.specialist?['name'] ?? 'Barber',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3.0,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (widget.specialist?['imageUrl'] != null)
                    Image.network(
                      widget.specialist!['imageUrl'].toString(),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppTheme.grey300,
                        child: const Icon(Icons.person, size: 100),
                      ),
                    )
                  else
                    Container(
                      color: AppTheme.grey300,
                      child: const Icon(Icons.person, size: 100),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: () => setState(() => _isFavorite = !_isFavorite),
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating and Location
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 24),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.specialist?['rating'] ?? 0.0}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${_reviews.length} reviews)',
                        style: TextStyle(fontSize: 14, color: AppTheme.grey600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 20,
                        color: AppTheme.grey600,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.specialist?['location']?.toString() ??
                              widget.specialist?['address']?.toString() ??
                              'Location not specified',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.grey600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Services Section
                  if (_services.isNotEmpty) ...[
                    const Text(
                      'Services',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._services.asMap().entries.map((entry) {
                      final index = entry.key;
                      final service = entry.value;
                      final isSelected = _selectedServiceIndex == index;
                      final name = service['name']?.toString() ?? 'Service';
                      final priceCents =
                          (service['priceCents'] as num?)?.toInt() ??
                          ((service['price'] as num?)?.toDouble() ?? 0.0) * 100;
                      final duration =
                          service['durationMinutes']?.toString() ?? '30';

                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedServiceIndex = index),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryYellow.withValues(alpha: 0.1)
                                : Colors.white,
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primaryYellow
                                  : AppTheme.grey300,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? AppTheme.primaryYellow
                                            : Colors.black,
                                      ),
                                    ),
                                    if (service['description'] != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        service['description'].toString(),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppTheme.grey600,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 16,
                                          color: AppTheme.grey600,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$duration min',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppTheme.grey600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                '\$${(priceCents / 100).toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? AppTheme.primaryYellow
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.grey50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'No services listed yet',
                          style: TextStyle(color: AppTheme.greyMedium),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Portfolio Section
                  if (_portfolioImages.isNotEmpty) ...[
                    const Text(
                      'Portfolio',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.0,
                          ),
                      itemCount: _portfolioImages.length,
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            _portfolioImages[index],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: AppTheme.grey200,
                                  child: const Icon(Icons.image, size: 40),
                                ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Reviews Section
                  if (_reviews.isNotEmpty) ...[
                    const Text(
                      'Reviews',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._reviews.take(3).map((review) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.grey100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  review['customerName']?.toString() ??
                                      'Anonymous',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                Row(
                                  children: List.generate(5, (i) {
                                    return Icon(
                                      i <
                                              ((review['rating'] as num?)
                                                      ?.toInt() ??
                                                  0)
                                          ? Icons.star
                                          : Icons.star_border,
                                      size: 16,
                                      color: Colors.amber,
                                    );
                                  }),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              review['comment']?.toString() ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.grey700,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // Book Now Button — only shown when services are available
      bottomNavigationBar: _services.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: () {
                    if (widget.specialist != null && _services.isNotEmpty) {
                      controller.startBookingFromPortfolio(
                        widget.specialist!,
                        _services[_selectedServiceIndex],
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryYellow,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Book ${_services[_selectedServiceIndex]['name']?.toString() ?? 'Service'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
