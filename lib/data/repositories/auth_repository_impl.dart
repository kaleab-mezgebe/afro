import 'dart:convert';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/local_storage.dart';

class AuthRepositoryImpl implements AuthRepository {
  final LocalStorage _localStorage;

  AuthRepositoryImpl({required LocalStorage localStorage})
    : _localStorage = localStorage;

  @override
  Future<User> login({required String email, required String password}) async {
    // Mock implementation - in real app, this would call an API
    await Future.delayed(const Duration(seconds: 2));

    // Mock user data
    final mockUser = User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Kaleab Mezgebe',
      email: email,
      isEmailVerified: true,
      createdAt: DateTime.now(),
    );

    // Save to local storage
    await _localStorage.save('current_user', jsonEncode(mockUser.toJson()));

    return mockUser;
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    // Mock implementation - in real app, this would call an API
    await Future.delayed(const Duration(seconds: 2));

    // Mock user data
    final mockUser = User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      isEmailVerified: false,
      createdAt: DateTime.now(),
    );

    // Save to local storage
    await _localStorage.save('current_user', jsonEncode(mockUser.toJson()));

    return mockUser;
  }

  @override
  Future<User> refreshToken(String token) async {
    // Mock implementation
    final currentUserJson = await _localStorage.get('current_user');
    if (currentUserJson != null) {
      return User.fromJson(jsonDecode(currentUserJson));
    }
    throw Exception('No user logged in');
  }

  @override
  Future<void> logout() async {
    await _localStorage.remove('current_user');
  }

  @override
  Future<void> forgotPassword(String email) async {
    // Mock implementation
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<User> getCurrentUser() async {
    final currentUserJson = await _localStorage.get('current_user');
    if (currentUserJson != null) {
      return User.fromJson(jsonDecode(currentUserJson));
    }
    throw Exception('No user logged in');
  }

  @override
  Future<User> updateProfile({
    required String name,
    String? phoneNumber,
    String? avatar,
  }) async {
    final currentUser = await getCurrentUser();
    final updatedUser = currentUser.copyWith(
      name: name,
      phoneNumber: phoneNumber,
      avatar: avatar,
      updatedAt: DateTime.now(),
    );

    await _localStorage.save('current_user', updatedUser.toJson() as String);
    return updatedUser;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    // Mock implementation
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Stream<User?> get userChanges async* {
    // In a real implementation, this would listen to auth state changes
    // For now, return empty stream
    yield null;
  }
}
