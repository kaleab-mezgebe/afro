import 'package:customer_app/domain/entities/profile.dart';
import 'package:customer_app/domain/repositories/profile_repository.dart';

class UpdateProfile {
  final ProfileRepository repository;

  UpdateProfile(this.repository);

  Future<Profile> call({
    required String name,
    String? phoneNumber,
    String? avatar,
    String? bio,
    String? gender,
    DateTime? dateOfBirth,
  }) {
    return repository.updateProfile(
      name: name,
      phoneNumber: phoneNumber,
      avatar: avatar,
      bio: bio,
      gender: gender,
      dateOfBirth: dateOfBirth,
    );
  }
}
