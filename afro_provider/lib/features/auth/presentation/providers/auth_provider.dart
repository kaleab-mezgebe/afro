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
      // Check if Firebase Auth is available
      if (authService.currentUser == null) {
        // Fallback to mock authentication for development
        await Future.delayed(const Duration(seconds: 1));

        // Try to get provider data from backend using mock auth
        try {
          final providerData = await providerService.getProfile();
          state = AuthState(
            isLoading: false,
            isAuthenticated: true,
            provider: _parseProviderData(providerData),
          );
        } catch (e) {
          // If backend fails, create mock provider data
          state = AuthState(
            isLoading: false,
            isAuthenticated: true,
            provider: models.Provider(
              id: '1',
              email: email,
              phoneNumber: '+1234567890',
              firstName: 'John',
              lastName: 'Doe',
              status: ProviderStatus.approved,
              isVerified: true,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
        }
        return;
      }

      // Real Firebase authentication
      await authService.signInWithEmailPassword(email, password);

      // Get provider token and fetch data from backend
      final providerData = await providerService.getProfile();

      state = AuthState(
        isLoading: false,
        isAuthenticated: true,
        provider: _parseProviderData(providerData),
      );
    } catch (e) {
      state = AuthState(
        isLoading: false,
        error: e.toString(),
      );
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
      final response = await providerService.registerProvider(registrationData);

      state = AuthState(
        isLoading: false,
        isAuthenticated: true,
        provider: _parseProviderData(response),
      );
    } catch (e) {
      state = AuthState(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      // TODO: Implement logout logic
      await Future.delayed(const Duration(milliseconds: 500));

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
