import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
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
        showCountryPicker(
          context: context,
          showPhoneCode: true,
          onSelect: onCountryChanged,
          countryListTheme: CountryListThemeData(
            backgroundColor: Colors.white,
            searchTextStyle: const TextStyle(color: AppTheme.textPrimary),
            textStyle: const TextStyle(color: AppTheme.textPrimary),
            inputDecoration: InputDecoration(
              hintText: 'Search country...',
              hintStyle: const TextStyle(color: AppTheme.textMuted),
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
                borderSide: const BorderSide(color: AppTheme.primaryYellow, width: 2),
              ),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: errorText != null ? AppTheme.error : AppTheme.grey300,
            width: errorText != null ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              country.flagEmoji,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 8),
            Text(
              '+${country.phoneCode}',
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_drop_down,
              color: AppTheme.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
