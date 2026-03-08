import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/appointment_analytics_models.dart';
import '../../../../core/di/injection_container.dart';

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
      // Format date for API
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      // Get shop ID from provider service (assuming first shop)
      final shops = await shopService.getShops();
      if (shops.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: 'No shop found. Please create a shop first.',
          appointments: [],
        );
        return;
      }

      final shopId = shops[0]['id'].toString();

      // Fetch appointments from API
      final response = await appointmentService.getShopAppointments(
        shopId,
        date: dateStr,
      );

      // Convert API response to Appointment models
      final appointments = response.map((json) {
        return Appointment(
          id: json['id'].toString(),
          customerId: json['customerId']?.toString() ?? '',
          staffId: json['staffId']?.toString() ?? '',
          shopId: json['shopId']?.toString() ?? '',
          bookingType: _parseBookingType(json['bookingType']),
          appointmentDateTime: DateTime.parse(json['appointmentDate']),
          duration: json['duration'] ?? 30,
          startTime: DateTime.parse(json['startTime']),
          endTime: DateTime.parse(json['endTime']),
          status: _parseStatus(json['status']),
          totalPrice: (json['totalPrice'] ?? 0).toDouble(),
          depositAmount: (json['depositAmount'] ?? 0).toDouble(),
          tipAmount: (json['tipAmount'] ?? 0).toDouble(),
          isNoShow: json['isNoShow'] ?? false,
          createdAt: DateTime.parse(json['createdAt']),
          updatedAt: DateTime.parse(json['updatedAt']),
          services: (json['services'] as List?)?.map((s) {
                return AppointmentService(
                  id: s['id'].toString(),
                  serviceId: s['serviceId'].toString(),
                  price: (s['price'] ?? 0).toDouble(),
                  duration: s['duration'] ?? 30,
                );
              }).toList() ??
              [],
        );
      }).toList();

      state = state.copyWith(
        isLoading: false,
        appointments: appointments,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  BookingType _parseBookingType(String? type) {
    switch (type?.toLowerCase()) {
      case 'online':
        return BookingType.online;
      case 'walkin':
      case 'walk_in':
        return BookingType.walkIn;
      default:
        return BookingType.online;
    }
  }

  AppointmentStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return AppointmentStatus.pending;
      case 'confirmed':
        return AppointmentStatus.confirmed;
      case 'in_progress':
        return AppointmentStatus.inProgress;
      case 'completed':
        return AppointmentStatus.completed;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      case 'no_show':
        return AppointmentStatus.noShow;
      default:
        return AppointmentStatus.pending;
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
