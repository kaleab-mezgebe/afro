import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/theme/butter_theme.dart';
import '../../../core/utils/preference_helper.dart';
import '../../../routes/app_routes.dart';

class PhoneAuthController extends GetxController {
  // Form fields
  final RxString phoneNumber = ''.obs;
  final RxInt maxPhoneLength = 9.obs;
  final RxBool isLoading = false.obs;
  final RxString validationError = ''.obs; // Only for validation errors

  // Text controllers
  late TextEditingController phoneController;

  // Country picker
  final Rx<Country> selectedCountry = Country(
    phoneCode: '251',
    countryCode: 'ET',
    name: 'Ethiopia',
    e164Sc: 251,
    geographic: true,
    level: 1,
    example: 'Ethiopia',
    displayName: 'Ethiopia (+251)',
    displayNameNoCountryCode: 'Ethiopia',
    e164Key: 'ET-251',
  ).obs;

  // Form validation
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    phoneController = TextEditingController();
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }

  // Validation
  bool get isPhoneNumberValid {
    final phone = phoneNumber.value;
    if (phone.startsWith('0')) {
      return phone.length == 10;
    }
    return phone.length == 9;
  }

  bool get canProceed => !isLoading.value;

  void setPhoneNumber(String value) {
    // Remove all non-digit characters
    String cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');

    // Determine max length based on first digit
    if (cleanPhone.startsWith('0')) {
      maxPhoneLength.value = 10;
    } else {
      maxPhoneLength.value = 9;
      // If user had 10 digits (starting with 0) and changed the first digit to non-zero, truncate
      if (cleanPhone.length > 9) {
        cleanPhone = cleanPhone.substring(0, 9);
      }
    }

    phoneNumber.value = cleanPhone;

    // Update controller text if we truncated
    if (phoneController.text != cleanPhone) {
      phoneController.text = cleanPhone;
      phoneController.selection = TextSelection.fromPosition(
        TextPosition(offset: cleanPhone.length),
      );
    }

    if (validationError.value == 'Please enter a valid phone number') {
      validationError.value = '';
    }
  }

  void onCountryChanged(Country country) {
    selectedCountry.value = country;
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanPhone.length < 9) {
      return 'Phone number is too short';
    }
    return null;
  }

  Future<void> proceed() async {
    if (!isPhoneNumberValid) {
      validationError.value = 'Please enter a valid phone number';
      return;
    }

    isLoading.value = true;
    validationError.value = ''; // Clear validation errors

    // Remove leading zero if it exists (e.g., 0914... -> 914...)
    String cleanInput = phoneNumber.value;
    if (cleanInput.startsWith('0')) {
      cleanInput = cleanInput.substring(1);
    }

    final fullPhoneNumber = '+${selectedCountry.value.phoneCode}$cleanInput';

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: fullPhoneNumber,
        timeout: const Duration(seconds: 60),

        // Auto-retrieved on Android (no user action needed)
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            final userCredential = await FirebaseAuth.instance
                .signInWithCredential(credential);
            if (userCredential.user != null) {
              Get.snackbar(
                'Success!',
                'Phone number verified successfully',
                backgroundColor: ButterTheme.successMint,
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );
              await PreferenceHelper.navigateAfterAuth();
            }
          } catch (e) {
            // Don't show network errors in the field, only in snackbar
            Get.snackbar(
              'Sign-In Issue',
              'Verification successful, but there was an issue completing sign-in. Please try again.',
              backgroundColor: ButterTheme.errorRose,
              colorText: Colors.white,
              duration: const Duration(seconds: 4),
            );
          } finally {
            isLoading.value = false;
          }
        },

        // Called when Firebase rejects the request
        verificationFailed: (FirebaseAuthException e) {
          isLoading.value = false;
          String userFriendlyMsg;

          if (e.code == 'invalid-phone-number') {
            userFriendlyMsg = 'Please enter a valid phone number.';
            validationError.value =
                userFriendlyMsg; // Show in field for validation errors
          } else if (e.code == 'too-many-requests') {
            userFriendlyMsg =
                'Too many attempts. Please wait a few minutes and try again.';
          } else if (e.code == 'quota-exceeded') {
            userFriendlyMsg =
                'Service temporarily busy. Please try again in a few minutes.';
          } else if (e.code == 'network-request-failed') {
            userFriendlyMsg =
                'Please check your internet connection and try again.';
          } else if (e.code == 'app-not-authorized') {
            userFriendlyMsg =
                'App configuration issue. Please contact support.';
          } else {
            // Convert any other technical error to user-friendly message
            userFriendlyMsg = _getUserFriendlyErrorMessage(e.message ?? e.code);
          }

          // Show user-friendly error as snackbar
          Get.snackbar(
            'Unable to Send Code',
            userFriendlyMsg,
            backgroundColor: ButterTheme.errorRose,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
        },

        // SMS sent — navigate to OTP screen
        codeSent: (String verificationId, int? resendToken) {
          isLoading.value = false;
          Get.snackbar(
            'Code Sent!',
            'We sent a verification code to your phone',
            backgroundColor: ButterTheme.successMint,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
          Get.toNamed(
            AppRoutes.otpVerification,
            arguments: {
              'phoneNumber': fullPhoneNumber,
              'verificationId': verificationId,
              'resendToken': resendToken,
              'isSignUpMode': false,
            },
          );
        },

        codeAutoRetrievalTimeout: (String verificationId) {
          // verificationId is still usable on the OTP screen
        },
      );
    } catch (e) {
      isLoading.value = false;
      // Convert technical error to user-friendly message
      final userFriendlyMsg = _getUserFriendlyErrorMessage(e.toString());

      Get.snackbar(
        'Unable to Send Code',
        userFriendlyMsg,
        backgroundColor: ButterTheme.errorRose,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  void clearError() {
    validationError.value = '';
  }

  /// Convert technical error messages to user-friendly messages
  String _getUserFriendlyErrorMessage(String technicalError) {
    final lowerError = technicalError.toLowerCase();

    // Network-related errors
    if (lowerError.contains('network') ||
        lowerError.contains('connection') ||
        lowerError.contains('timeout') ||
        lowerError.contains('unreachable')) {
      return 'Please check your internet connection and try again.';
    }

    // Firebase-specific errors
    if (lowerError.contains('firebase') || lowerError.contains('auth')) {
      return 'Authentication service is temporarily unavailable. Please try again.';
    }

    // SMS/OTP related errors
    if (lowerError.contains('sms') || lowerError.contains('otp')) {
      return 'Unable to send verification code. Please try again.';
    }

    // Server errors
    if (lowerError.contains('server') || lowerError.contains('500')) {
      return 'Our servers are temporarily busy. Please try again in a moment.';
    }

    // Permission/quota errors
    if (lowerError.contains('quota') || lowerError.contains('limit')) {
      return 'Service temporarily unavailable. Please try again later.';
    }

    // Generic fallback for unknown errors
    return 'Something went wrong. Please try again.';
  }

  // Social login methods
  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;
      validationError.value = ''; // Clear validation errors

      // Initialize Google Sign-In with proper configuration
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        Get.snackbar(
          'Google Sign-In Cancelled',
          'You cancelled the login process',
          backgroundColor: ButterTheme.errorRose,
          colorText: Colors.white,
        );
        return;
      }

      // Obtain authentication details from the Google sign-in
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      if (userCredential.user != null) {
        Get.snackbar(
          'Google Login Successful!',
          'Welcome ${userCredential.user?.displayName ?? ''}!',
          backgroundColor: ButterTheme.successMint,
          colorText: Colors.white,
        );

        // Navigate to preference or home screen
        await PreferenceHelper.navigateAfterAuth();
      }
    } on FirebaseAuthException catch (e) {
      String userFriendlyMsg;

      if (e.code == 'account-exists-with-different-credential') {
        userFriendlyMsg =
            'An account with this email already exists. Please use a different sign-in method.';
      } else if (e.code == 'invalid-credential') {
        userFriendlyMsg = 'Sign-in failed. Please try again.';
      } else if (e.code == 'user-disabled') {
        userFriendlyMsg =
            'This account has been disabled. Please contact support.';
      } else if (e.code == 'user-not-found') {
        userFriendlyMsg = 'No account found. Please sign up first.';
      } else if (e.code == 'network-request-failed') {
        userFriendlyMsg =
            'Please check your internet connection and try again.';
      } else {
        userFriendlyMsg = _getUserFriendlyErrorMessage(
          e.message ?? 'Google sign-in failed',
        );
      }

      Get.snackbar(
        'Google Sign-In Failed',
        userFriendlyMsg,
        backgroundColor: ButterTheme.errorRose,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      final userFriendlyMsg = _getUserFriendlyErrorMessage(e.toString());
      Get.snackbar(
        'Google Sign-In Failed',
        userFriendlyMsg,
        backgroundColor: ButterTheme.errorRose,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithFacebook() async {
    try {
      isLoading.value = true;
      validationError.value = ''; // Clear validation errors

      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        // Get the user credentials
        final AccessToken accessToken = result.accessToken!;

        // Create a credential from the access token
        final OAuthCredential credential = FacebookAuthProvider.credential(
          accessToken.token,
        );

        // Sign in to Firebase with the Facebook credential
        final userCredential = await FirebaseAuth.instance.signInWithCredential(
          credential,
        );

        if (userCredential.user != null) {
          Get.snackbar(
            'Facebook Login Successful!',
            'Welcome ${userCredential.user?.displayName ?? ''}!',
            backgroundColor: ButterTheme.successMint,
            colorText: Colors.white,
          );

          // Navigate to preference or home screen
          await PreferenceHelper.navigateAfterAuth();
        }
      } else {
        throw result.message ?? 'Unknown Facebook login error';
      }
    } on FirebaseAuthException catch (e) {
      String userFriendlyMsg;

      if (e.code == 'account-exists-with-different-credential') {
        userFriendlyMsg =
            'An account with this email already exists. Please use a different sign-in method.';
      } else if (e.code == 'invalid-credential') {
        userFriendlyMsg = 'Sign-in failed. Please try again.';
      } else if (e.code == 'user-disabled') {
        userFriendlyMsg =
            'This account has been disabled. Please contact support.';
      } else if (e.code == 'user-not-found') {
        userFriendlyMsg = 'No account found. Please sign up first.';
      } else if (e.code == 'network-request-failed') {
        userFriendlyMsg =
            'Please check your internet connection and try again.';
      } else {
        userFriendlyMsg = _getUserFriendlyErrorMessage(
          e.message ?? 'Facebook sign-in failed',
        );
      }

      Get.snackbar(
        'Facebook Sign-In Failed',
        userFriendlyMsg,
        backgroundColor: ButterTheme.errorRose,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      final userFriendlyMsg = _getUserFriendlyErrorMessage(e.toString());
      Get.snackbar(
        'Facebook Sign-In Failed',
        userFriendlyMsg,
        backgroundColor: ButterTheme.errorRose,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
