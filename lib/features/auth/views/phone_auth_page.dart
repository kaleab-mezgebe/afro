import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../controllers/phone_auth_controller.dart';
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
          padding: EdgeInsets.all(4.w),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 12.h),

                _buildLogo(),
                SizedBox(height: 2.h),

                _buildHeader(),
                SizedBox(height: 3.h),

                Form(key: controller.formKey, child: _buildPhoneField()),

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
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(shape: BoxShape.circle),
      child: Image.asset('assets/images/logo.png', width: 36.w, height: 32.w),
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
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Country Picker
            Container(
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
                validator: controller.validatePhoneNumber,
                onChanged: controller.setPhoneNumber,
                decoration: InputDecoration(
                  hintText: 'Phone Number',
                  filled: false,
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 5.w,
                    vertical: 1.5.h,
                  ),
                  hintStyle: TextStyle(
                    fontSize: 13.sp,
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w400,
                  ),
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
            backgroundColor: AppTheme.primaryYellow,
            foregroundColor: AppTheme.black,
            disabledBackgroundColor: AppTheme.grey300,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: controller.isLoading.value
              ? SizedBox(
                  width: 5.w,
                  height: 5.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.black),
                  ),
                )
              : Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
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
            'Or login with',
            style: TextStyle(fontSize: 11.sp, color: AppTheme.textSecondary),
          ),
        ),
        const Expanded(child: Divider(color: AppTheme.grey300)),
      ],
    );
  }

  Widget _buildSocialLogin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton(
          'assets/icons/google.svg',
          controller.loginWithGoogle,
        ),
        SizedBox(width: 4.w),
        _buildSocialButton(
          'assets/icons/facebook.svg',
          controller.loginWithFacebook,
        ),
      ],
    );
  }

  Widget _buildSocialButton(String svgAssetPath, VoidCallback onTap) {
    return Container(
      width: 16.w,
      height: 16.w,
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.grey300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: SvgPicture.asset(svgAssetPath, width: 7.w, height: 7.w),
      ),
    );
  }
}
