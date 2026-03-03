import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:sizer/sizer.dart';
import '../../../core/theme/app_theme.dart';

class CountryPickerWidget extends StatelessWidget {
  final Country country;
  final Function(Country) onCountryChanged;
  final String? errorText;

  const CountryPickerWidget({
    super.key,
    required this.country,
    required this.onCountryChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Use the original country picker to get ALL countries from the package
        // This ensures we have the complete, non-mocked country list
        showCountryPicker(
          context: context,
          showPhoneCode: true,
          onSelect: onCountryChanged,
          countryListTheme: CountryListThemeData(
            // Custom styling to make it look amazing
            backgroundColor: Colors.white,
            searchTextStyle: const TextStyle(color: AppTheme.textPrimary),
            textStyle: const TextStyle(color: AppTheme.textPrimary),
            inputDecoration: InputDecoration(
              hintText: '🔍 Search countries...',
              hintStyle: const TextStyle(color: AppTheme.textMuted),
              filled: true,
              fillColor: AppTheme.grey50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppTheme.primaryYellow,
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 4.w,
                vertical: 1.5.h,
              ),
            ),
            // Custom country item styling
            flagSize: 24,
            bottomSheetHeight: 70.h,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.5.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(country.flagEmoji, style: TextStyle(fontSize: 16.sp)),
            SizedBox(width: 1.w),
            Text(
              '+${country.phoneCode}',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 1.w),
            Icon(Icons.arrow_drop_down, color: AppTheme.textMuted, size: 18.sp),
          ],
        ),
      ),
    );
  }
}
