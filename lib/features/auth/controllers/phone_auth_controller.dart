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
  final RxString error = ''.obs;

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

    if (error.value == 'Please enter a valid phone number') {
      error.value = '';
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
      error.value = 'Please enter a valid phone number';
      return;
    }

    isLoading.value = true;
    error.value = '';

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
                'Verified!',
                'Phone number verified automatically',
                backgroundColor: ButterTheme.successMint,
                colorText: Colors.white,
              );
              await PreferenceHelper.navigateAfterAuth();
            }
          } catch (e) {
            error.value = e.toString();
          } finally {
            isLoading.value = false;
          }
        },

        // Called when Firebase rejects the request
        verificationFailed: (FirebaseAuthException e) {
          isLoading.value = false;
          String msg = 'Failed to send OTP';
          if (e.code == 'invalid-phone-number') {
            msg = 'Invalid phone number. Please check and try again.';
          } else if (e.code == 'too-many-requests') {
            msg = 'Too many attempts. Please try again later.';
          } else if (e.code == 'quota-exceeded') {
            msg = 'SMS quota exceeded. Please try again later.';
          } else if (e.message != null) {
            msg = e.message!;
          }
          error.value = msg;
          Get.snackbar(
            'Failed to Send OTP',
            msg,
            backgroundColor: ButterTheme.errorRose,
            colorText: Colors.white,
          );
        },

        // SMS sent — navigate to OTP screen
        codeSent: (String verificationId, int? resendToken) {
          isLoading.value = false;
          Get.snackbar(
            'OTP Sent!',
            'Verification code sent to $fullPhoneNumber',
            backgroundColor: ButterTheme.successMint,
            colorText: Colors.white,
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
      final msg = 'Unable to send OTP: ${e.toString()}';
      error.value = msg;
      Get.snackbar(
        'Failed to Send OTP',
        msg,
        backgroundColor: ButterTheme.errorRose,
        colorText: Colors.white,
      );
    }
  }

  void clearError() {
    error.value = '';
  }

  // Social login methods
  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;
      error.value = '';

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
      String errorMessage = 'Google login failed';
      if (e.code == 'account-exists-with-different-credential') {
        final email = e.email ?? '';
        final methods = email.isNotEmpty
            ? await FirebaseAuth.instance.fetchSignInMethodsForEmail(email)
            : <String>[];
        final methodString = methods.isNotEmpty
            ? methods.join(', ')
            : 'another method';
        errorMessage =
            'An account already exists with this email ($email) via $methodString. Please use that method to sign in.';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'The credential is malformed or has expired';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'This user account has been disabled';
      } else if (e.code == 'user-not-found') {
        errorMessage = 'No user found for this account';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password';
      } else {
        errorMessage = 'Firebase error: ${e.message}';
      }

      error.value = errorMessage;
      Get.snackbar(
        'Google Login Failed',
        errorMessage,
        backgroundColor: ButterTheme.errorRose,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Google Login Failed',
        'An unexpected error occurred: ${e.toString()}',
        backgroundColor: ButterTheme.errorRose,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithFacebook() async {
    try {
      isLoading.value = true;
      error.value = '';

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
      String errorMessage = 'Facebook login failed';
      if (e.code == 'account-exists-with-different-credential') {
        // Facebook user data might not be directly available if sign in fails
        // but often the email is provided in the exception or can be fetched
        final email = e.email ?? '';
        if (email.isNotEmpty) {
          final methods = await FirebaseAuth.instance
              .fetchSignInMethodsForEmail(email);
          final methodString = methods.isNotEmpty
              ? methods.join(', ')
              : 'another method';
          errorMessage =
              'An account already exists with this email ($email) via $methodString. Please use that method to sign in.';
        } else {
          errorMessage =
              'An account already exists with the same email but different sign-in method.';
        }
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'The credential is malformed or has expired';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'This user account has been disabled';
      } else if (e.code == 'user-not-found') {
        errorMessage = 'No user found for this account';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password';
      } else {
        errorMessage = 'Firebase error: ${e.message}';
      }

      error.value = errorMessage;
      Get.snackbar(
        'Facebook Login Failed',
        errorMessage,
        backgroundColor: ButterTheme.errorRose,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Facebook Login Failed',
        'An unexpected error occurred: ${e.toString()}',
        backgroundColor: ButterTheme.errorRose,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
