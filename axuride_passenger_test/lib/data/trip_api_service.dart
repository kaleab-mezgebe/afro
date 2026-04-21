import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/config/app_config.dart';

class TripRequest {
  final double pickupLat;
  final double pickupLng;
  final double dropoffLat;
  final double dropoffLng;
  final String tripType;

  const TripRequest({
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffLat,
    required this.dropoffLng,
    this.tripType = 'Standard',
  });

  Map<String, dynamic> toJson() => {
    'passengerUserId': jwtConfig.userId,
    'passengerPhoneNumber': jwtConfig.phoneNumber,
    'pickup': {'latitude': pickupLat, 'longitude': pickupLng},
    'dropoff': {'latitude': dropoffLat, 'longitude': dropoffLng},
    'tripType': tripType,
  };
}

class TripApiService {
  /// POST /api/v1/passengertrip/request
  /// Returns the tripId on success, throws on failure.
  Future<String> createTrip(TripRequest request) async {
    final url = Uri.parse('$kApiBase/v1/passengertrip/request');
    final body = jsonEncode(request.toJson());

    debugPrint('[TripApi] POST $url');
    debugPrint('[TripApi] Body: $body');

    final res = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $kToken',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    debugPrint('[TripApi] HTTP ${res.statusCode}: ${res.body}');

    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final id =
          data['tripId']?.toString() ??
          data['id']?.toString() ??
          (data['data'] as Map?)?['tripId']?.toString() ??
          (data['data'] as Map?)?['id']?.toString();
      if (id != null && id.isNotEmpty) return id;
      throw Exception('tripId not found in response: ${res.body}');
    }

    throw Exception('HTTP ${res.statusCode}: ${res.body}');
  }
}
