import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/appointment_analytics_models.dart';

// Appointment State
class AppointmentState {
  final bool isLoading;
  final String? error;
  final List<Appointment> appointments;
  final DateTime? selectedDate;

  const AppointmentState({
    this.isLoading = false,
    this.error,
    this.appointments = const [],
    this.selectedDate,
  });

  AppointmentState copyWith({
    bool? isLoading,
    String? error,
    List<Appointment>? appointments,
    DateTime? selectedDate,
  }) {
    return AppointmentState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      appointments: appointments ?? this.appointments,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppointmentState &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          error == other.error &&
          appointments == other.appointments &&
          selectedDate == other.selectedDate;

  @override
  int get hashCode => Object.hash(isLoading, error, appointments, selectedDate);
}

// Appointment Notifier
class AppointmentNotifier extends StateNotifier<AppointmentState> {
  AppointmentNotifier() : super(const AppointmentState());

  Future<void> loadAppointments(DateTime date) async {
    state = state.copyWith(isLoading: true, selectedDate: date);

    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 2));

      // Mock data
      final mockAppointments = [
        Appointment(
          id: '1',
          customerId: 'cust1',
          staffId: 'staff1',
          shopId: 'shop1',
          bookingType: BookingType.online,
          appointmentDateTime: DateTime(date.year, date.month, date.day, 9, 0),
          duration: 30,
          startTime: DateTime(date.year, date.month, date.day, 9, 0),
          endTime: DateTime(date.year, date.month, date.day, 9, 30),
          status: AppointmentStatus.confirmed,
          totalPrice: 25.0,
          depositAmount: 0.0,
          tipAmount: 0.0,
          isNoShow: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          services: [
            AppointmentService(
              id: 'svc1',
              serviceId: 'service1',
              price: 25.0,
              duration: 30,
            ),
          ],
        ),
        Appointment(
          id: '2',
          customerId: 'cust2',
          staffId: 'staff2',
          shopId: 'shop1',
          bookingType: BookingType.walkIn,
          appointmentDateTime: DateTime(date.year, date.month, date.day, 10, 0),
          duration: 45,
          startTime: DateTime(date.year, date.month, date.day, 10, 0),
          endTime: DateTime(date.year, date.month, date.day, 10, 45),
          status: AppointmentStatus.confirmed,
          totalPrice: 40.0,
          depositAmount: 0.0,
          tipAmount: 0.0,
          isNoShow: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          services: [
            AppointmentService(
              id: 'svc2',
              serviceId: 'service2',
              price: 40.0,
              duration: 45,
            ),
          ],
        ),
      ];

      state = AppointmentState(
        isLoading: false,
        appointments: mockAppointments,
      );
    } catch (e) {
      state = AppointmentState(error: e.toString());
    }
  }

  void addAppointment(Appointment appointment) {
    final currentAppointments = List<Appointment>.from(state.appointments);
    currentAppointments.add(appointment);
    state = state.copyWith(appointments: currentAppointments);
  }

  void updateAppointment(Appointment appointment) {
    final currentAppointments = List<Appointment>.from(state.appointments);
    final index = currentAppointments.indexWhere((a) => a.id == appointment.id);

    if (index != -1) {
      currentAppointments[index] = appointment;
    }

    state = state.copyWith(appointments: currentAppointments);
  }

  void deleteAppointment(String appointmentId) {
    final currentAppointments =
        state.appointments.where((a) => a.id != appointmentId).toList();
    state = state.copyWith(appointments: currentAppointments);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final appointmentProvider =
    StateNotifierProvider<AppointmentNotifier, AppointmentState>(
  (ref) => AppointmentNotifier(),
);
