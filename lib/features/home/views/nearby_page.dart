import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/barber_api_service.dart';
import '../../../domain/entities/provider.dart';
import '../../../routes/app_routes.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/app_empty_state.dart';

class NearByPage extends StatefulWidget {
  const NearByPage({super.key});

  @override
  State<NearByPage> createState() => _NearByPageState();
}

class _NearByPageState extends State<NearByPage> {
  static const CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(9.03, 38.74), // Addis Ababa coordinates as default
    zoom: 14.0,
  );

  final BarberApiService _barberService = Get.find<BarberApiService>();
  List<Provider> _providers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNearbyProviders();
  }

  Future<void> _loadNearbyProviders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Fetch all barbers - in production, you'd pass location coordinates
      final barbers = await _barberService.getBarbers();

      setState(() {
        _providers = barbers
            .map(
              (barber) => Provider(
                id: barber['id'] ?? '',
                name: barber['name'] ?? 'Unknown',
                category: barber['category'] ?? 'barber',
                rating: (barber['rating'] ?? 0.0).toDouble(),
                location: barber['location'] ?? '',
                services: List<String>.from(barber['services'] ?? []),
                minPrice: (barber['minPrice'] ?? 0.0).toDouble(),
                maxPrice: (barber['maxPrice'] ?? 0.0).toDouble(),
                imageUrl: barber['imageUrl'],
                isFeatured: barber['isFeatured'] ?? false,
                isVerified: barber['isVerified'] ?? false,
                gender: barber['gender'] ?? 'unisex',
                reviewCount: barber['reviewCount'] ?? 0,
              ),
            )
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load nearby providers: $e';
        _isLoading = false;
      });
    }
  }

  Set<Marker> _createMarkers() {
    return _providers.asMap().entries.map((entry) {
      final index = entry.key;
      final provider = entry.value;

      return Marker(
        markerId: MarkerId(provider.id),
        position: LatLng(
          9.03 + (index * 0.01), // Slightly different positions
          38.74 + (index * 0.01),
        ),
        infoWindow: InfoWindow(
          title: provider.name,
          snippet: '${provider.rating} ⭐ • ${provider.category}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          provider.category == 'barber'
              ? BitmapDescriptor.hueBlue
              : BitmapDescriptor.hueMagenta,
        ),
        onTap: () {
          _showProviderDetails(provider);
        },
      );
    }).toSet();
  }

  void _showProviderDetails(Provider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.grey300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (provider.imageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          provider.imageUrl!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: 200,
                                color: AppTheme.grey200,
                                child: const Icon(Icons.store, size: 60),
                              ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            provider.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (provider.isVerified == true)
                          const Icon(
                            Icons.verified,
                            color: AppTheme.primaryYellow,
                            size: 24,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          '${provider.rating}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          ' (${provider.reviewCount} reviews)',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.grey600,
                          ),
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
                            provider.location,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.grey600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Services',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: provider.services
                          .map(
                            (service) => Chip(
                              label: Text(service),
                              backgroundColor: AppTheme.primaryYellow
                                  .withOpacity(0.1),
                              labelStyle: const TextStyle(
                                color: AppTheme.primaryYellow,
                                fontSize: 12,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text(
                          'Price Range: ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '\$${provider.minPrice.toInt()} - \$${provider.maxPrice.toInt()}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppTheme.primaryYellow,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Get.toNamed(
                            AppRoutes.portfolio,
                            arguments: {
                              'specialist': {
                                'id': provider.id,
                                'name': provider.name,
                                'rating': provider.rating,
                                'location': provider.location,
                                'categories': [provider.category],
                                'services': provider.services,
                                'imageUrl': provider.imageUrl,
                              },
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryYellow,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'View Details & Book',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_isLoading)
            const Center(child: AppLoading())
          else if (_error != null)
            Center(
              child: AppEmptyState(
                icon: Icons.error_outline,
                title: 'Error Loading Providers',
                message: _error!,
                actionText: 'Retry',
                onAction: _loadNearbyProviders,
              ),
            )
          else if (_providers.isEmpty)
            const Center(
              child: AppEmptyState(
                icon: Icons.location_off,
                title: 'No Providers Nearby',
                message: 'No providers found in your area',
              ),
            )
          else
            GoogleMap(
              initialCameraPosition: _kInitialPosition,
              markers: _createMarkers(),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
            ),

          // Search bar overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search for services nearby...',
                  border: InputBorder.none,
                  icon: const Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Icon(Icons.search, color: AppTheme.grey500),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.tune, color: AppTheme.grey500),
                    onPressed: () {
                      // Show filter options
                    },
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                onSubmitted: (value) {
                  // Implement search
                },
              ),
            ),
          ),

          // Provider list overlay
          if (!_isLoading && _error == null && _providers.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        '${_providers.length} providers nearby',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _providers.length,
                        itemBuilder: (context, index) {
                          final provider = _providers[index];
                          return GestureDetector(
                            onTap: () => _showProviderDetails(provider),
                            child: Container(
                              width: 140,
                              margin: const EdgeInsets.only(right: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: provider.imageUrl != null
                                        ? Image.network(
                                            provider.imageUrl!,
                                            height: 80,
                                            width: 140,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Container(
                                                      height: 80,
                                                      color: AppTheme.grey200,
                                                      child: const Icon(
                                                        Icons.store,
                                                      ),
                                                    ),
                                          )
                                        : Container(
                                            height: 80,
                                            color: AppTheme.grey200,
                                            child: const Icon(Icons.store),
                                          ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    provider.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        size: 14,
                                        color: Colors.amber,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${provider.rating}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
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
}
