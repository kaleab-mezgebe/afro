import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login({
    required String email,
    required String password,
  });

  Future<User> register({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
  });

  Future<User> refreshToken(String token);

  Future<void> logout();

  Future<void> forgotPassword(String email);

  Future<User> getCurrentUser();

  Future<User> updateProfile({
    required String name,
    String? phoneNumber,
    String? avatar,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Stream<User?> get userChanges;
}
