import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../../../domain/entities/booking.dart';
import '../../../domain/entities/provider.dart';
import '../../../domain/entities/service.dart';
import '../../../domain/entities/time_slot.dart';
import '../../../domain/usecases/booking/create_booking.dart';
import '../../../domain/usecases/booking/get_availability.dart';
import '../../../domain/usecases/booking/get_booking_history.dart';
import '../../../domain/usecases/booking/get_providers.dart';
import '../../../domain/usecases/booking/get_services.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/services/appointment_api_service.dart';

class AppointmentsController extends GetxController {
  final GetProviders getProviders;
  final GetServices getServices;
  final GetAvailability getAvailability;
  final CreateBooking createBooking;
  final GetBookingHistory getBookingHistory;

  // State
  final RxList<Provider> providers = <Provider>[].obs;
  final RxList<Service> services = <Service>[].obs;
  final RxList<TimeSlot> timeSlots = <TimeSlot>[].obs;
  final RxList<Booking> bookings = <Booking>[].obs;

  final Rx<Provider?> selectedProvider = Rx<Provider?>(null);
  final Rx<Service?> selectedService = Rx<Service?>(null);
  final Rx<TimeSlot?> selectedTimeSlot = Rx<TimeSlot?>(null);
  final Rx<DateTime> selectedDate = Rx<DateTime>(DateTime.now());

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxString selectedPaymentMethod = 'cash'.obs;

  AppointmentsController({
    required this.getProviders,
    required this.getServices,
    required this.getAvailability,
    required this.createBooking,
    required this.getBookingHistory,
  });

  @override
  void onInit() {
    super.onInit();
    loadProviders();
    loadBookingHistory();
  }

