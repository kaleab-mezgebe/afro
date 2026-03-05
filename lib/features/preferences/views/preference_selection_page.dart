import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';

class PreferenceSelectionPage extends StatefulWidget {
  const PreferenceSelectionPage({super.key});

  @override
  State<PreferenceSelectionPage> createState() =>
      _PreferenceSelectionPageState();
}

class _PreferenceSelectionPageState extends State<PreferenceSelectionPage> {
  String? _selectedPreference;

  Future<void> _savePreferenceAndContinue() async {
    if (_selectedPreference == null) {
      Get.snackbar(
        'Selection Required',
        'Please select your preference to continue',
        backgroundColor: AppTheme.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_preference', _selectedPreference!);
    await prefs.setBool('preference_selected', true);

    Get.offAllNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // Title
              const Text(
                'Choose Your Preference',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.black,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Subtitle
              Text(
                'Select the type of service provider you prefer',
                style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 60),

              // Barber Option
              _buildPreferenceCard(
                title: 'Barber',
                subtitle: 'Men\'s grooming specialists',
                icon: Icons.content_cut,
                value: 'barber',
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryYellow.withValues(alpha: 0.2),
                    AppTheme.primaryYellow.withValues(alpha: 0.1),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Salon Option
              _buildPreferenceCard(
                title: 'Salon',
                subtitle: 'Full-service beauty & styling',
                icon: Icons.spa,
                value: 'salon',
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryYellow.withValues(alpha: 0.2),
                    AppTheme.primaryYellow.withValues(alpha: 0.1),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Both Option
              _buildPreferenceCard(
                title: 'Both',
                subtitle: 'Show all service providers',
                icon: Icons.apps,
                value: 'all',
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryYellow.withValues(alpha: 0.2),
                    AppTheme.primaryYellow.withValues(alpha: 0.1),
                  ],
                ),
              ),

              const Spacer(),

              // Continue Button
              ElevatedButton(
                onPressed: _savePreferenceAndContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryYellow,
                  foregroundColor: AppTheme.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreferenceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required Gradient gradient,
  }) {
    final isSelected = _selectedPreference == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPreference = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: isSelected ? gradient : null,
          color: isSelected ? null : AppTheme.grey100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryYellow : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryYellow.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryYellow : AppTheme.grey300,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 32,
                color: isSelected ? AppTheme.black : AppTheme.textSecondary,
              ),
            ),

            const SizedBox(width: 20),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppTheme.black : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected
                          ? AppTheme.textSecondary
                          : AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            ),

            // Check Icon
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryYellow,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 20, color: AppTheme.black),
              ),
          ],
        ),
      ),
    );
  }
}
