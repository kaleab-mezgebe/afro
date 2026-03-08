import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:logger/logger.dart';
import '../../domain/entities/user.dart';

class FirebaseUserService {
  static final FirebaseUserService _instance = FirebaseUserService._internal();
  factory FirebaseUserService() => _instance;
  FirebaseUserService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final Logger _logger = Logger();

  // Collection reference
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  /// Save user profile to Firestore after successful authentication
  Future<User> saveUserProfile({
    required String uid,
    required String name,
    required String email,
    String? phoneNumber,
    String? avatar,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final now = DateTime.now();

      final userData = {
        'id': uid,
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'avatar': avatar,
        'isEmailVerified': _auth.currentUser?.emailVerified ?? false,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        ...?additionalData,
      };

      await _usersCollection.doc(uid).set(userData);

      _logger.i('User profile saved to Firestore: $uid');

      return User.fromJson(userData);
    } catch (e) {
      _logger.e('Error saving user profile: $e');
      throw Exception('Failed to save user profile: $e');
    }
  }

  /// Get user profile from Firestore
  Future<User?> getUserProfile(String uid) async {
    try {
      final docSnapshot = await _usersCollection.doc(uid).get();

      if (docSnapshot.exists) {
        final userData = docSnapshot.data()!;
        return User.fromJson(userData);
      }

      return null;
    } catch (e) {
      _logger.e('Error getting user profile: $e');
      throw Exception('Failed to get user profile: $e');
    }
  }

  /// Update user profile in Firestore
  Future<User> updateUserProfile({
    required String uid,
    String? name,
    String? phoneNumber,
    String? avatar,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final updateData = <String, Object?>{
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (name != null) updateData['name'] = name;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (avatar != null) updateData['avatar'] = avatar;

      if (additionalData != null) {
        updateData.addAll(additionalData);
      }

      await _usersCollection.doc(uid).update(updateData);

      // Get updated user data
      final updatedUser = await getUserProfile(uid);
      if (updatedUser != null) {
        _logger.i('User profile updated: $uid');
        return updatedUser;
      } else {
        throw Exception('User not found after update');
      }
    } catch (e) {
      _logger.e('Error updating user profile: $e');
      throw Exception('Failed to update user profile: $e');
    }
  }

  /// Delete user profile from Firestore
  Future<void> deleteUserProfile(String uid) async {
    try {
      await _usersCollection.doc(uid).delete();
      _logger.i('User profile deleted: $uid');
    } catch (e) {
      _logger.e('Error deleting user profile: $e');
      throw Exception('Failed to delete user profile: $e');
    }
  }

  /// Check if user profile exists
  Future<bool> userProfileExists(String uid) async {
    try {
      final docSnapshot = await _usersCollection.doc(uid).get();
      return docSnapshot.exists;
    } catch (e) {
      _logger.e('Error checking user profile existence: $e');
      return false;
    }
  }

  /// Get current authenticated user profile
  Future<User?> getCurrentUserProfile() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return null;
    }

    return await getUserProfile(currentUser.uid);
  }

  /// Save comprehensive user registration data
  Future<User> saveUserRegistration({
    required String uid,
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
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final now = DateTime.now();

      final userData = {
        'id': uid,
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'avatar': avatar,
        'isEmailVerified': _auth.currentUser?.emailVerified ?? false,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),

        // Extended profile data
        'firstName': firstName,
        'lastName': lastName,
        'location': location,
        'gender': gender,
        'dateOfBirth': dateOfBirth,
        'hairType': hairType,
        'skinType': skinType,
        'preferredServices': preferredServices,

        ...?additionalData,
      };

      await _usersCollection.doc(uid).set(userData);

      _logger.i('User registration data saved to Firestore: $uid');

      return User.fromJson(userData);
    } catch (e) {
      _logger.e('Error saving user registration: $e');
      throw Exception('Failed to save user registration: $e');
    }
  }

  /// Stream user profile changes
  Stream<User?> userProfileStream(String uid) {
    return _usersCollection.doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return User.fromJson(snapshot.data()!);
      }
      return null;
    });
  }

  /// Stream current user profile changes
  Stream<User?> currentUserProfileStream() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value(null);
    }

    return userProfileStream(currentUser.uid);
  }
}