  Future<void> loadProviders() async {
    try {
      isLoading.value = true;
      error.value = '';
      final result = await getProviders();
      providers.value = result;
    } catch (e) {
      error.value = ErrorHandler.getErrorMessage(e);
      ErrorHandler.handleError(e, onRetry: loadProviders);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadServices(String providerId) async {
    try {
      isLoading.value = true;
      error.value = '';
      final result = await getServices(providerId: providerId);
      services.value = result;
    } catch (e) {
      error.value = ErrorHandler.getErrorMessage(e);
      ErrorHandler.handleError(e, onRetry: () => loadServices(providerId));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAvailability({
    required String providerId,
    required String serviceId,
    required DateTime date,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';
      final result = await getAvailability(
        providerId: providerId,
        serviceId: serviceId,
        date: date,
      );
      timeSlots.value = result;
    } catch (e) {
      error.value = ErrorHandler.getErrorMessage(e);
      ErrorHandler.handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createNewBooking() async {
    if (selectedProvider.value == null ||
        selectedService.value == null ||
        selectedTimeSlot.value == null) {
      ErrorHandler.showErrorSnackbar(
        'Please select provider, service, and time slot',
      );
      return;
    }

    try {
      isLoading.value = true;
      error.value = '';

      // Use AppointmentApiService (EnhancedApiClient) which properly attaches auth token
      final appointmentApiService = Get.find<AppointmentApiService>();
      await appointmentApiService.createAppointment(
        barberId: selectedProvider.value!.id,
        serviceId: selectedService.value!.id,
        appointmentDate: selectedTimeSlot.value!.start,
      );

      // Reset selection
      selectedProvider.value = null;
      selectedService.value = null;
      selectedServices.clear();
      selectedTimeSlot.value = null;
      selectedPaymentMethod.value = 'cash';
      services.clear();
      timeSlots.clear();

      Get.offAllNamed(AppRoutes.bookingSuccess);
    } catch (e) {
      error.value = ErrorHandler.getErrorMessage(e);
      ErrorHandler.handleError(e, onRetry: createNewBooking);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadBookingHistory() async {
    try {
      isLoading.value = true;
      error.value = '';

      // Use AppointmentApiService (EnhancedApiClient) — has proper auth token
      final appointmentApiService = Get.find<AppointmentApiService>();
      final rawList = await appointmentApiService.getMyAppointments();

      final parsed = rawList.map((json) {
        final map = json as Map<String, dynamic>;
        return _bookingFromMap(map);
      }).toList();

      parsed.sort((a, b) => b.start.compareTo(a.start));
      bookings.value = parsed;
    } catch (e) {
      error.value = ErrorHandler.getErrorMessage(e);
      // Don't show snackbar for history load — just show error state in UI
    } finally {
      isLoading.value = false;
    }
  }

  Booking _bookingFromMap(Map<String, dynamic> json) {
    final providerRaw = json['provider'];
    final serviceRaw = json['service'];

    final provider = providerRaw is Map<String, dynamic>
        ? Provider(
            id: providerRaw['id']?.toString() ?? '',
            name: providerRaw['name']?.toString() ?? 'Specialist',
            category: providerRaw['category']?.toString() ?? 'Beauty',
            rating: (providerRaw['rating'] as num?)?.toDouble() ?? 0.0,
            location: providerRaw['location']?.toString() ?? '',
            imageUrl: providerRaw['imageUrl']?.toString(),
          )
        : Provider(
            id: json['barberId']?.toString() ?? '',
            name: json['barberName']?.toString() ?? 'Specialist',
            category: json['serviceType']?.toString() ?? 'Beauty',
            rating: 0.0,
            location: '',
          );

    final service = serviceRaw is Map<String, dynamic>
        ? Service(
            id: serviceRaw['id']?.toString() ?? '',
            providerId: serviceRaw['providerId']?.toString() ?? '',
            name: serviceRaw['name']?.toString() ?? 'Service',
            durationMinutes:
                (serviceRaw['durationMinutes'] as num?)?.toInt() ?? 30,
            priceCents: (serviceRaw['priceCents'] as num?)?.toInt() ?? 0,
          )
        : Service(
            id: json['serviceType']?.toString() ?? 'unknown',
            providerId: json['barberId']?.toString() ?? '',
            name: json['serviceType']?.toString() ?? 'Service',
            durationMinutes: 30,
            priceCents: 0,
          );

    final startRaw = json['start'] ?? json['appointmentDate'];
    final start = startRaw != null
        ? DateTime.parse(startRaw.toString())
        : DateTime.now();
    final endRaw = json['end'];
    final end = endRaw != null
        ? DateTime.parse(endRaw.toString())
        : start.add(const Duration(minutes: 30));

    final statusStr = json['status']?.toString() ?? 'pending';
    final status = BookingStatus.values.firstWhere(
      (e) => e.name == statusStr,
      orElse: () => BookingStatus.pending,
    );

    return Booking(
      id: json['id']?.toString() ?? '',
      provider: provider,
      service: service,
      start: start,
      end: end,
      status: status,
      totalPriceCents: (json['totalPriceCents'] as num?)?.toInt() ?? 0,
    );
  }

  void selectProvider(Provider provider) {
    selectedProvider.value = provider;
    selectedService.value = null;
    selectedTimeSlot.value = null;
    services.clear();
    timeSlots.clear();
    loadServices(provider.id);
  }

  // Holds multiple selected services from portfolio
  final RxList<Service> selectedServices = <Service>[].obs;

  void startBookingFromPortfolio(
    Map<String, dynamic> specialist, [
    List<Map<String, dynamic>>? serviceList,
  ]) {
    // Clear previous state
    selectedProvider.value = null;
    selectedService.value = null;
    selectedServices.clear();
    selectedTimeSlot.value = null;
    services.clear();
    timeSlots.clear();

    final provider = Provider(
      id: specialist['id'] ?? 'unknown',
      name: specialist['name'] ?? 'Specialist',
      category: (specialist['categories'] as List?)?.first ?? 'Barber',
      rating: (specialist['rating'] as num?)?.toDouble() ?? 4.5,
      imageUrl: specialist['image'] ?? '',
      location: specialist['location'] ?? 'Unknown Location',
      services:
          (specialist['categories'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );

    selectedProvider.value = provider;

    if (serviceList != null && serviceList.isNotEmpty) {
      final mapped = serviceList
          .map(
            (s) => Service(
              id:
                  s['id'] ??
                  s['name']?.toString().toLowerCase().replaceAll(' ', '_') ??
                  'service',
              providerId: provider.id,
              name: s['name'] ?? 'Service',
              priceCents: _parsePrice(s['price']),
              durationMinutes: _parseDuration(
                s['durationMinutes'] ?? s['duration'],
              ),
            ),
          )
          .toList();

      selectedServices.assignAll(mapped);
      // Set primary service to first selected for backward compat
      selectedService.value = mapped.first;
    }

    loadServices(provider.id);

    if (selectedService.value != null) {
      // Pre-load availability then go to time picker
      loadAvailability(
        providerId: provider.id,
        serviceId: selectedService.value!.id,
        date: selectedDate.value,
      );
      Get.toNamed(AppRoutes.bookingTime);
    } else {
      Get.toNamed(AppRoutes.bookingService);
    }
  }

  int _parsePrice(dynamic price) {
    if (price == null) return 0;
    if (price is int) return price;
    final String s = price.toString().replaceAll(RegExp(r'[^0-9.]'), '');
    return ((double.tryParse(s) ?? 0) * 100).toInt();
  }

  int _parseDuration(dynamic duration) {
    if (duration == null) return 30;
    if (duration is int) return duration;
    final String s = duration.toString().replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(s) ?? 30;
  }

  void selectService(Service service) {
    selectedService.value = service;
    selectedTimeSlot.value = null;
    timeSlots.clear();
    if (selectedProvider.value != null) {
      loadAvailability(
        providerId: selectedProvider.value!.id,
        serviceId: service.id,
        date: selectedDate.value,
      );
    }
  }

  void selectTimeSlot(TimeSlot timeSlot) {
    selectedTimeSlot.value = timeSlot;
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
    selectedTimeSlot.value = null;
    timeSlots.clear();
    if (selectedProvider.value != null && selectedService.value != null) {
      loadAvailability(
        providerId: selectedProvider.value!.id,
        serviceId: selectedService.value!.id,
        date: date,
      );
    }
  }

  void clearError() {
    error.value = '';
  }
}
