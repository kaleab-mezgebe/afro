import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:logger/logger.dart';

class BackendApiService {
  static final BackendApiService _instance = BackendApiService._internal();
  factory BackendApiService() => _instance;
  BackendApiService._internal();

  final String _baseUrl = 'http://localhost:3001/api/v1';
  final Logger _logger = Logger();

  // Get current Firebase token
  Future<String?> _getCurrentToken() async {
    final currentUser = auth.FirebaseAuth.instance.currentUser;
    if (currentUser == null) return null;
    
    try {
      return await currentUser.getIdToken(true);
    } catch (e) {
      _logger.e('Error getting Firebase token: $e');
      return null;
    }
  }

  // Get headers with Firebase token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getCurrentToken();
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  // Verify Firebase token with backend
  Future<Map<String, dynamic>?> verifyToken(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/verify-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        _logger.e('Token verification failed: ${response.body}');
        return null;
      }
    } catch (e) {
      _logger.e('Error verifying token: $e');
      return null;
    }
  }

  // Get current user from backend
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/me'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        _logger.e('Get current user failed: ${response.body}');
        return null;
      }
    } catch (e) {
      _logger.e('Error getting current user: $e');
      return null;
    }
  }

  // Get all barbers
  Future<List<Map<String, dynamic>>> getBarbers({
    String? search,
    double? lat,
    double? lng,
    double? radius,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/barbers').replace(queryParameters: {
        if (search != null) 'search': search,
        if (lat != null) 'lat': lat.toString(),
        if (lng != null) 'lng': lng.toString(),
        if (radius != null) 'radius': radius.toString(),
      });

      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        _logger.e('Get barbers failed: ${response.body}');
        return [];
      }
    } catch (e) {
      _logger.e('Error getting barbers: $e');
      return [];
    }
  }

  // Get barber by ID
  Future<Map<String, dynamic>?> getBarber(String id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/barbers/$id'));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        _logger.e('Get barber failed: ${response.body}');
        return null;
      }
    } catch (e) {
      _logger.e('Error getting barber: $e');
      return null;
    }
  }

  // Add barber to favorites
  Future<bool> addToFavorites(String barberId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/barbers/$barberId/favorite'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      _logger.e('Error adding to favorites: $e');
      return false;
    }
  }

  // Remove barber from favorites
  Future<bool> removeFromFavorites(String barberId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/barbers/$barberId/unfavorite'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      _logger.e('Error removing from favorites: $e');
      return false;
    }
  }
}
