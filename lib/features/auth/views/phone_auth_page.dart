import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../controllers/phone_auth_controller.dart';
import '../widgets/country_picker_widget.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/brand_loading_button.dart';

class PhoneAuthPage extends GetView<PhoneAuthController> {
  const PhoneAuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 16.h),

                    _buildLogo(),
                    SizedBox(height: 2.h),

                    _buildHeader(),
                    SizedBox(height: 3.h),

                    Form(
                      key: controller.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPhoneField(),
                          Obx(
                            () => controller.error.value.isNotEmpty
                                ? Padding(
                                    padding: EdgeInsets.only(
                                      top: 1.h,
                                      left: 2.w,
                                    ),
                                    child: Text(
                                      controller.error.value,
                                      style: TextStyle(
                                        color: AppTheme.error,
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 2.h),

                    _buildLoginButton(),

                    SizedBox(height: 2.5.h),

                    _buildSeparator(),

                    SizedBox(height: 2.5.h),

                    _buildSocialLogin(),

                    SizedBox(height: 2.5.h),
                  ],
                ),
              ),
            ),
          ),

          // Full-screen loading overlay
          Obx(
            () => controller.isLoading.value
                ? SafeArea(
                    top: false,
                    bottom: false,
                    child: Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.3),
                        child: Align(
                          alignment: Alignment
                              .center, // Center horizontally, slightly lower vertically
                          child: Transform.translate(
                            offset: Offset(0, 50), // Move 50 pixels down
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppTheme.primaryYellow,
                                    ),
                                    backgroundColor: Colors.transparent,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return SizedBox(
      width: 120,
      height: 120,
      child: Center(
        child: Image.asset('assets/images/logo.png', width: 120, height: 120),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Login',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 0.8.h),
        Text(
          'Enter your phone number to continue',
          style: TextStyle(fontSize: 12.sp, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: AppTheme.grey50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.grey300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Country Picker
            SizedBox(
              width: 28.w,
              height: 7.h,
              child: CountryPickerWidget(
                country: controller.selectedCountry.value,
                onCountryChanged: controller.onCountryChanged,
              ),
            ),

            // Phone Number
            Expanded(
              child: TextFormField(
                controller: controller.phoneController,
                keyboardType: TextInputType.phone,
                onChanged: controller.setPhoneNumber,
                maxLength: controller.maxPhoneLength.value,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: 'Phone Number',
                  filled: false,
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  counterText: '',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 5.w,
                    vertical: 1.5.h,
                  ),
                  hintStyle: TextStyle(
                    fontSize: 13.sp,
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w400,
                  ),
                  errorStyle: const TextStyle(height: 0, fontSize: 0),
                ),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 7.h,
        child: ElevatedButton(
          onPressed: controller.canProceed ? controller.proceed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryYellow, // Always yellow
            foregroundColor: AppTheme.black,
            disabledBackgroundColor:
                AppTheme.primaryYellow, // Keep yellow when disabled
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Continue',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildSeparator() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppTheme.grey300)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            'Or ',
            style: TextStyle(fontSize: 11.sp, color: AppTheme.textSecondary),
          ),
        ),
        const Expanded(child: Divider(color: AppTheme.grey300)),
      ],
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        // Social login buttons
        SocialLoginButton(
          text: 'Continue with Google    ',
          iconAssetPath: 'assets/icons/google.svg',
          onTap: controller.loginWithGoogle,
          isLoading: false, // Never show internal loading
          backgroundColor: Colors.white,
          textColor: Colors.black87,
          borderColor: AppTheme.grey100,
          height: 7.h,
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
        ),
        SizedBox(height: 2.5.h),
        SocialLoginButton(
          text: 'Continue with Facebook',
          iconAssetPath: 'assets/icons/facebook.svg',
          onTap: controller.loginWithFacebook,
          isLoading:
              false, // Never show internal loading - this prevents second loading
          backgroundColor: Colors.white,
          textColor: Colors.black,
          borderColor: AppTheme.grey100,
          height: 7.h,
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
        ),
      ],
    );
  }
}
