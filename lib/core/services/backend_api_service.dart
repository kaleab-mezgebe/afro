import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../utils/logger.dart';

class BackendApiService {
  static final BackendApiService _instance = BackendApiService._internal();
  factory BackendApiService() => _instance;
  BackendApiService._internal();

  final String _baseUrl = 'http://192.168.0.201:3001/api/v1';

  // Get current Firebase token
  Future<String?> _getCurrentToken() async {
    final currentUser = auth.FirebaseAuth.instance.currentUser;
    if (currentUser == null) return null;
    
    try {
      return await currentUser.getIdToken(true);
    } catch (e) {
      AppLogger.e('Error getting Firebase token: $e');
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

  // Verify Firebase token with backend
  Future<Map<String, dynamic>?> verifyToken(String token) async {
    _logRequest('POST', '$_baseUrl/auth/verify-token', {'token': '***'});
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/verify-token'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'token': token}),
      );

      _logResponse('POST', '$_baseUrl/auth/verify-token', response);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return body.containsKey('data') ? body['data'] : body;
      } else {
        return null;
      }
    } catch (e) {
      _logError('POST', '$_baseUrl/auth/verify-token', e);
      return null;
    }
  }

  // Get current user from backend
  Future<Map<String, dynamic>?> getCurrentUser() async {
    _logRequest('GET', '$_baseUrl/auth/me');
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/me'),
        headers: headers,
      );

      _logResponse('GET', '$_baseUrl/auth/me', response);
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return body.containsKey('data') ? body['data'] : body;
      } else {
        return null;
      }
    } catch (e) {
      _logError('GET', '$_baseUrl/auth/me', e);
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
    final uri = Uri.parse('$_baseUrl/barbers').replace(queryParameters: {
      if (search != null) 'search': search,
      if (lat != null) 'lat': lat.toString(),
      if (lng != null) 'lng': lng.toString(),
      if (radius != null) 'radius': radius.toString(),
    });

    _logRequest('GET', uri.toString());
    try {
      final headers = await _getHeaders();
      final response = await http.get(uri, headers: headers);
      
      _logResponse('GET', uri.toString(), response);
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final dynamic dataField = body.containsKey('data') ? body['data'] : body;
        
        if (dataField is List) {
          return dataField.cast<Map<String, dynamic>>();
        } else if (dataField is Map && dataField.containsKey('barbers')) {
          return (dataField['barbers'] as List).cast<Map<String, dynamic>>();
        }
        return [];
      } else {
        return [];
      }
    } catch (e) {
      _logError('GET', uri.toString(), e);
      return [];
    }
  }

  // Get barber by ID
  Future<Map<String, dynamic>?> getBarber(String id) async {
    _logRequest('GET', '$_baseUrl/barbers/$id');
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse('$_baseUrl/barbers/$id'), headers: headers);
      
      _logResponse('GET', '$_baseUrl/barbers/$id', response);
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return body.containsKey('data') ? body['data'] : body;
      } else {
        return null;
      }
    } catch (e) {
      _logError('GET', '$_baseUrl/barbers/$id', e);
      return null;
    }
  }

  // Add barber to favorites
  Future<bool> addToFavorites(String barberId) async {
    _logRequest('POST', '$_baseUrl/barbers/$barberId/favorite');
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/barbers/$barberId/favorite'),
        headers: headers,
      );

      _logResponse('POST', '$_baseUrl/barbers/$barberId/favorite', response);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      _logError('POST', '$_baseUrl/barbers/$barberId/favorite', e);
      return false;
    }
  }

  // Remove barber from favorites
  Future<bool> removeFromFavorites(String barberId) async {
    _logRequest('POST', '$_baseUrl/barbers/$barberId/unfavorite');
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/barbers/$barberId/unfavorite'),
        headers: headers,
      );

      _logResponse('POST', '$_baseUrl/barbers/$barberId/unfavorite', response);
      return response.statusCode == 200;
    } catch (e) {
      _logError('POST', '$_baseUrl/barbers/$barberId/unfavorite', e);
      return false;
    }
  }

  void _logRequest(String method, String url, [dynamic data]) {
    final timestamp = DateTime.now().toIso8601String();
    AppLogger.d('----------------------------------------');
    AppLogger.d('🚀 BACKEND REQUEST [$timestamp]');
    AppLogger.d('Method:  $method');
    AppLogger.d('URL:     $url');
    if (data != null) AppLogger.d('Payload: $data');
    AppLogger.d('----------------------------------------');
  }

  void _logResponse(String method, String url, http.Response response) {
    final timestamp = DateTime.now().toIso8601String();
    AppLogger.d('----------------------------------------');
    AppLogger.d('✅ BACKEND RESPONSE [$timestamp]');
    AppLogger.d('Status:  ${response.statusCode}');
    AppLogger.d('URL:     $url');
    AppLogger.d('Data:    ${response.body}');
    AppLogger.d('----------------------------------------');
  }

  void _logError(String method, String url, dynamic error) {
    AppLogger.e('❌ BACKEND ERROR: $method $url - $error');
  }
}
