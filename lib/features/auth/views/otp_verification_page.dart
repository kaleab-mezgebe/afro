import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../controllers/otp_verification_controller.dart';
import '../../../core/theme/shegabet_theme.dart';
import '../../../core/animations/shegabet_animations.dart';

class OtpVerificationPage extends GetView<OTPVerificationController> {
  const OtpVerificationPage({super.key});

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

                // OTP Input
                _buildOTPInput(),

                const SizedBox(height: 32),

                // Resend OTP
                _buildResendOTP(),

                const SizedBox(height: 40),

                // Verify Button
                _buildVerifyButton(),

                const Spacer(flex: 2),

                // Sign In/Sign Up Toggle
                _buildAuthModeToggle(),

                const SizedBox(height: 40),
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
            const Text('Verify OTP', style: ShegabetTheme.heading3),
            const SizedBox(height: 8),
            Text(
              'Enter the 6-digit code sent to ${controller.phoneNumber.value}',
              style: ShegabetTheme.bodyMedium.copyWith(
                color: ShegabetTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOTPInput() {
    return ShegabetAnimations.slideIn(
      direction: SlideDirection.up,
      child: PinCodeTextField(
        appContext: Get.context!,
        length: 6,
        obscureText: false,
        animationType: AnimationType.fade,
        pinTheme: PinTheme(
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(16),
          fieldHeight: 56,
          fieldWidth: 48,
          activeFillColor: Colors.white,
          activeColor: ShegabetTheme.deepRoyalPurple,
          inactiveFillColor: ShegabetTheme.neutral50,
          inactiveColor: ShegabetTheme.neutral300,
          selectedColor: ShegabetTheme.deepRoyalPurple,
          selectedFillColor: Colors.white,
        ),
        animationDuration: ShegabetAnimations.medium,
        backgroundColor: Colors.transparent,
        enableActiveFill: true,
        controller: controller.otpController,
        keyboardType: TextInputType.number,
        boxShadows: [ShegabetTheme.softShadow],
        onCompleted: (value) {
          controller.verifyOTP();
        },
        onChanged: (value) {
          controller.setOTP(value);
          controller.clearError();

          // Auto-navigate if OTP is "123456" and length is 6
          if (value.length == 6 && value == '123456') {
            controller.verifyOTP();
          }
        },
      ),
    );
  }

  Widget _buildResendOTP() {
    return ShegabetAnimations.fadeIn(
      child: Obx(
        () => Center(
          child: controller.canResend.value
              ? TextButton(
                  onPressed: controller.resendOTP,
                  child: Text(
                    'Resend OTP',
                    style: ShegabetTheme.bodyMedium.copyWith(
                      color: ShegabetTheme.deepRoyalPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : Text(
                  'Resend OTP in ${controller.countdown.value}s',
                  style: ShegabetTheme.bodyMedium.copyWith(
                    color: ShegabetTheme.textMuted,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildVerifyButton() {
    return ShegabetAnimations.scaleIn(
      child: Obx(
        () => AnimatedButton(
          onPressed: controller.otpController.text.length == 6
              ? controller.verifyOTP
              : null,
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
              : const Text('Verify OTP', style: ShegabetTheme.button),
        ),
      ),
    );
  }

  Widget _buildAuthModeToggle() {
    return ShegabetAnimations.fadeIn(
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              controller.isSignUpMode.value
                  ? 'Already have an account?'
                  : 'New to ShegaBet?',
              style: ShegabetTheme.bodyMedium.copyWith(
                color: ShegabetTheme.textSecondary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              controller.isSignUpMode.value ? 'Sign In' : 'Sign Up',
              style: ShegabetTheme.bodyMedium.copyWith(
                color: ShegabetTheme.deepRoyalPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
