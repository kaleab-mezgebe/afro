import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/provider_models.dart' show ProviderStatus;
import '../../../../core/models/provider_models.dart' as models;
import '../../../../core/di/injection_container.dart';

// Auth State
class AuthState {
  final bool isLoading;
  final models.Provider? provider;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.isLoading = false,
    this.provider,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    bool? isLoading,
    models.Provider? provider,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      provider: provider ?? this.provider,
      error: error ?? this.error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          provider == other.provider &&
          error == other.error &&
          isAuthenticated == other.isAuthenticated;

  @override
  int get hashCode => Object.hash(
        isLoading,
        provider,
        error,
        isAuthenticated,
      );
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      print('🔧 Using backend authentication only');
      await _directBackendLogin(email, password);
    } catch (e) {
      print('❌ Login error: $e');
      state = AuthState(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> _directBackendLogin(String email, String password) async {
    try {
      // Authenticate directly with backend using email/password
      final loginData = {
        'email': email,
        'password': password,
      };

      final response = await providerService.loginProvider(loginData);

      print('🔍 Backend login response: $response');

      // Extract JWT from response - the token is nested under data.access_token
      final jwt = response['data']?['access_token'] ??
          response['data']?['jwt'] ??
          response['data']?['token'] ??
          response['data']?['accessToken'] ??
          response['access_token'] ??
          response['jwt'] ??
          response['token'] ??
          response['accessToken'];

      if (jwt != null) {
        apiClient.setAuthToken(jwt);
        print(
            '✅ Backend login successful, JWT token set: ${jwt.substring(0, 20)}...');
      } else {
        print(
            '❌ No JWT token found in response. Available keys: ${response.keys.toList()}');
        if (response.containsKey('data')) {
          print('❌ Data keys available: ${response['data'].keys.toList()}');
        }
        throw Exception('No authentication token received from backend');
      }

      // Get provider data from backend
      final providerData = await providerService.getProfile();

      state = AuthState(
        isLoading: false,
        isAuthenticated: true,
        provider: _parseProviderData(providerData),
      );
      print('✅ Backend authentication successful');
    } catch (backendError) {
      print('❌ Backend authentication failed: $backendError');
      throw Exception(
          'Authentication failed. Please check your credentials and try again.');
    }
  }

  // Helper method to parse provider data from API response
  models.Provider _parseProviderData(Map<String, dynamic> data) {
    return models.Provider(
      id: data['id']?.toString() ?? '1',
      email: data['email']?.toString() ?? 'provider@example.com',
      phoneNumber: data['phoneNumber']?.toString() ?? '+1234567890',
      firstName: data['firstName']?.toString() ?? 'John',
      lastName: data['lastName']?.toString() ?? 'Doe',
      status: _parseProviderStatus(data['status']?.toString()),
      isVerified: data['isVerified'] ?? true,
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? DateTime.parse(data['updatedAt'])
          : DateTime.now(),
    );
  }

  ProviderStatus _parseProviderStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return ProviderStatus.approved;
      case 'pending':
        return ProviderStatus.pending;
      case 'rejected':
        return ProviderStatus.rejected;
      case 'suspended':
        return ProviderStatus.suspended;
      default:
        return ProviderStatus.approved;
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String phoneNumber,
    required String firstName,
    required String lastName,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      // Prepare registration data
      final registrationData = {
        'email': email,
        'password': password,
        'phoneNumber': phoneNumber,
        'firstName': firstName,
        'lastName': lastName,
        'businessType': 'barber', // Default to barber, can be made configurable
      };

      // Register with backend
      await providerService.registerProvider(registrationData);

      // After successful registration, login directly with backend
      print('✅ Provider registered, logging in with backend...');
      await _directBackendLogin(email, password);
    } catch (e) {
      String errorMessage = e.toString();

      // Handle specific database constraint errors
      if (errorMessage.contains('duplicate key') ||
          errorMessage.contains('unique constraint')) {
        if (errorMessage.contains('email')) {
          errorMessage =
              'An account with this email already exists. Please use a different email or try signing in.';
        } else if (errorMessage.contains('phoneNumber') ||
            errorMessage.contains('phone')) {
          errorMessage =
              'An account with this phone number already exists. Please use a different phone number.';
        } else {
          errorMessage =
              'An account with this information already exists. Please check your details and try again.';
        }
      }

      state = AuthState(
        isLoading: false,
        error: errorMessage,
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      // Clear auth token from API client
      apiClient.clearAuthToken();

      state = const AuthState(
        isLoading: false,
        isAuthenticated: false,
      );
    } catch (e) {
      state = AuthState(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);

// Convenience providers
final authStateProvider = Provider<bool>(
  (ref) => ref.watch(authProvider).isAuthenticated,
);

final authProviderProvider = Provider<models.Provider?>(
  (ref) => ref.watch(authProvider).provider,
);
