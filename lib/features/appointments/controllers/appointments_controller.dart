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
      error.value = e.toString();
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
      error.value = e.toString();
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
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createNewBooking() async {
    if (selectedProvider.value == null ||
        selectedService.value == null ||
        selectedTimeSlot.value == null) {
      error.value = 'Please select provider, service, and time slot';
      return;
    }

    try {
      isLoading.value = true;
      error.value = '';
      
      final booking = await createBooking(
        provider: selectedProvider.value!,
        service: selectedService.value!,
        start: selectedTimeSlot.value!.start,
        end: selectedTimeSlot.value!.end,
      );

      bookings.insert(0, booking);
      
      // Reset selection
      selectedProvider.value = null;
      selectedService.value = null;
      selectedTimeSlot.value = null;
      services.clear();
      timeSlots.clear();

      Get.snackbar('Success', 'Booking confirmed successfully!');
      Get.offAllNamed(AppRoutes.bookingSuccess); 
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadBookingHistory() async {
    try {
      isLoading.value = true;
      error.value = '';
      final result = await getBookingHistory();
      // Sort: Upcoming (closest first) then Past (newest first)
      result.sort((a, b) => b.start.compareTo(a.start));
      bookings.value = result;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void selectProvider(Provider provider) {
    selectedProvider.value = provider;
    selectedService.value = null;
    selectedTimeSlot.value = null;
    services.clear();
    timeSlots.clear();
    loadServices(provider.id);
  }

  void startBookingFromPortfolio(Map<String, dynamic> specialist, [Map<String, dynamic>? service]) {
    // Clear previous state
    selectedProvider.value = null;
    selectedService.value = null;
    selectedTimeSlot.value = null;
    services.clear();
    timeSlots.clear();

    // Mapping logic
    final provider = Provider(
      id: specialist['id'] ?? 'unknown',
      name: specialist['name'] ?? 'Specialist',
      category: (specialist['categories'] as List?)?.first ?? 'Barber',
      rating: (specialist['rating'] as num?)?.toDouble() ?? 4.5,
      imageUrl: specialist['image'] ?? '',
      location: specialist['location'] ?? 'Unknown Location',
      services: (specialist['categories'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );

    selectedProvider.value = provider;

    if (service != null) {
      final serviceEntity = Service(
        id: service['id'] ?? service['name']?.toLowerCase()?.replaceAll(' ', '_') ?? 'service',
        providerId: provider.id,
        name: service['name'] ?? 'Service',
        priceCents: _parsePrice(service['price']),
        durationMinutes: _parseDuration(service['duration']),
      );
      selectedService.value = serviceEntity;
    }

    // Load full services list for this provider in background
    loadServices(provider.id);
    
    // Navigate to appropriate page
    if (selectedService.value != null) {
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
