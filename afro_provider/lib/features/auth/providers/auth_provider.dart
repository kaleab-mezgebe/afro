import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/di/injection_container.dart';

// Auth state
class AuthState {
  final bool isLoading;
  final String? error;
  final User? user;
  final Map<String, dynamic>? userProfile;
  final bool isAuthenticated;

  AuthState({
    this.isLoading = false,
    this.error,
    this.user,
    this.userProfile,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    User? user,
    Map<String, dynamic>? userProfile,
    bool? isAuthenticated,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
      userProfile: userProfile ?? this.userProfile,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

// Auth provider
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _checkAuthStatus();
  }

  // Check initial auth status
  Future<void> _checkAuthStatus() async {
    final user = authService.currentUser;
    if (user != null) {
      state = state.copyWith(
        user: user,
        isAuthenticated: true,
      );
      await loadUserProfile();
    }
  }

  // Load user profile from backend
  Future<void> loadUserProfile() async {
    try {
      final profile = await authService.getCurrentUser();
      state = state.copyWith(userProfile: profile);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Sign in with email and password
  Future<void> signInWithEmailPassword(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final credential = await authService.signInWithEmailPassword(
        email,
        password,
      );

      state = state.copyWith(
        isLoading: false,
        user: credential.user,
        isAuthenticated: true,
      );

      await loadUserProfile();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Sign up with email and password
  Future<void> signUpWithEmailPassword(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final credential = await authService.signUpWithEmailPassword(
        email,
        password,
      );

      state = state.copyWith(
        isLoading: false,
        user: credential.user,
        isAuthenticated: true,
      );

      await loadUserProfile();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await authService.signOut();

      state = AuthState(); // Reset to initial state
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await authService.sendPasswordResetEmail(email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

// Provider instance
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
