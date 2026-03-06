import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/provider.dart';
import '../../../routes/app_routes.dart';

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

  // Sample provider data for demo
  final List<Provider> _providers = [
    Provider(
      id: '1',
      name: 'Premium Barber Shop',
      category: 'barber',
      rating: 4.8,
      location: 'Bole, Addis Ababa',
      services: ['Haircut', 'Beard Trim', 'Hot Towel Shave'],
      minPrice: 150,
      maxPrice: 500,
      imageUrl: 'https://picsum.photos/seed/barber1/200/200',
      isFeatured: true,
      isVerified: true,
      gender: 'male',
      reviewCount: 127,
    ),
    Provider(
      id: '2',
      name: 'Elegant Beauty Salon',
      category: 'salon',
      rating: 4.5,
      location: 'Mekanisa, Addis Ababa',
      services: ['Hair Coloring', 'Styling', 'Facial'],
      minPrice: 200,
      maxPrice: 800,
      imageUrl: 'https://picsum.photos/seed/salon1/200/200',
      isFeatured: false,
      isVerified: true,
      gender: 'female',
      reviewCount: 89,
    ),
    Provider(
      id: '3',
      name: 'Modern Cuts',
      category: 'barber',
      rating: 4.9,
      location: 'Kazanchis, Addis Ababa',
      services: ['Haircut', 'Hair & Beard', 'Styling'],
      minPrice: 100,
      maxPrice: 300,
      imageUrl: 'https://picsum.photos/seed/barber2/200/200',
      isFeatured: true,
      isVerified: false,
      gender: 'unisex',
      reviewCount: 203,
    ),
    Provider(
      id: '4',
      name: 'Luxury Spa & Salon',
      category: 'salon',
      rating: 4.7,
      location: 'Bole, Addis Ababa',
      services: ['Manicure', 'Pedicure', 'Hair Treatment'],
      minPrice: 250,
      maxPrice: 1000,
      imageUrl: 'https://picsum.photos/seed/salon2/200/200',
      isFeatured: true,
      isVerified: true,
      gender: 'female',
      reviewCount: 156,
    ),
  ];

  Set<Marker> _createMarkers() {
    return _providers.map((provider) {
      return Marker(
        markerId: MarkerId(provider.id),
        position: LatLng(
          9.03 +
              (double.parse(provider.id) *
                  0.01), // Slightly different positions
          38.74 + (double.parse(provider.id) * 0.01),
        ),
        infoWindow: InfoWindow(
          title: provider.name,
          snippet: '${provider.rating} ⭐ • ${provider.category}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          provider.category == 'barber'
              ? BitmapDescriptor.hueOrange
              : BitmapDescriptor.hueBlue,
        ),
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Nearby Providers',
          style: TextStyle(
            color: AppTheme.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _kInitialPosition,
            markers: _createMarkers(),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
          ),
          Positioned(top: 100, left: 16, right: 16, child: _buildSearchBox()),
          Positioned(
            bottom: 140,
            left: 16,
            right: 16,
            child: _buildProviderCards(),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCards() {
    return Container(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _providers.length,
        itemBuilder: (context, index) {
          final provider = _providers[index];
          return GestureDetector(
            onTap: () => Get.toNamed(
              AppRoutes.portfolio,
              arguments: {'specialist': _mapProviderToMap(provider)},
            ),
            child: Container(
              width: 280,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(
                          provider.imageUrl ??
                              'https://picsum.photos/seed/${provider.id}/200/200',
                        ),
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(
                        color: provider.isFeatured == true
                            ? AppTheme.primaryYellow
                            : Colors.transparent,
                        width: provider.isFeatured == true ? 3 : 0,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  provider.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.black,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (provider.isVerified == true)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.success,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.verified_rounded,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: provider.category == 'barber'
                                      ? AppTheme.primaryYellow.withOpacity(0.1)
                                      : AppTheme.info.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  provider.category.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: provider.category == 'barber'
                                        ? AppTheme.primaryYellow
                                        : AppTheme.info,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: AppTheme.primaryYellow,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    provider.rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.black,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            provider.location,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                provider.minPrice > 0
                                    ? 'From \$${provider.minPrice.toInt()}'
                                    : 'Variable pricing',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.black,
                                ),
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.chat_bubble_outline_rounded,
                                    color: AppTheme.textMuted,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '(${provider.reviewCount ?? 0})',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                ],
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
        },
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

  Widget _buildSearchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Search for services nearby...',
          border: InputBorder.none,
          icon: Icon(Icons.search, color: AppTheme.grey500),
        ),
      ),
    );
  }
}
