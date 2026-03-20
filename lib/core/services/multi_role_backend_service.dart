import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:logger/logger.dart';

enum UserRole { admin, barber, customer }
enum Gender { male, female, other }

class MultiRoleBackendService {
  static final MultiRoleBackendService _instance = MultiRoleBackendService._internal();
  factory MultiRoleBackendService() => _instance;
  MultiRoleBackendService._internal();

  final String _baseUrl = 'http://192.168.0.201:3001/api/v1';
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
      'Accept': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  // Verify Firebase token and get user with roles
  Future<Map<String, dynamic>?> verifyToken(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/verify-token'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'token': token}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return body.containsKey('data') ? body['data'] : body;
      } else {
        _logger.e('Token verification failed: ${response.body}');
        return null;
      }
    } catch (e) {
      _logger.e('Error verifying token: $e');
      return null;
    }
  }

  // Get current user with profile based on role
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/me'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return body.containsKey('data') ? body['data'] : body;
      } else {
        _logger.e('Get current user failed: ${response.body}');
        return null;
      }
    } catch (e) {
      _logger.e('Error getting current user: $e');
      return null;
    }
  }

  // Assign role to user (admin only)
  Future<bool> assignRole(String userId, UserRole role) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/assign-role'),
        headers: headers,
        body: jsonEncode({
          'userId': userId,
          'role': role.name,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      _logger.e('Error assigning role: $e');
      return false;
    }
  }

  // Remove role from user (admin only)
  Future<bool> removeRole(String userId, UserRole role) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/remove-role'),
        headers: headers,
        body: jsonEncode({
          'userId': userId,
          'role': role.name,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      _logger.e('Error removing role: $e');
      return false;
    }
  }

  // ==================== BARBER METHODS ====================

  // Get barbers with gender filtering
  Future<List<Map<String, dynamic>>> getBarbers({
    String? search,
    double? lat,
    double? lng,
    double? radius,
    Gender? genderFocus,
    bool? verified,
  }) async {
    try {
      final queryParams = <String, String>{
        if (search != null) 'search': search,
        if (lat != null) 'lat': lat.toString(),
        if (lng != null) 'lng': lng.toString(),
        if (radius != null) 'radius': radius.toString(),
        if (genderFocus != null) 'genderFocus': genderFocus.name,
        if (verified != null) 'verified': verified.toString(),
      };

      final uri = Uri.parse('$_baseUrl/barbers').replace(queryParameters: queryParams);
      final headers = await _getHeaders();
      final response = await http.get(uri, headers: headers);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final dynamic dataField = body.containsKey('data') ? body['data'] : body;
        
        if (dataField is List) {
          return dataField.cast<Map<String, dynamic>>();
        }
        return [];
      } else {
        _logger.e('Get barbers failed: ${response.body}');
        return [];
      }
    } catch (e) {
      _logger.e('Error getting barbers: $e');
      return [];
    }
  }

  // Update barber profile (barber only)
  Future<bool> updateBarberProfile(Map<String, dynamic> profileData) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$_baseUrl/barbers/profile'),
        headers: headers,
        body: jsonEncode(profileData),
      );

      return response.statusCode == 200;
    } catch (e) {
      _logger.e('Error updating barber profile: $e');
      return false;
    }
  }

  // ==================== CUSTOMER METHODS ====================

  // Update customer profile (customer only)
  Future<bool> updateCustomerProfile({
    String? gender,
    String? dateOfBirth,
    String? hairType,
    String? skinType,
    List<String>? preferredServices,
    Map<String, dynamic>? notificationPreferences,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = <String, dynamic>{
        if (gender != null) 'gender': gender,
        if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
        if (hairType != null) 'hairType': hairType,
        if (skinType != null) 'skinType': skinType,
        if (preferredServices != null) 'preferredServices': preferredServices,
        if (notificationPreferences != null) 'notificationPreferences': notificationPreferences,
      };

      final response = await http.put(
        Uri.parse('$_baseUrl/customers/profile'),
        headers: headers,
        body: jsonEncode(body),
      );

      return response.statusCode == 200;
    } catch (e) {
      _logger.e('Error updating customer profile: $e');
      return false;
    }
  }

  // Get gender-specific services
  Future<List<Map<String, dynamic>>> getServices({Gender? genderTarget}) async {
    try {
      final queryParams = <String, String>{
        if (genderTarget != null) 'genderTarget': genderTarget.name,
      };

      final uri = Uri.parse('$_baseUrl/services').replace(queryParameters: queryParams);
      final headers = await _getHeaders();
      final response = await http.get(uri, headers: headers);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final dynamic dataField = body.containsKey('data') ? body['data'] : body;
        
        if (dataField is List) {
          return dataField.cast<Map<String, dynamic>>();
        }
        return [];
      } else {
        _logger.e('Get services failed: ${response.body}');
        return [];
      }
    } catch (e) {
      _logger.e('Error getting services: $e');
      return [];
    }
  }

  // ==================== APPOINTMENT METHODS ====================

  // Create appointment (customer only)
  Future<Map<String, dynamic>?> createAppointment({
    required String barberId,
    required String serviceId,
    required DateTime appointmentDate,
    String? notes,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = {
        'barberId': barberId,
        'serviceId': serviceId,
        'appointmentDate': appointmentDate.toIso8601String(),
        if (notes != null) 'notes': notes,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/appointments'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> bodyJson = jsonDecode(response.body);
        return bodyJson.containsKey('data') ? bodyJson['data'] : bodyJson;
      } else {
        _logger.e('Create appointment failed: ${response.body}');
        return null;
      }
    } catch (e) {
      _logger.e('Error creating appointment: $e');
      return null;
    }
  }

  // Get customer appointments (customer only)
  Future<List<Map<String, dynamic>>> getMyAppointments() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/appointments/my'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final dynamic dataField = body.containsKey('data') ? body['data'] : body;
        
        if (dataField is List) {
          return dataField.cast<Map<String, dynamic>>();
        }
        return [];
      } else {
        _logger.e('Get appointments failed: ${response.body}');
        return [];
      }
    } catch (e) {
      _logger.e('Error getting appointments: $e');
      return [];
    }
  }

  // Get barber appointments (barber only)
  Future<List<Map<String, dynamic>>> getBarberAppointments() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/appointments/barber'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final dynamic dataField = body.containsKey('data') ? body['data'] : body;
        
        if (dataField is List) {
          return dataField.cast<Map<String, dynamic>>();
        }
        return [];
      } else {
        _logger.e('Get barber appointments failed: ${response.body}');
        return [];
      }
    } catch (e) {
      _logger.e('Error getting barber appointments: $e');
      return [];
    }
  }

  // ==================== ADMIN METHODS ====================

  // Get all users (admin only)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/users'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final dynamic dataField = body.containsKey('data') ? body['data'] : body;
        
        if (dataField is List) {
          return dataField.cast<Map<String, dynamic>>();
        }
        return [];
      } else {
        _logger.e('Get users failed: ${response.body}');
        return [];
      }
    } catch (e) {
      _logger.e('Error getting users: $e');
      return [];
    }
  }

  // Get analytics data (admin only)
  Future<Map<String, dynamic>?> getAnalytics() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/analytics'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return body.containsKey('data') ? body['data'] : body;
      } else {
        _logger.e('Get analytics failed: ${response.body}');
        return null;
      }
    } catch (e) {
      _logger.e('Error getting analytics: $e');
      return null;
    }
  }

  // ==================== FAVORITES & REVIEWS ====================

  // Add to favorites (customer only)
  Future<bool> addToFavorites(String barberId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/favorites/barber/$barberId'),
        headers: headers,
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      _logger.e('Error adding to favorites: $e');
      return false;
    }
  }

  // Remove from favorites (customer only)
  Future<bool> removeFromFavorites(String barberId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$_baseUrl/favorites/barber/$barberId'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      _logger.e('Error removing from favorites: $e');
      return false;
    }
  }

  // Create review (customer only)
  Future<bool> createReview({
    required String barberId,
    required String appointmentId,
    required int rating,
    String? comment,
    int? serviceQuality,
    int? cleanliness,
    int? professionalism,
    int? valueForMoney,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = {
        'barberId': barberId,
        'appointmentId': appointmentId,
        'rating': rating,
        if (comment != null) 'comment': comment,
        if (serviceQuality != null) 'serviceQuality': serviceQuality,
        if (cleanliness != null) 'cleanliness': cleanliness,
        if (professionalism != null) 'professionalism': professionalism,
        if (valueForMoney != null) 'valueForMoney': valueForMoney,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/reviews'),
        headers: headers,
        body: jsonEncode(body),
      );

      return response.statusCode == 201;
    } catch (e) {
      _logger.e('Error creating review: $e');
      return false;
    }
  }

  // Helper method to check user role
  bool hasRole(List<dynamic> userRoles, UserRole requiredRole) {
    return userRoles.any((role) => role['role'] == requiredRole.name);
  }

  // Helper method to get user's primary role
  UserRole? getPrimaryRole(List<dynamic> userRoles) {
    if (userRoles.isEmpty) return null;
    
    // Priority: admin > barber > customer
    if (hasRole(userRoles, UserRole.admin)) return UserRole.admin;
    if (hasRole(userRoles, UserRole.barber)) return UserRole.barber;
    if (hasRole(userRoles, UserRole.customer)) return UserRole.customer;
    
    return null;
  }
}
