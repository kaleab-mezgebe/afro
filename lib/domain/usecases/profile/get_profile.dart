import 'package:customer_app/domain/entities/profile.dart';
import 'package:customer_app/domain/repositories/profile_repository.dart';

class GetProfile {
  final ProfileRepository repository;

  GetProfile(this.repository);

  Future<Profile> call() {
    return repository.getCurrentProfile();
  }
}
