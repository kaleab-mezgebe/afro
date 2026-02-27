import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/user_registration_controller.dart';
import '../../../core/theme/app_theme.dart';

class UserRegistrationPage extends GetView<UserRegistrationController> {
  const UserRegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Complete Your Profile',
          style: TextStyle(
            color: AppTheme.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.white, AppTheme.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Header
                _buildHeader(),

                const SizedBox(height: 32),

                // Profile Photo Section
                _buildProfilePhotoSection(),

                const SizedBox(height: 32),

                // Personal Information Section
                _buildPersonalInfoSection(),

                const SizedBox(height: 32),

                // Contact Information Section
                _buildContactInfoSection(),

                const SizedBox(height: 32),

                // Preferences Section
                _buildPreferencesSection(),

                const SizedBox(height: 32),

                // Submit Button
                _buildSubmitButton(),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tell us about yourself',
          style: TextStyle(
            color: AppTheme.black,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'This helps us personalize your experience and recommend the best services for you',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 16,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePhotoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.grey50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.grey200),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              // TODO: Implement profile photo picker
            },
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primaryYellow.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primaryYellow.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: _buildDefaultAvatar(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tap to add photo',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Icon(Icons.camera_alt, color: AppTheme.textMuted, size: 40);
  }

  Widget _buildPersonalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Information',
          style: TextStyle(
            color: AppTheme.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        // First Name
        TextField(
          onChanged: controller.setFirstName,
          decoration: InputDecoration(
            hintText: 'First Name',
            prefixIcon: const Icon(Icons.person, color: AppTheme.textSecondary),
            filled: true,
            fillColor: AppTheme.grey50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.grey200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.grey200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryYellow),
            ),
            hintStyle: const TextStyle(color: AppTheme.textSecondary),
          ),
          style: const TextStyle(color: AppTheme.black),
        ),

        const SizedBox(height: 16),

        // Last Name
        TextField(
          onChanged: controller.setLastName,
          decoration: InputDecoration(
            hintText: 'Last Name',
            prefixIcon: const Icon(Icons.person, color: AppTheme.textSecondary),
            filled: true,
            fillColor: AppTheme.grey50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.grey200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.grey200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryYellow),
            ),
            hintStyle: const TextStyle(color: AppTheme.textSecondary),
          ),
          style: const TextStyle(color: AppTheme.black),
        ),

        const SizedBox(height: 16),

        // Date of Birth
        Obx(
          () => TextField(
            onTap: () => controller.selectDateOfBirth(),
            readOnly: true,
            decoration: InputDecoration(
              hintText: 'Date of Birth',
              prefixIcon: const Icon(
                Icons.calendar_today,
                color: AppTheme.textSecondary,
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white),
              ),
              hintStyle: const TextStyle(color: AppTheme.textSecondary),
            ),
            style: const TextStyle(color: AppTheme.black),
            controller: TextEditingController(
              text: controller.dateOfBirth.value.isNotEmpty
                  ? controller.formatDate(controller.dateOfBirth.value)
                  : '',
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Gender
        Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gender',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.setGender('male'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: controller.gender.value == 'male'
                              ? AppTheme.primaryYellow.withOpacity(0.1)
                              : AppTheme.grey50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: controller.gender.value == 'male'
                                ? AppTheme.primaryYellow
                                : AppTheme.grey200,
                          ),
                        ),
                        child: Text(
                          'Male',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: controller.gender.value == 'male'
                                ? AppTheme.primaryYellow
                                : AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.setGender('female'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: controller.gender.value == 'female'
                              ? AppTheme.primaryYellow.withOpacity(0.1)
                              : AppTheme.grey50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: controller.gender.value == 'female'
                                ? AppTheme.primaryYellow
                                : AppTheme.grey200,
                          ),
                        ),
                        child: Text(
                          'Female',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: controller.gender.value == 'female'
                                ? AppTheme.primaryYellow
                                : AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.setGender('other'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: controller.gender.value == 'other'
                              ? AppTheme.primaryYellow.withOpacity(0.1)
                              : AppTheme.grey50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: controller.gender.value == 'other'
                                ? AppTheme.primaryYellow
                                : AppTheme.grey200,
                          ),
                        ),
                        child: Text(
                          'Other',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: controller.gender.value == 'other'
                                ? AppTheme.primaryYellow
                                : AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Information',
          style: TextStyle(
            color: AppTheme.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        // Phone Number
        TextField(
          onChanged: controller.setPhoneNumber,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: 'Phone Number',
            prefixIcon: const Icon(Icons.phone, color: AppTheme.textSecondary),
            filled: true,
            fillColor: AppTheme.grey50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.grey200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.grey200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryYellow),
            ),
            hintStyle: const TextStyle(color: AppTheme.textSecondary),
          ),
          style: const TextStyle(color: AppTheme.black),
        ),

        const SizedBox(height: 16),

        // Location
        TextField(
          onChanged: controller.setLocation,
          decoration: InputDecoration(
            hintText: 'City/Area',
            prefixIcon: const Icon(
              Icons.location_on,
              color: AppTheme.textSecondary,
            ),
            filled: true,
            fillColor: AppTheme.grey50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.grey200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.grey200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryYellow),
            ),
            hintStyle: const TextStyle(color: AppTheme.textSecondary),
          ),
          style: const TextStyle(color: AppTheme.black),
        ),
      ],
    );
  }

  Widget _buildPreferencesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service Preferences',
          style: TextStyle(
            color: AppTheme.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        // Hair Type
        Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hair Type',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['Straight', 'Wavy', 'Curly', 'Coily', 'Kinky'].map((
                  type,
                ) {
                  final isSelected = controller.hairType.value == type;
                  return GestureDetector(
                    onTap: () => controller.setHairType(type),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryYellow.withOpacity(0.1)
                            : AppTheme.grey50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryYellow
                              : AppTheme.grey200,
                        ),
                      ),
                      child: Text(
                        type,
                        style: TextStyle(
                          color: isSelected
                              ? AppTheme.primaryYellow
                              : AppTheme.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Skin Type
        Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Skin Type',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['Normal', 'Dry', 'Oily', 'Combination', 'Sensitive']
                    .map((type) {
                      final isSelected = controller.skinType.value == type;
                      return GestureDetector(
                        onTap: () => controller.setSkinType(type),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            type,
                            style: TextStyle(
                              color: isSelected
                                  ? AppTheme.primaryYellow
                                  : AppTheme.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    })
                    .toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Preferred Services
        Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Preferred Services (Select all that apply)',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    [
                      'Haircuts',
                      'Styling',
                      'Coloring',
                      'Beard Grooming',
                      'Facials',
                      'Waxing',
                      'Manicure',
                      'Pedicure',
                      'Massage',
                    ].map((service) {
                      final isSelected = controller.preferredServices.contains(
                        service,
                      );
                      return GestureDetector(
                        onTap: () => controller.togglePreferredService(service),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primaryYellow
                                  : AppTheme.grey200,
                            ),
                          ),
                          child: Text(
                            service,
                            style: TextStyle(
                              color: isSelected
                                  ? AppTheme.primaryYellow
                                  : AppTheme.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: controller.canSubmit
              ? controller.submitRegistration
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppTheme.primaryYellow,
            elevation: 8,
            shadowColor: Colors.black.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: controller.isLoading.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryYellow,
                    ),
                  ),
                )
              : const Text(
                  'Complete Profile',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }
}
