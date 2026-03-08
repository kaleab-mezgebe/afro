import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/staff_service_models.dart';

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
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 2));

      // Mock data
      final mockStaff = [
        Staff(
          id: '1',
          shopId: 'shop1',
          firstName: 'Sarah',
          lastName: 'Johnson',
          email: 'sarah@barbershop.com',
          phoneNumber: '+1 234-567-8901',
          role: StaffRole.barber,
          status: StaffStatus.active,
          experience: 5,
          rating: 4.8,
          totalReviews: 120,
          baseSalary: 45000.0,
          canAcceptOnlineBookings: true,
          isFeatured: true,
          createdAt: DateTime.now().subtract(const Duration(days: 365)),
          updatedAt: DateTime.now(),
        ),
        Staff(
          id: '2',
          shopId: 'shop1',
          firstName: 'Mike',
          lastName: 'Wilson',
          email: 'mike@barbershop.com',
          phoneNumber: '+1 234-567-8902',
          role: StaffRole.barber,
          status: StaffStatus.active,
          experience: 3,
          rating: 4.5,
          totalReviews: 85,
          baseSalary: 38000.0,
          canAcceptOnlineBookings: true,
          isFeatured: false,
          createdAt: DateTime.now().subtract(const Duration(days: 180)),
          updatedAt: DateTime.now(),
        ),
        Staff(
          id: '3',
          shopId: 'shop1',
          firstName: 'Emily',
          lastName: 'Davis',
          email: 'emily@barbershop.com',
          phoneNumber: '+1 234-567-8903',
          role: StaffRole.receptionist,
          status: StaffStatus.onLeave,
          experience: 2,
          rating: 4.6,
          totalReviews: 45,
          baseSalary: 32000.0,
          canAcceptOnlineBookings: false,
          isFeatured: false,
          createdAt: DateTime.now().subtract(const Duration(days: 90)),
          updatedAt: DateTime.now(),
        ),
      ];

      state = StaffState(
        isLoading: false,
        staff: mockStaff,
      );
    } catch (e) {
      state = StaffState(error: e.toString());
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

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final staffProvider = StateNotifierProvider<StaffNotifier, StaffState>(
  (ref) => StaffNotifier(),
);
