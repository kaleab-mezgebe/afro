import 'package:customer_app/domain/repositories/profile_repository.dart';

class UpdatePreferences {
  final ProfileRepository repository;

  UpdatePreferences(this.repository);

  Future<void> call(List<String> preferences) {
    return repository.updatePreferences(preferences);
  }
}
