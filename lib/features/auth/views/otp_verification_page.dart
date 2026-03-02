import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../controllers/otp_verification_controller.dart';
import '../../../core/theme/app_theme.dart';

class OtpVerificationPage extends GetView<OTPVerificationController> {
  const OtpVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFFFF5F5,
      ), // Light orange to purple gradient
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),

              // Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryYellow,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.content_cut,
                  color: AppTheme.black,
                  size: 40,
                ),
              ),

              const SizedBox(height: 40),

              // Header
              Column(
                children: [
                  const Text(
                    'Verify Your Phone',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter the 6-digit code sent to ${controller.phoneNumber.value}',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // OTP Input
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: PinCodeTextField(
                  appContext: context,
                  length: 6,
                  obscureText: false,
                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(12),
                    fieldHeight: 56,
                    fieldWidth: 45,
                    activeFillColor: AppTheme.primaryYellow.withValues(
                      alpha: 0.1,
                    ),
                    activeColor: AppTheme.primaryYellow,
                    inactiveFillColor: AppTheme.grey50,
                    inactiveColor: AppTheme.grey300,
                    selectedColor: AppTheme.primaryYellow,
                    selectedFillColor: AppTheme.primaryYellow.withValues(
                      alpha: 0.1,
                    ),
                  ),
                  animationDuration: const Duration(milliseconds: 300),
                  backgroundColor: Colors.transparent,
                  enableActiveFill: true,
                  controller: controller.otpController,
                  keyboardType: TextInputType.number,
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
              ),

              const SizedBox(height: 32),

              // Resend OTP
              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      controller.canResend.value
                          ? "Didn't receive the code?"
                          : 'Resend code in ${controller.countdown.value}s',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (controller.canResend.value)
                      TextButton(
                        onPressed: controller.resendOTP,
                        child: const Text(
                          'Resend',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.primaryYellow,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.otpController.text.length == 6
                        ? controller.verifyOTP
                        : null,
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
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.black,
                              ),
                            ),
                          )
                        : const Text(
                            'Verify',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Change Number
              TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  'Change phone number',
                  style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
