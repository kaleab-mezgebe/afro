import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/phone_auth_controller.dart';
import '../../../core/theme/shegabet_theme.dart';
import '../../../core/animations/shegabet_animations.dart';

class PhoneAuthPage extends GetView<PhoneAuthController> {
  const PhoneAuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ShegabetTheme.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: ShegabetTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 1),

                // Header
                _buildHeader(),

                const SizedBox(height: 40),

                // Form
                _buildForm(),

                const SizedBox(height: 32),

                // Sign In/Sign Up Toggle
                _buildModeToggle(),

                const SizedBox(height: 40),

                // Proceed Button
                _buildProceedButton(),

                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return ShegabetAnimations.fadeIn(
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.isSignUpMode.value ? 'Create Account' : 'Welcome Back',
              style: ShegabetTheme.heading3,
            ),
            const SizedBox(height: 8),
            Text(
              controller.isSignUpMode.value
                  ? 'Enter your phone number to create your account'
                  : 'Enter your phone number to sign in to your account',
              style: ShegabetTheme.bodyMedium.copyWith(
                color: ShegabetTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return ShegabetAnimations.slideIn(
      direction: SlideDirection.up,
      child: Column(
        children: [
          // Phone Number Field
          TextField(
            onChanged: controller.setPhoneNumber,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: '+254 XXX XXX XXX',
              prefixIcon: const Icon(
                Icons.phone,
                color: ShegabetTheme.textMuted,
              ),
              filled: true,
              fillColor: ShegabetTheme.neutral50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: ShegabetTheme.neutral300,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: ShegabetTheme.neutral300,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: ShegabetTheme.deepRoyalPurple,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              hintStyle: const TextStyle(
                color: ShegabetTheme.textLight,
                fontSize: 16,
              ),
            ),
            style: ShegabetTheme.bodyMedium.copyWith(
              color: ShegabetTheme.textPrimary,
            ),
          ),

          // Error message
          Obx(
            () => controller.error.value.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      controller.error.value,
                      style: const TextStyle(
                        color: ShegabetTheme.error,
                        fontSize: 14,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return ShegabetAnimations.fadeIn(
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (!controller.isSignUpMode.value) {
                    controller.toggleMode();
                  }
                },
                child: AnimatedContainer(
                  duration: ShegabetAnimations.medium,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: controller.isSignUpMode.value
                        ? ShegabetTheme.deepRoyalPurple
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: controller.isSignUpMode.value
                          ? ShegabetTheme.deepRoyalPurple
                          : ShegabetTheme.neutral300,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    'Sign Up',
                    textAlign: TextAlign.center,
                    style: ShegabetTheme.button.copyWith(
                      color: controller.isSignUpMode.value
                          ? Colors.white
                          : ShegabetTheme.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (controller.isSignUpMode.value) {
                    controller.toggleMode();
                  }
                },
                child: AnimatedContainer(
                  duration: ShegabetAnimations.medium,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: !controller.isSignUpMode.value
                        ? ShegabetTheme.deepRoyalPurple
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: !controller.isSignUpMode.value
                          ? ShegabetTheme.deepRoyalPurple
                          : ShegabetTheme.neutral300,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    'Sign In',
                    textAlign: TextAlign.center,
                    style: ShegabetTheme.button.copyWith(
                      color: !controller.isSignUpMode.value
                          ? Colors.white
                          : ShegabetTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProceedButton() {
    return ShegabetAnimations.scaleIn(
      child: Obx(
        () => AnimatedButton(
          onPressed: controller.canProceed ? controller.proceed : null,
          style: ShegabetTheme.primaryButton,
          child: controller.isLoading.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  controller.isSignUpMode.value ? 'Continue' : 'Sign In',
                  style: ShegabetTheme.button,
                ),
        ),
      ),
    );
  }
}
