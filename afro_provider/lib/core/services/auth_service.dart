import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import '../network/api_client.dart';

class AuthService {
  final ApiClient _apiClient;
  final FirebaseAuth _firebaseAuth;
  final Logger _logger = Logger();

  AuthService(this._apiClient, this._firebaseAuth);

  // Get current Firebase user
  User? get currentUser => _firebaseAuth.currentUser;

  // Get Firebase ID token
  Future<String?> getIdToken() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        return await user.getIdToken();
      }
      return null;
    } catch (e) {
      _logger.e('Error getting ID token', error: e);
      return null;
    }
  }

  // Set auth token in API client
  Future<void> setAuthToken() async {
    final token = await getIdToken();
    if (token != null) {
      _apiClient.setAuthToken(token);
    }
  }

  // Verify token with backend
  Future<Map<String, dynamic>> verifyToken(String token) async {
    try {
      final response = await _apiClient.post(
        '/auth/verify-token',
        data: {'token': token},
      );
      return response.data;
    } catch (e) {
      _logger.e('Error verifying token', error: e);
      rethrow;
    }
  }

  // Get current user info from backend
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      await setAuthToken();
      final response = await _apiClient.get('/auth/me');
      return response.data;
    } catch (e) {
      _logger.e('Error getting current user', error: e);
      rethrow;
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final token = await getIdToken();
      if (token != null) {
        await verifyToken(token);
      }
      await setAuthToken();
      return credential;
    } catch (e) {
      _logger.e('Error signing in', error: e);
      rethrow;
    }
  }

  // Sign up with email and password
  Future<UserCredential> signUpWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final token = await getIdToken();
      if (token != null) {
        await verifyToken(token);
      }
      await setAuthToken();
      return credential;
    } catch (e) {
      _logger.e('Error signing up', error: e);
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      _apiClient.clearAuthToken();
    } catch (e) {
      _logger.e('Error signing out', error: e);
      rethrow;
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      _logger.e('Error sending password reset email', error: e);
      rethrow;
    }
  }
}
