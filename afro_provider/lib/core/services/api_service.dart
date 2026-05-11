import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  late Dio _dio;
  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Token expired, clear it
          _clearToken();
        }
        return handler.next(error);
      },
    ));
  }

  Dio get dio => _dio;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> clearToken() async {
    await _clearToken();
  }

  // Auth endpoints
  Future<Response> login(String email, String password) async {
    return await _dio.post(
      '${ApiConfig.auth}/login',
      data: {'email': email, 'password': password},
    );
  }

  Future<Response> register(Map<String, dynamic> data) async {
    return await _dio.post(
      '${ApiConfig.auth}/register',
      data: data,
    );
  }

  Future<Response> logout() async {
    await clearToken();
    return await _dio.post('${ApiConfig.auth}/logout');
  }

  // Provider endpoints
  Future<Response> getProviderProfile() async {
    return await _dio.get('${ApiConfig.providers}/profile');
  }

  Future<Response> updateProviderProfile(Map<String, dynamic> data) async {
    return await _dio.put('${ApiConfig.providers}/profile', data: data);
  }

  // Shops endpoints
  Future<Response> getShops() async {
    return await _dio.get(ApiConfig.shops);
  }

  Future<Response> getShop(String shopId) async {
    return await _dio.get('$ApiConfig.shops/$shopId');
  }

  Future<Response> createShop(Map<String, dynamic> data) async {
    return await _dio.post(ApiConfig.shops, data: data);
  }

  Future<Response> updateShop(String shopId, Map<String, dynamic> data) async {
    return await _dio.put('$ApiConfig.shops/$shopId', data: data);
  }

  Future<Response> deleteShop(String shopId) async {
    return await _dio.delete('$ApiConfig.shops/$shopId');
  }

  // Staff endpoints
  Future<Response> getStaff() async {
    return await _dio.get(ApiConfig.staff);
  }

  Future<Response> getStaffMember(String staffId) async {
    return await _dio.get('$ApiConfig.staff/$staffId');
  }

  Future<Response> createStaff(Map<String, dynamic> data) async {
    return await _dio.post(ApiConfig.staff, data: data);
  }

  Future<Response> updateStaff(
      String staffId, Map<String, dynamic> data) async {
    return await _dio.put('$ApiConfig.staff/$staffId', data: data);
  }

  Future<Response> deleteStaff(String staffId) async {
    return await _dio.delete('$ApiConfig.staff/$staffId');
  }

  // Services endpoints
  Future<Response> getServices() async {
    return await _dio.get(ApiConfig.services);
  }

  Future<Response> getService(String serviceId) async {
    return await _dio.get('$ApiConfig.services/$serviceId');
  }

  Future<Response> createService(Map<String, dynamic> data) async {
    return await _dio.post(ApiConfig.services, data: data);
  }

  Future<Response> updateService(
      String serviceId, Map<String, dynamic> data) async {
    return await _dio.put('$ApiConfig.services/$serviceId', data: data);
  }

  Future<Response> deleteService(String serviceId) async {
    return await _dio.delete('$ApiConfig.services/$serviceId');
  }

  // Appointments endpoints
  Future<Response> getAppointments({Map<String, dynamic>? params}) async {
    return await _dio.get(
      ApiConfig.appointments,
      queryParameters: params,
    );
  }

  Future<Response> getAppointment(String appointmentId) async {
    return await _dio.get('$ApiConfig.appointments/$appointmentId');
  }

  Future<Response> updateAppointmentStatus(
      String appointmentId, String status) async {
    return await _dio.put(
      '$ApiConfig.appointments/$appointmentId/status',
      data: {'status': status},
    );
  }

  // Analytics endpoints
  Future<Response> getAnalytics({Map<String, dynamic>? params}) async {
    return await _dio.get(
      ApiConfig.analytics,
      queryParameters: params,
    );
  }

  // Customers endpoints
  Future<Response> getCustomers({Map<String, dynamic>? params}) async {
    return await _dio.get(
      ApiConfig.customers,
      queryParameters: params,
    );
  }

  // Earnings endpoints
  Future<Response> getEarnings({Map<String, dynamic>? params}) async {
    return await _dio.get(
      ApiConfig.earnings,
      queryParameters: params,
    );
  }
}
