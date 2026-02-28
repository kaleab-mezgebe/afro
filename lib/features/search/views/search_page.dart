import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/theme/shegabet_theme.dart';
import '../../../domain/entities/provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // Mock data for demonstration
  final List<Provider> _mockProviders = const [
    Provider(id: '1', name: 'Afro Cuts Salon', category: 'salon', rating: 4.8),
    Provider(id: '2', name: 'Barber Joe', category: 'barber', rating: 4.9),
    Provider(id: '3', name: 'Style Studio', category: 'salon', rating: 4.7),
    Provider(id: '4', name: 'Gentle Cuts', category: 'barber', rating: 4.6),
    Provider(id: '5', name: 'Urban Styles', category: 'salon', rating: 4.9),
  ];

  // Mock coordinates for providers (around Nairobi, Kenya)
  final List<LatLng> _providerLocations = const [
    LatLng(-1.2921, 36.8219), // Afro Cuts Salon
    LatLng(-1.2856, 36.8283), // Barber Joe
    LatLng(-1.2981, 36.8352), // Style Studio
    LatLng(-1.2756, 36.8156), // Gentle Cuts
    LatLng(-1.3056, 36.8421), // Urban Styles
  ];

  bool _showMap = false;
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Stylists'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: ShegabetTheme.deepRoyalPurple),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: ShegabetTheme.primaryGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Search Bar
              _buildSearchBar(),

              const SizedBox(height: 16),

              // Category Filter
              _buildCategoryFilter(),

              const SizedBox(height: 16),

              // Filters Row
              _buildFiltersRow(),

              const SizedBox(height: 16),

              // View Toggle
              _buildViewToggle(),

              const SizedBox(height: 16),

              // Results
              Expanded(child: _buildResults()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: TextField(
        onChanged: (query) {},
        decoration: InputDecoration(
          hintText: 'Search stylists or services...',
          prefixIcon: const Icon(Icons.search, color: ShegabetTheme.textLight),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: ShegabetTheme.ethiopianGold),
          ),
          hintStyle: const TextStyle(color: ShegabetTheme.textLight),
        ),
        style: const TextStyle(color: ShegabetTheme.textPrimary),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const Text(
              'Category:',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
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
                  provider.name[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              title: Text(
                provider.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: ShegabetTheme.textPrimary,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.category.toUpperCase(),
                    style: TextStyle(
                      color: ShegabetTheme.ethiopianGold,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        provider.rating.toString(),
                        style: const TextStyle(
                          color: ShegabetTheme.textLight,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: ShegabetTheme.textLight,
                size: 16,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMapView() {
    // Create markers for each provider
    final Set<Marker> markers = _mockProviders.asMap().entries.map((entry) {
      final index = entry.key;
      final provider = entry.value;
      final location = _providerLocations[index];

      return Marker(
        markerId: MarkerId(provider.id),
        position: location,
        infoWindow: InfoWindow(
          title: provider.name,
          snippet: '${provider.category} • Rating: ${provider.rating}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          provider.category == 'salon'
              ? BitmapDescriptor.hueMagenta
              : BitmapDescriptor.hueBlue,
        ),
      );
    }).toSet();

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(-1.2921, 36.8219), // Nairobi center
            zoom: 13,
          ),
          markers: markers,
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: true,
          mapToolbarEnabled: false,
        ),
      ),
    );
  }
}
