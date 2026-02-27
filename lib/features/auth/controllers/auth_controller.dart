import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../domain/usecases/auth/login.dart';
import '../../../domain/usecases/auth/register.dart';
import '../../../core/theme/afro_theme.dart';
import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  final Login login;
  final Register register;

  AuthController({required this.login, required this.register});

  // Form fields
  final RxString email = ''.obs;
  final RxString password = ''.obs;
  final RxString name = ''.obs;
  final RxString phoneNumber = ''.obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxBool isLoginMode = true.obs;

  // Validation
  bool get isEmailValid => GetUtils.isEmail(email.value);
  bool get isPasswordValid => password.value.length >= 6;
  bool get isNameValid => name.value.length >= 2;
  bool get canLogin => isEmailValid && isPasswordValid && !isLoading.value;
  bool get canRegister =>
      isEmailValid && isPasswordValid && isNameValid && !isLoading.value;

  void toggleMode() {
    isLoginMode.value = !isLoginMode.value;
    clearForm();
  }

  void clearForm() {
    email.value = '';
    password.value = '';
    name.value = '';
    phoneNumber.value = '';
    error.value = '';
  }

  void setEmail(String value) => email.value = value;
  void setPassword(String value) => password.value = value;
  void setName(String value) => name.value = value;
  void setPhoneNumber(String value) => phoneNumber.value = value;

  Future<void> submit() async {
    if (isLoginMode.value) {
      await _login();
    } else {
      await _register();
    }
  }

  Future<void> _login() async {
    try {
      isLoading.value = true;
      error.value = '';

      final user = await login(
        email: email.value.trim(),
        password: password.value,
      );

      // Handle successful login
      Get.snackbar(
        'Welcome back!',
        'Successfully logged in as ${user.name}',
        backgroundColor: AfroTheme.successColor,
        colorText: Colors.white,
      );

      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Login Failed',
        error.value,
        backgroundColor: AfroTheme.errorColor,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _register() async {
    try {
      isLoading.value = true;
      error.value = '';

      final user = await register(
        name: name.value.trim(),
        email: email.value.trim(),
        password: password.value,
        phoneNumber: phoneNumber.value.trim().isEmpty
            ? null
            : phoneNumber.value.trim(),
      );

      // Handle successful registration
      Get.snackbar(
        'Registration Successful!',
        'Welcome to AFRO, ${user.name}!',
        backgroundColor: AfroTheme.successColor,
        colorText: Colors.white,
      );

      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Registration Failed',
        error.value,
        backgroundColor: AfroTheme.errorColor,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void clearError() {
    error.value = '';
  }
}
