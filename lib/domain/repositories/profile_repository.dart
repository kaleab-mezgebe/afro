import '../entities/profile.dart';

abstract class ProfileRepository {
  Future<Profile> getCurrentProfile();
  Future<Profile> updateProfile({
    required String name,
    String? phoneNumber,
    String? avatar,
    String? bio,
    String? gender,
    DateTime? dateOfBirth,
  });
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<void> updatePreferences(List<String> preferences);
  Stream<Profile?> get profileChanges;
}
