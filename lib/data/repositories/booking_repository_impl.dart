import 'dart:convert';
import '../../domain/entities/booking.dart';
import '../../domain/entities/provider.dart';
import '../../domain/entities/service.dart';
import '../../domain/entities/time_slot.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/local/local_storage.dart';
import '../datasources/remote/api_client.dart';
import '../models/booking_model.dart';

class BookingRepositoryImpl implements BookingRepository {
  final ApiClient _apiClient;
  final LocalStorage _localStorage;

  BookingRepositoryImpl({
    required ApiClient apiClient,
    required LocalStorage localStorage,
  }) : _apiClient = apiClient,
       _localStorage = localStorage;

  @override
  Future<List<Provider>> getProviders() async {
    final response = await _apiClient.get('/barbers');
    final List<dynamic> data = response is List ? response : (response['data'] ?? response['barbers'] ?? []);

    return data
        .map((json) => ProviderModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Service>> getServices({required String providerId}) async {
    // In our backend, services might be part of the barber profile or a separate endpoint
    final response = await _apiClient.get('/services?barberId=$providerId');
    final List<dynamic> data = response is List ? response : (response['data'] ?? response['services'] ?? []);

    return data
        .map((json) => ServiceModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<TimeSlot>> getAvailability({
    required String providerId,
    required String serviceId,
    required DateTime date,
  }) async {
    final response = await _apiClient.get(
      '/appointments/availability?barberId=$providerId&serviceId=$serviceId&date=${date.toIso8601String().split('T')[0]}',
    );
    final List<dynamic> data = response is List ? response : (response['data'] ?? response['timeSlots'] ?? []);

    return data
        .map((json) => TimeSlotModel.fromJson(json as Map<String, dynamic>))
        .map(
          (model) => TimeSlot(
            start: model.start,
            end: model.end,
            isAvailable: model.isAvailable,
          ),
        )
        .toList();
  }

  @override
  Future<Booking> createBooking({
    required Provider provider,
    required Service service,
    required DateTime start,
    required DateTime end,
  }) async {
    final response = await _apiClient.post('/appointments', {
      'barberId': provider.id,
      'serviceId': service.id,
      'appointmentDate': start.toIso8601String(),
      'status': 'pending',
    });

    final booking = BookingModel.fromJson(
      response.containsKey('data')
          ? response['data'] as Map<String, dynamic>
          : response,
    );

    // Save to local storage
    await _saveBookingToLocalStorage(booking);

    return booking;
  }

  @override
  Future<List<Booking>> getMyBookings() async {
    try {
      final response = await _apiClient.get('/appointments/my');
      final List<dynamic> data = response is List ? response : (response['data'] ?? response['appointments'] ?? []);

      final bookings = data
          .map((json) => BookingModel.fromJson(json as Map<String, dynamic>))
          .toList();

      // Update local storage with latest data
      for (var booking in bookings) {
        await _saveBookingToLocalStorage(booking);
      }

      return bookings;
    } catch (e) {
      // Return cached bookings if API fails
      return await _getBookingsFromLocalStorage();
    }
  }

  Future<void> _saveBookingToLocalStorage(BookingModel booking) async {
    final existingBookings = await _getBookingsFromLocalStorage();

    // Remove existing booking with same ID if present
    existingBookings.removeWhere((b) => b.id == booking.id);
    existingBookings.add(booking);

    final bookingsJson = existingBookings
        .map((b) => (b as BookingModel).toJson())
        .toList();
    await _localStorage.save('my_bookings', jsonEncode(bookingsJson));
  }

  Future<List<Booking>> _getBookingsFromLocalStorage() async {
    final bookingsString = await _localStorage.get('my_bookings');
    if (bookingsString != null) {
      try {
        final List<dynamic> bookingsJson = jsonDecode(bookingsString);
        return bookingsJson
            .map((json) => BookingModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (e) {
        // Return empty list if parsing fails
        return [];
      }
    }
    return [];
  }
}
