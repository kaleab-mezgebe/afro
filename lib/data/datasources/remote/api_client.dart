import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../../../core/utils/logger.dart';

abstract class ApiClient {
  Future<Map<String, dynamic>> get(String endpoint);
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data);
  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data);
  Future<Map<String, dynamic>> delete(String endpoint);
}

class ApiClientImpl implements ApiClient {
  final String baseUrl;
  final http.Client _client;
  final FirebaseAuth _firebaseAuth;

  ApiClientImpl({required this.baseUrl, FirebaseAuth? firebaseAuth})
    : _client = http.Client(),
      _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        final token = await user.getIdToken();
        headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      AppLogger.e('Error getting auth token: $e');
    }
    return headers;
  }

  @override
  Future<Map<String, dynamic>> get(String endpoint) async {
    _logRequest('GET', endpoint);
    try {
      final headers = await _getHeaders();
      final response = await _client.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );
      _logResponse('GET', endpoint, response);
      return _handleResponse(response);
    } catch (e) {
      _logError('GET', endpoint, e);
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    _logRequest('POST', endpoint, data);
    try {
      final headers = await _getHeaders();
      final response = await _client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      );
      _logResponse('POST', endpoint, response);
      return _handleResponse(response);
    } catch (e) {
      _logError('POST', endpoint, e);
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    _logRequest('PUT', endpoint, data);
    try {
      final headers = await _getHeaders();
      final response = await _client.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      );
      _logResponse('PUT', endpoint, response);
      return _handleResponse(response);
    } catch (e) {
      _logError('PUT', endpoint, e);
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> delete(String endpoint) async {
    _logRequest('DELETE', endpoint);
    try {
      final headers = await _getHeaders();
      final response = await _client.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );
      _logResponse('DELETE', endpoint, response);
      return _handleResponse(response);
    } catch (e) {
      _logError('DELETE', endpoint, e);
      throw Exception('Network error: $e');
    }
  }

  void _logRequest(String method, String endpoint, [dynamic data]) {
    final timestamp = DateTime.now().toIso8601String();
    AppLogger.d('----------------------------------------');
    AppLogger.d('🚀 HTTP REQUEST [$timestamp]');
    AppLogger.d('Method:  $method');
    AppLogger.d('URL:     $baseUrl$endpoint');
    if (data != null) AppLogger.d('Payload: $data');
    AppLogger.d('----------------------------------------');
  }

  void _logResponse(String method, String endpoint, http.Response response) {
    final timestamp = DateTime.now().toIso8601String();
    AppLogger.d('----------------------------------------');
    AppLogger.d('✅ HTTP RESPONSE [$timestamp]');
    AppLogger.d('Status:  ${response.statusCode}');
    AppLogger.d('URL:     $baseUrl$endpoint');
    AppLogger.d('Data:    ${response.body}');
    AppLogger.d('----------------------------------------');
  }

  void _logError(String method, String endpoint, dynamic error) {
    AppLogger.e('❌ HTTP ERROR: $method $baseUrl$endpoint - $error');
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    }
  }
}
