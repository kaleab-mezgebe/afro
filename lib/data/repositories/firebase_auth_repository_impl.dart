import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/local_storage.dart';
import '../../core/services/firebase_user_service.dart';

class FirebaseAuthRepositoryImpl implements AuthRepository {
  final LocalStorage _localStorage;
  final FirebaseUserService _firebaseUserService;
  final auth.FirebaseAuth _firebaseAuth;

  FirebaseAuthRepositoryImpl({
    required LocalStorage localStorage,
    required FirebaseUserService firebaseUserService,
  }) : _localStorage = localStorage,
       _firebaseUserService = firebaseUserService,
       _firebaseAuth = auth.FirebaseAuth.instance;

  @override
  Future<User> login({required String email, required String password}) async {
    try {
      // Sign in with Firebase Auth
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user!;
      
      // Get or create user profile in Firestore
      User? userProfile = await _firebaseUserService.getUserProfile(firebaseUser.uid);
      
      if (userProfile == null) {
        // Create profile if it doesn't exist
        userProfile = await _firebaseUserService.saveUserProfile(
          uid: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'User',
          email: firebaseUser.email!,
          phoneNumber: firebaseUser.phoneNumber,
          avatar: firebaseUser.photoURL,
        );
      }

      // Save to local storage for offline access
      await _localStorage.save('current_user', jsonEncode(userProfile.toJson()));

      return userProfile;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    try {
      // Create user with Firebase Auth
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user!;
      
      // Save user profile to Firestore
      final userProfile = await _firebaseUserService.saveUserProfile(
        uid: firebaseUser.uid,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        avatar: firebaseUser.photoURL,
      );

      // Save to local storage for offline access
      await _localStorage.save('current_user', jsonEncode(userProfile.toJson()));

      return userProfile;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  @override
  Future<User> registerWithFullProfile({
    required String name,
    required String email,
    String? phoneNumber,
    String? avatar,
    required String firstName,
    required String lastName,
    required String location,
    required String gender,
    required String dateOfBirth,
    required String hairType,
    required String skinType,
    required List<String> preferredServices,
  }) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      // Save complete user registration data to Firestore
      final userProfile = await _firebaseUserService.saveUserRegistration(
        uid: currentUser.uid,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        avatar: avatar,
        firstName: firstName,
        lastName: lastName,
        location: location,
        gender: gender,
        dateOfBirth: dateOfBirth,
        hairType: hairType,
        skinType: skinType,
        preferredServices: preferredServices,
      );

      // Save to local storage for offline access
      await _localStorage.save('current_user', jsonEncode(userProfile.toJson()));

      return userProfile;
    } catch (e) {
      throw Exception('Full registration failed: $e');
    }
  }

  @override
  Future<User> refreshToken(String token) async {
    try {
      // Refresh Firebase Auth token
      await _firebaseAuth.currentUser?.reload();
      
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      // Get updated user profile from Firestore
      final userProfile = await _firebaseUserService.getUserProfile(currentUser.uid);
      if (userProfile == null) {
        throw Exception('User profile not found');
      }

      // Update local storage
      await _localStorage.save('current_user', jsonEncode(userProfile.toJson()));

      return userProfile;
    } catch (e) {
      throw Exception('Token refresh failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      await _localStorage.remove('current_user');
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  @override
  Future<User> getCurrentUser() async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      // Try to get from Firestore first
      User? userProfile = await _firebaseUserService.getUserProfile(currentUser.uid);
      
      // If not found in Firestore, try local storage
      if (userProfile == null) {
        final currentUserJson = await _localStorage.get('current_user');
        if (currentUserJson != null) {
          userProfile = User.fromJson(jsonDecode(currentUserJson));
        }
      }

      if (userProfile == null) {
        throw Exception('User profile not found');
      }

      return userProfile;
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  @override
  Future<User> updateProfile({
    required String name,
    String? phoneNumber,
    String? avatar,
  }) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      // Update profile in Firestore
      final updatedUser = await _firebaseUserService.updateUserProfile(
        uid: currentUser.uid,
        name: name,
        phoneNumber: phoneNumber,
        avatar: avatar,
      );

      // Update local storage
      await _localStorage.save('current_user', jsonEncode(updatedUser.toJson()));

      return updatedUser;
    } catch (e) {
      throw Exception('Profile update failed: $e');
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      // Re-authenticate user first
      final credential = auth.EmailAuthProvider.credential(
        email: currentUser.email!,
        password: currentPassword,
      );

      await currentUser.reauthenticateWithCredential(credential);

      // Update password
      await currentUser.updatePassword(newPassword);
    } catch (e) {
      throw Exception('Password change failed: $e');
    }
  }

  @override
  Stream<User?> get userChanges async* {
    await for (final authUser in _firebaseAuth.authStateChanges()) {
      if (authUser == null) {
        yield null;
      } else {
        try {
          final userProfile = await _firebaseUserService.getUserProfile(authUser.uid);
          yield userProfile;
        } catch (e) {
          // If we can't get the profile, yield null
          yield null;
        }
      }
    }
  }

  /// Get current Firebase user
  auth.User? get currentFirebaseUser => _firebaseAuth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _firebaseAuth.currentUser != null;
}
