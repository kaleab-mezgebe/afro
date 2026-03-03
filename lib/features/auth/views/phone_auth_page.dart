import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

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
      width: 20.w,
      height: 20.w,
      decoration: BoxDecoration(
        color: AppTheme.primaryYellow,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.phone, color: AppTheme.black, size: 10.w),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Login',
          style: TextStyle(
            fontSize: 24.sp,
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
      () => Row(
        children: [
          // Country Picker
          Container(
            width: 30.w,
            height: 7.h,
            decoration: BoxDecoration(
              color: AppTheme.grey50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.grey300),
            ),
            child: CountryPickerWidget(
              country: controller.selectedCountry.value,
              onCountryChanged: controller.onCountryChanged,
            ),
          ),

          SizedBox(width: 3.w),

          // Phone Number
          Expanded(
            child: TextFormField(
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
              validator: controller.validatePhoneNumber,
              onChanged: controller.setPhoneNumber,
              decoration: InputDecoration(
                hintText: 'Phone Number',
                filled: true,
                fillColor: AppTheme.grey50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.grey300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.grey300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppTheme.primaryYellow,
                    width: 2,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 1.5.h,
                ),
                hintStyle: TextStyle(
                  fontSize: 12.sp,
                  color: AppTheme.textMuted,
                ),
              ),
            ),
          ),
        ],
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
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSocialButton(Icons.g_mobiledata, controller.loginWithGoogle),
        _buildSocialButton(Icons.facebook, controller.loginWithFacebook),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, VoidCallback onTap) {
    return Container(
      width: 16.w,
      height: 16.w,
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.grey300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, size: 7.w, color: AppTheme.textSecondary),
      ),
    );
  }
}
