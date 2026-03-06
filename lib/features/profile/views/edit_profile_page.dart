import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/profile_controller.dart';
import '../../../core/theme/afro_theme.dart';

class EditProfilePage extends GetView<ProfileController> {
  EditProfilePage({super.key});

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  
  String? _selectedGender;
  List<String> _selectedPreferences = [];

  @override
  Widget build(BuildContext context) {
    final profile = controller.profile;
    
    // Initialize controllers with current profile data
    if (profile != null) {
      _nameController.text = profile.name;
      _phoneController.text = profile.phoneNumber ?? '';
      _bioController.text = profile.bio ?? '';
      _selectedGender = profile.gender;
      _selectedPreferences = List.from(profile.preferences);
      
      if (profile.dateOfBirth != null) {
        _dateOfBirthController.text = 
            '${profile.dateOfBirth!.day}/${profile.dateOfBirth!.month}/${profile.dateOfBirth!.year}';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture Section
                _buildProfilePictureSection(),
                
                const SizedBox(height: 24),
                
                // Personal Information
                _buildSectionTitle('Personal Information'),
                
                const SizedBox(height: 16),
                
                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'Enter your full name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Email Field (Read-only)
                TextFormField(
                  initialValue: profile?.email,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Your email address',
                  ),
                  enabled: false,
                  style: const TextStyle(color: AfroTheme.textLight),
                ),
                
                const SizedBox(height: 16),
                
                // Phone Field
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'Enter your phone number',
                  ),
                  keyboardType: TextInputType.phone,
                ),
                
                const SizedBox(height: 16),
                
                // Gender Field
                DropdownButtonFormField<String>(
                  initialValue: _selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    hintText: 'Select your gender',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                    DropdownMenuItem(value: 'Prefer not to say', child: Text('Prefer not to say')),
                  ],
                  onChanged: (value) {
                    _selectedGender = value;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Date of Birth Field
                TextFormField(
                  controller: _dateOfBirthController,
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                    hintText: 'Select your date of birth',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: _selectDateOfBirth,
                ),
                
                const SizedBox(height: 24),
                
                // Bio Section
                _buildSectionTitle('About Me'),
                
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _bioController,
                  decoration: const InputDecoration(
                    labelText: 'Bio',
                    hintText: 'Tell us about yourself',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                
                const SizedBox(height: 24),
                
                // Service Preferences
                _buildSectionTitle('Service Preferences'),
                
                const SizedBox(height: 16),
                
                _buildPreferencesSection(),
                
                const SizedBox(height: 32),
                
                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    child: controller.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProfilePictureSection() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AfroTheme.cardColor,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: AfroTheme.primaryColor, width: 2),
            ),
            child: const Icon(
              Icons.person,
              size: 50,
              color: AfroTheme.textLight,
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _changeProfilePicture,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Change Photo'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Get.textTheme.headlineSmall?.copyWith(
        color: AfroTheme.primaryColor,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPreferencesSection() {
    final availablePreferences = [
      'Haircut',
      'Beard Trim',
      'Shave',
      'Hair Coloring',
      'Styling',
      'Treatment',
      'Massage',
      'Facial',
      'Manicure',
      'Pedicure',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availablePreferences.map((preference) {
        final isSelected = _selectedPreferences.contains(preference);
        return FilterChip(
          label: Text(preference),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              _selectedPreferences.add(preference);
            } else {
              _selectedPreferences.remove(preference);
            }
          },
          backgroundColor: AfroTheme.cardColor,
          selectedColor: AfroTheme.primaryColor.withValues(alpha: 0.2),
          checkmarkColor: AfroTheme.primaryColor,
        );
      }).toList(),
    );
  }

  void _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: controller.profile?.dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      _dateOfBirthController.text = 
          '${picked.day}/${picked.month}/${picked.year}';
    }
  }

  void _changeProfilePicture() {
    // TODO: Implement image picker
    Get.snackbar('Info', 'Image picker will be implemented soon');
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Parse date of birth
    DateTime? dateOfBirth;
    if (_dateOfBirthController.text.isNotEmpty) {
      try {
        final parts = _dateOfBirthController.text.split('/');
        dateOfBirth = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      } catch (e) {
        Get.snackbar('Error', 'Invalid date format');
        return;
      }
    }

    await controller.updateProfile(
      name: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim().isEmpty 
          ? null 
          : _phoneController.text.trim(),
      bio: _bioController.text.trim().isEmpty 
          ? null 
          : _bioController.text.trim(),
      gender: _selectedGender,
      dateOfBirth: dateOfBirth,
    );

    // Update preferences separately
    await controller.updatePreferences(_selectedPreferences);

    if (controller.error.isEmpty) {
      Get.back();
    }
  }
}
