import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/phone_auth_controller.dart';
import '../controllers/sign_up_controller.dart';
import '../views/sign_up_page.dart';
import '../widgets/country_picker_widget.dart';
import '../../../core/theme/app_theme.dart';

class PhoneAuthPage extends GetView<PhoneAuthController> {
  const PhoneAuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Logo
              _buildLogo(),

              const SizedBox(height: 32),

              // Header
              _buildHeader(),

              const SizedBox(height: 24),

              // Form
              Expanded(
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    children: [
                      // Email Field
                      TextFormField(
                        controller: controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: controller.validateEmail,
                        onChanged: controller.setEmail,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          filled: true,
                          fillColor: AppTheme.grey50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppTheme.grey300,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppTheme.grey300,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppTheme.primaryYellow,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Password Field
                      TextFormField(
                        controller: controller.passwordController,
                        obscureText: true,
                        validator: controller.validatePassword,
                        onChanged: controller.setPassword,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          filled: true,
                          fillColor: AppTheme.grey50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppTheme.grey300,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppTheme.grey300,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppTheme.primaryYellow,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Remember Me & Forgot Password
              _buildRememberAndForgot(),

              const SizedBox(height: 24),

              // Login Button
              _buildLoginButton(),

              const SizedBox(height: 24),

              // Separator
              _buildSeparator(),

              const SizedBox(height: 24),

              // Social Login
              _buildSocialLogin(),

              const SizedBox(height: 24),

              // Sign Up Link
              _buildSignUpLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppTheme.primaryYellow,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.content_cut, color: AppTheme.black, size: 40),
    );
  }

  Widget _buildHeader() {
    return const Column(
      children: [
        Text(
          'Login',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Enter your email and password to log in.',
          style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        // Email Field
        TextField(
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Email',
            filled: true,
            fillColor: AppTheme.grey50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.grey300, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.grey300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.primaryYellow,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Password Field
        TextField(
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Password',
            filled: true,
            fillColor: AppTheme.grey50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.grey300, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.grey300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.primaryYellow,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRememberAndForgot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: false,
                onChanged: (value) {},
                activeColor: AppTheme.primaryYellow,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Remember me',
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
          ],
        ),
        TextButton(
          onPressed: () {},
          child: const Text(
            'Forgot Password?',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.primaryYellow,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: controller.canProceed ? controller.proceed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryYellow,
            foregroundColor: AppTheme.black,
            disabledBackgroundColor: AppTheme.grey300,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: controller.isLoading.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.black),
                  ),
                )
              : const Text(
                  'Login',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
        ),
      ),
    );
  }

  Widget _buildSeparator() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppTheme.grey300, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: const Text(
            'Or login with',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
        ),
        const Expanded(child: Divider(color: AppTheme.grey300, thickness: 1)),
      ],
    );
  }

  Widget _buildSocialLogin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSocialButton(Icons.gavel, 'Google'),
        _buildSocialButton(Icons.facebook, 'Facebook'),
        _buildSocialButton(Icons.apple, 'Apple'),
        _buildSocialButton(Icons.person, 'Other'),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, String label) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.grey300, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: () {},
        icon: Icon(icon, color: AppTheme.textSecondary, size: 24),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account? ",
          style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
        ),
        TextButton(
          onPressed: () {
            Get.put(SignUpController());
            Get.to(() => SignUpPage());
          },
          child: const Text(
            'Sign Up',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.primaryYellow,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
