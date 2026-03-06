import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import '../theme/afro_theme.dart';
import '../../routes/app_routes.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find<AuthController>();

  // Safer access methods
  static AuthController? get instance =>
      Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;
  static bool get isInitialized => Get.isRegistered<AuthController>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Observable state
  final Rx<User?> user = Rx<User?>(null);
  final RxBool isLoggedIn = false.obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Check current user status
    user.value = _auth.currentUser;
    isLoggedIn.value = user.value != null;

    // Listen to auth state changes
    ever(user, (User? currentUser) {
      isLoggedIn.value = currentUser != null;
    });
  }

  // Get current user
  User? get currentUser => user.value;

  // Check if user is logged in
  bool get isAuthenticated => isLoggedIn.value;

  // Comprehensive logout method
  Future<void> logout() async {
    try {
      isLoading.value = true;
      error.value = '';

      // Sign out from Firebase
      await _auth.signOut();

      // Sign out from Google (if signed in)
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // Sign out from Facebook (if signed in)
      await FacebookAuth.instance.logOut();

      // Clear any local storage or cached data
      await _clearLocalData();

      // Show success message
      Get.snackbar(
        'Logged Out',
        'You have been successfully logged out',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AfroTheme.successColor,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        duration: const Duration(seconds: 2),
      );

      // Navigate to login screen
      Get.offAllNamed(AppRoutes.phoneAuth);
    } catch (e) {
      error.value = e.toString();

      Get.snackbar(
        'Logout Error',
        'Failed to logout: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AfroTheme.errorColor,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Clear local data
  Future<void> _clearLocalData() async {
    try {
      // Clear any local storage, preferences, or cached data here
      // For example, if you're using shared preferences:
      // final prefs = await SharedPreferences.getInstance();
      // await prefs.clear();

      // Clear any GetX storage if you're using it
      // Get.reset();
    } catch (e) {
      print('Error clearing local data: $e');
    }
  }

  // Force logout (for error cases)
  Future<void> forceLogout() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      await FacebookAuth.instance.logOut();
      await _clearLocalData();
      Get.offAllNamed(AppRoutes.splash);
    } catch (e) {
      print('Force logout error: $e');
      Get.offAllNamed(AppRoutes.splash);
    }
  }

  // Check authentication status
  Future<void> checkAuthStatus() async {
    try {
      user.value = _auth.currentUser;
      isLoggedIn.value = user.value != null;
    } catch (e) {
      print('Error checking auth status: $e');
      user.value = null;
      isLoggedIn.value = false;
    }
  }
}
