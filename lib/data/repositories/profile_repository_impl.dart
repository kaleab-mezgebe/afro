import 'dart:convert';

import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/local/local_storage.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final LocalStorage _localStorage;

  ProfileRepositoryImpl({required LocalStorage localStorage})
    : _localStorage = localStorage;

  @override
  Future<Profile> getCurrentProfile() async {
    final profileJson = await _localStorage.get('current_profile');
    if (profileJson != null) {
      return Profile.fromJson(jsonDecode(profileJson));
    }
    
    // Return default profile if none exists
    final defaultProfile = Profile(
      id: 'default_profile',
      name: 'Kaleab Mezgebe',
      email: 'john.doe@example.com',
      phoneNumber: '+1234567890',
      bio: 'Welcome to my profile!',
      preferences: ['haircut', 'beard_trim'],
    );
    
    await _localStorage.save('current_profile', jsonEncode(defaultProfile.toJson()));
    return defaultProfile;
  }

  @override
  Future<Profile> updateProfile({
    required String name,
    String? phoneNumber,
    String? avatar,
    String? bio,
    String? gender,
    DateTime? dateOfBirth,
  }) async {
    final currentProfile = await getCurrentProfile();
    final updatedProfile = currentProfile.copyWith(
      name: name,
      phoneNumber: phoneNumber,
      avatar: avatar,
      bio: bio,
      gender: gender,
      dateOfBirth: dateOfBirth,
    );

    await _localStorage.save('current_profile', jsonEncode(updatedProfile.toJson()));
    return updatedProfile;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    // Mock implementation - in real app, this would call an API
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> updatePreferences(List<String> preferences) async {
    final currentProfile = await getCurrentProfile();
    final updatedProfile = currentProfile.copyWith(preferences: preferences);
    
    await _localStorage.save('current_profile', jsonEncode(updatedProfile.toJson()));
  }

  @override
  Stream<Profile?> get profileChanges async* {
    // In a real implementation, this would listen to profile changes
    // For now, yield current profile and then listen for changes
    while (true) {
      await Future.delayed(const Duration(seconds: 1));
      final profileJson = await _localStorage.get('current_profile');
      if (profileJson != null) {
        yield Profile.fromJson(jsonDecode(profileJson));
      }
    }
  }
}
