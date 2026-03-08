import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/provider_models.dart' show ProviderStatus;
import '../../../../core/models/provider_models.dart' as models;

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
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 2));

      // Mock successful login
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
    } catch (e) {
      state = AuthState(
        isLoading: false,
        error: e.toString(),
      );
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
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 2));

      // Mock successful registration
      state = AuthState(
        isLoading: false,
        isAuthenticated: true,
        provider: models.Provider(
          id: '1',
          email: email,
          phoneNumber: phoneNumber,
          firstName: firstName,
          lastName: lastName,
          status: ProviderStatus.pending,
          isVerified: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
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
