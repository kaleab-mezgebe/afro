import 'package:firebase_auth/firebase_auth.dart';

import '../../core/services/customer_api_service.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final CustomerApiService _customerApiService;

  ProfileRepositoryImpl({required CustomerApiService customerApiService})
    : _customerApiService = customerApiService;

  @override
  Future<Profile> getCurrentProfile() async {
    final data = await _customerApiService.getProfile();
    return _mapToProfile(data);
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
    final data = await _customerApiService.updateProfile(
      name: name,
      phone: phoneNumber,
      avatar: avatar,
      bio: bio,
      gender: gender,
      dateOfBirth: dateOfBirth,
    );
    // Also sync Firebase display name
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && name.isNotEmpty && name != user.displayName) {
      await user.updateDisplayName(name);
    }
    return _mapToProfile(data);
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not authenticated');

    // Re-authenticate then update password
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  @override
  Future<void> updatePreferences(List<String> preferences) async {
    await _customerApiService.updatePreferences({
      'preferredServices': preferences,
    });
  }

  @override
  Stream<Profile?> get profileChanges async* {
    // Emit current profile once; real-time updates can be added later
    try {
      final profile = await getCurrentProfile();
      yield profile;
    } catch (_) {
      yield null;
    }
  }

  Profile _mapToProfile(Map<String, dynamic> data) {
    // Backend returns { user: { id, name, email, phone, avatar, ... },
    //                   profile: { id, gender, dateOfBirth, bio, preferredServices, ... } }
    // Both GET and PUT /customers/profile use this shape.
    final user = (data['user'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final profile =
        (data['profile'] as Map<String, dynamic>?) ??
        (data['customer'] as Map<String, dynamic>?) ??
        <String, dynamic>{};

    return Profile(
      // Prefer the user's UUID as the canonical id
      id: user['id']?.toString() ?? profile['id']?.toString() ?? '',
      name: user['name']?.toString() ?? '',
      email: user['email']?.toString() ?? '',
      phoneNumber: user['phone']?.toString(),
      // avatar lives on the User entity
      avatar: user['avatar']?.toString() ?? profile['avatar']?.toString(),
      // profile-level fields
      gender: profile['gender']?.toString(),
      dateOfBirth: profile['dateOfBirth'] != null
          ? DateTime.tryParse(profile['dateOfBirth'].toString())
          : null,
      bio: profile['bio']?.toString(),
      preferences: List<String>.from(profile['preferredServices'] ?? []),
    );
  }
}
