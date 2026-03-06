import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/theme/app_theme.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nearby Providers',
          style: TextStyle(
            color: AppTheme.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          const GoogleMap(
            initialCameraPosition: _kInitialPosition,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _buildSearchBox(),
          ),
        ],
      ),
    );
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
