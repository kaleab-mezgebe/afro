import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

// Staff data model
class StaffMember {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String specialty;
  final double rating;
  final int completedServices;
  final double baseSalary;
  final bool isActive;
  final DateTime joinDate;
  final String? avatar;

  StaffMember({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.specialty,
    required this.rating,
    required this.completedServices,
    required this.baseSalary,
    required this.isActive,
    required this.joinDate,
    this.avatar,
  });

  factory StaffMember.fromJson(Map<String, dynamic> json) {
    return StaffMember(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'Staff',
      specialty: json['specialty'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      completedServices: json['completedServices'] ?? 0,
      baseSalary: (json['baseSalary'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? true,
      joinDate: json['joinDate'] != null
          ? DateTime.parse(json['joinDate'])
          : DateTime.now(),
      avatar: json['avatar'] ?? json['profileImage'],
    );
  }
}

class StaffNotifier extends StateNotifier<AsyncValue<List<StaffMember>>> {
  final ApiService _apiService = ApiService();

  StaffNotifier() : super(const AsyncValue.loading()) {
    loadStaff();
  }

  Future<void> loadStaff() async {
    state = const AsyncValue.loading();
    try {
      final response = await _apiService.getStaff();
      final List<dynamic> data = response.data['data'] ?? response.data ?? [];

      final staff = data.map((json) => StaffMember.fromJson(json)).toList();
      state = AsyncValue.data(staff);
    } catch (e) {
      print('Error loading staff: $e');
      // Return empty list if API fails
      state = const AsyncValue.data([]);
    }
  }

  Future<void> addStaff(Map<String, dynamic> staffData) async {
    try {
      await _apiService.createStaff(staffData);
      await loadStaff(); // Reload staff list
    } catch (e) {
      print('Error adding staff: $e');
      rethrow;
    }
  }

  Future<void> updateStaff(
      String staffId, Map<String, dynamic> staffData) async {
    try {
      await _apiService.updateStaff(staffId, staffData);
      await loadStaff(); // Reload staff list
    } catch (e) {
      print('Error updating staff: $e');
      rethrow;
    }
  }

  Future<void> deleteStaff(String staffId) async {
    try {
      await _apiService.deleteStaff(staffId);
      await loadStaff(); // Reload staff list
    } catch (e) {
      print('Error deleting staff: $e');
      rethrow;
    }
  }
}

final staffProvider =
    StateNotifierProvider<StaffNotifier, AsyncValue<List<StaffMember>>>((ref) {
  return StaffNotifier();
});
