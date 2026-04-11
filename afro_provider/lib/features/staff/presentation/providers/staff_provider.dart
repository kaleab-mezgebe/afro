import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/staff_service_models.dart';
import '../../../../core/di/injection_container.dart';

// Staff State
class StaffState {
  final bool isLoading;
  final String? error;
  final List<Staff> staff;

  const StaffState({
    this.isLoading = false,
    this.error,
    this.staff = const [],
  });

  StaffState copyWith({
    bool? isLoading,
    String? error,
    List<Staff>? staff,
  }) {
    return StaffState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      staff: staff ?? this.staff,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StaffState &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          error == other.error &&
          staff == other.staff;

  @override
  int get hashCode => Object.hash(isLoading, error, staff);
}

// Staff Notifier
class StaffNotifier extends StateNotifier<StaffState> {
  StaffNotifier() : super(const StaffState());

  Future<void> loadStaff() async {
    state = const StaffState(isLoading: true);

    try {
      // Get shop ID from provider service (assuming first shop)
      final shops = await shopService.getShops();
      if (shops.isEmpty) {
        state = const StaffState(
          isLoading: false,
          error: 'No shop found. Please create a shop first.',
          staff: [],
        );
        return;
      }

      final shopId = shops[0]['id'].toString();

      // Fetch staff from API
      final response = await staffService.getShopStaff(shopId);

      // Convert API response to Staff models
      final staff = response.map((json) {
        return Staff(
          id: json['id'].toString(),
          shopId: json['shopId']?.toString() ?? '',
          firstName: json['firstName'] ?? '',
          lastName: json['lastName'] ?? '',
          email: json['email'] ?? '',
          phoneNumber: json['phoneNumber'] ?? '',
          role: _parseRole(json['role']),
          status: _parseStatus(json['status']),
          experience: json['experience'] ?? 0,
          rating: (json['rating'] ?? 0).toDouble(),
          totalReviews: json['totalReviews'] ?? 0,
          baseSalary: (json['baseSalary'] ?? 0).toDouble(),
          canAcceptOnlineBookings: json['canAcceptOnlineBookings'] ?? true,
          isFeatured: json['isFeatured'] ?? false,
          createdAt: DateTime.parse(json['createdAt']),
          updatedAt: DateTime.parse(json['updatedAt']),
        );
      }).toList();

      state = StaffState(
        isLoading: false,
        staff: staff,
        error: null,
      );
    } catch (e) {
      state = StaffState(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  StaffRole _parseRole(String? role) {
    switch (role?.toLowerCase()) {
      case 'barber':
        return StaffRole.barber;
      case 'receptionist':
        return StaffRole.receptionist;
      case 'manager':
        return StaffRole.manager;
      default:
        return StaffRole.barber;
    }
  }

  StaffStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return StaffStatus.active;
      case 'on_leave':
      case 'onleave':
        return StaffStatus.onLeave;
      case 'inactive':
        return StaffStatus.inactive;
      default:
        return StaffStatus.active;
    }
  }

  void addStaff(Staff staffMember) {
    final currentStaff = List<Staff>.from(state.staff);
    currentStaff.add(staffMember);
    state = state.copyWith(staff: currentStaff);
  }

  void updateStaff(Staff staffMember) {
    final currentStaff = List<Staff>.from(state.staff);
    final index = currentStaff.indexWhere((s) => s.id == staffMember.id);

    if (index != -1) {
      currentStaff[index] = staffMember;
    }

    state = state.copyWith(staff: currentStaff);
  }

  void deleteStaff(String staffId) {
    final currentStaff =
        state.staff.where((staff) => staff.id != staffId).toList();
    state = state.copyWith(staff: currentStaff);
  }

  void updateStaffStatus(String staffId, StaffStatus newStatus) {
    final currentStaff = List<Staff>.from(state.staff);
    final index = currentStaff.indexWhere((s) => s.id == staffId);

    if (index != -1) {
      final updatedStaff = Staff(
        id: currentStaff[index].id,
        shopId: currentStaff[index].shopId,
        firstName: currentStaff[index].firstName,
        lastName: currentStaff[index].lastName,
        email: currentStaff[index].email,
        phoneNumber: currentStaff[index].phoneNumber,
        role: currentStaff[index].role,
        status: newStatus,
        experience: currentStaff[index].experience,
        rating: currentStaff[index].rating,
        totalReviews: currentStaff[index].totalReviews,
        baseSalary: currentStaff[index].baseSalary,
        canAcceptOnlineBookings: currentStaff[index].canAcceptOnlineBookings,
        isFeatured: currentStaff[index].isFeatured,
        createdAt: currentStaff[index].createdAt,
        updatedAt: DateTime.now(),
      );
      currentStaff[index] = updatedStaff;
      state = state.copyWith(staff: currentStaff);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final staffProvider = StateNotifierProvider<StaffNotifier, StaffState>(
  (ref) => StaffNotifier(),
);
