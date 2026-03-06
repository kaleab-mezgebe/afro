import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../controllers/otp_verification_controller.dart';
import '../../../core/theme/app_theme.dart';

class OtpVerificationPage extends GetView<OTPVerificationController> {
  const OtpVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get phone number from controller
    final String phoneNumber = controller.phoneNumber.value.isNotEmpty 
        ? controller.phoneNumber.value 
        : '+25194141459'; 

    return Scaffold(
      backgroundColor: AppTheme.white,
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

              // Header - Updated to show phone number
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
                  const SizedBox(height: 10),
                  Text(
                    'We sent a verification code to:',
                    style: const TextStyle(fontSize: 16, color: AppTheme.black),
                  ),
                  Text(
                    phoneNumber, // Show your phone number
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryYellow,
                    ),
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
