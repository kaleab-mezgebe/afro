import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../../../core/controllers/auth_controller.dart';
import '../../../core/theme/app_theme.dart';

class SettingsPage extends GetView<ProfileController> {
  SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.grey50,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(color: AppTheme.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preferences Section
              _buildPreferencesSection(),
              const SizedBox(height: 32),

              // App Settings Section
              _buildAppSettingsSection(),
              const SizedBox(height: 32),

              // Support Section
              _buildSupportSection(),
              const SizedBox(height: 32),

              // Account Actions
              _buildAccountActionsSection(),
              const SizedBox(height: 100), // Bottom padding
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.grey200.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  final RxBool _notificationsEnabled = true.obs;
  final RxBool _locationEnabled = true.obs;
  final RxBool _darkModeEnabled = false.obs;
  final RxString _selectedLanguage = 'English'.obs;
  final RxString _selectedCurrency = 'ETB'.obs;
  final RxString _servicePreference = 'all'.obs;

  Widget _buildPreferencesSection() {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preferences',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 24),

          // Service Preference
          _buildServicePreferenceTile(),

          // Notifications Toggle
          Obx(
            () => _buildSettingTile(
              icon: Icons.notifications_none_rounded,
              title: 'Push Notifications',
              subtitle: 'Booking reminders and updates',
              isToggle: true,
              value: _notificationsEnabled.value,
              onChanged: (value) => _notificationsEnabled.value = value,
            ),
          ),

          // Location Toggle
          Obx(
            () => _buildSettingTile(
              icon: Icons.location_on_outlined,
              title: 'Location Services',
              subtitle: 'Access your current location',
              isToggle: true,
              value: _locationEnabled.value,
              onChanged: (value) => _locationEnabled.value = value,
            ),
          ),

          // Dark Mode Toggle
          Obx(
            () => _buildSettingTile(
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              subtitle: 'Use dark theme across the app',
              isToggle: true,
              value: _darkModeEnabled.value,
              onChanged: (value) => _darkModeEnabled.value = value,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettingsSection() {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'App Settings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 24),

          // Language Selection
          Obx(
            () => _buildSettingTile(
              icon: Icons.language_rounded,
              title: 'Language',
              subtitle: _selectedLanguage.value,
              isToggle: false,
              value: null,
              onChanged: (value) => _showLanguageDialog(),
            ),
          ),

          // Currency Selection
          Obx(
            () => _buildSettingTile(
              icon: Icons.payments_outlined,
              title: 'Currency',
              subtitle: _selectedCurrency.value,
              isToggle: false,
              value: null,
              onChanged: (value) => _showCurrencyDialog(),
            ),
          ),

          // Payment Methods
          _buildSettingTile(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Payment Methods',
            subtitle: 'Manage your payment options',
            isToggle: false,
            value: null,
            onChanged: (value) {},
          ),

          // Privacy Settings
          _buildSettingTile(
            icon: Icons.security_outlined,
            title: 'Privacy & Security',
            subtitle: 'Control your privacy settings',
            isToggle: false,
            value: null,
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    final languages = ['English', 'Amharic', 'Oromiffa', 'French'];
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Language',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...languages.map(
              (lang) => ListTile(
                title: Text(lang),
                trailing: _selectedLanguage.value == lang
                    ? const Icon(
                        Icons.check_circle,
                        color: AppTheme.primaryYellow,
                      )
                    : null,
                onTap: () {
                  _selectedLanguage.value = lang;
                  Get.back();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencyDialog() {
    final currencies = ['ETB', 'USD', 'EUR', 'GBP'];
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Currency',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...currencies.map(
              (curr) => ListTile(
                title: Text(curr),
                trailing: _selectedCurrency.value == curr
                    ? const Icon(
                        Icons.check_circle,
                        color: AppTheme.primaryYellow,
                      )
                    : null,
                onTap: () {
                  _selectedCurrency.value = curr;
                  Get.back();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportSection() {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Support',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 24),

          _buildSettingTile(
            icon: Icons.help_outline_rounded,
            title: 'Help Center',
            subtitle: 'FAQs & Guides',
            isToggle: false,
            value: null,
            onChanged: (value) => Get.toNamed('/help-support'),
          ),

          _buildSettingTile(
            icon: Icons.mail_outline_rounded,
            title: 'Contact Us',
            subtitle: 'Get in touch with our team',
            isToggle: false,
            value: null,
            onChanged: (value) => Get.toNamed('/help-support'),
          ),

          _buildSettingTile(
            icon: Icons.info_outline_rounded,
            title: 'About',
            subtitle: 'Version 1.0.0',
            isToggle: false,
            value: null,
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }

  Widget _buildAccountActionsSection() {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 24),

          // Logout Button
          InkWell(
            onTap: _showLogoutDialog,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFF6B35).withValues(alpha: 0.2),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFFF6B35),
                    size: 22,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Logout Account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6B35),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicePreferenceTile() {
    return Obx(() {
      String preferenceLabel = _servicePreference.value == 'barber'
          ? 'Barber'
          : _servicePreference.value == 'salon'
          ? 'Salon'
          : 'Both';

      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _showServicePreferenceDialog,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryYellow.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.storefront_outlined,
                    color: AppTheme.primaryYellow,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Service Preference',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Currently showing: $preferenceLabel',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.grey400,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _showServicePreferenceDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Service Preference',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildPreferenceOption(
              'Barber',
              'barber',
              Icons.content_cut_rounded,
            ),
            const SizedBox(height: 12),
            _buildPreferenceOption('Salon', 'salon', Icons.spa_outlined),
            const SizedBox(height: 12),
            _buildPreferenceOption(
              'Both Services',
              'all',
              Icons.grid_view_rounded,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceOption(String label, String value, IconData icon) {
    return Obx(() {
      final isSelected = _servicePreference.value == value;

      return InkWell(
        onTap: () {
          _servicePreference.value = value;
          Get.back();
          Get.snackbar(
            'Preference Updated',
            'Now showing $label services',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppTheme.primaryYellow,
            colorText: AppTheme.black,
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryYellow.withValues(alpha: 0.1)
                : AppTheme.grey50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppTheme.primaryYellow : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppTheme.primaryYellow
                    : AppTheme.textSecondary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? AppTheme.black : AppTheme.textSecondary,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppTheme.primaryYellow,
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isToggle,
    required dynamic value,
    required Function(dynamic) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (isToggle) {
            onChanged(!value);
          } else {
            onChanged(null);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryYellow.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppTheme.primaryYellow, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isToggle) ...[
                Switch.adaptive(
                  value: value as bool,
                  onChanged: onChanged,
                  activeTrackColor: AppTheme.primaryYellow,
                ),
              ] else ...[
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.grey400,
                  size: 24,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Logout Account?'),
        content: const Text(
          'Are you sure you want to logout? You will need to login again to access your bookings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: AppTheme.grey600)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _performLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _performLogout() {
    if (AuthController.isInitialized) {
      AuthController.to.logout();
    } else {
      Get.snackbar(
        'Error',
        'Authentication system not available',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
