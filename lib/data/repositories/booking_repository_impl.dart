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
    final response = await _apiClient.get('/providers');
    final List<dynamic> data = response['providers'] ?? [];

    return data
        .map((json) => ProviderModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Service>> getServices({required String providerId}) async {
    final response = await _apiClient.get('/providers/$providerId/services');
    final List<dynamic> data = response['services'] ?? [];

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
      '/providers/$providerId/availability?date=${date.toIso8601String()}',
    );
    final List<dynamic> data = response['timeSlots'] ?? [];

    final timeSlotModels = data
        .map((json) => TimeSlotModel.fromJson(json as Map<String, dynamic>))
        .toList();

    return timeSlotModels
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
    final response = await _apiClient.post('/bookings', {
      'providerId': provider.id,
      'serviceId': service.id,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
    });

    final booking = BookingModel.fromJson(response);

    // Save to local storage for offline access
    await _saveBookingToLocalStorage(booking);

    return booking;
  }

  @override
  Future<List<Booking>> getMyBookings() async {
    try {
      final response = await _apiClient.get('/my-bookings');
      final List<dynamic> data = response['bookings'] ?? [];

      final bookings = data
          .map((json) => BookingModel.fromJson(json as Map<String, dynamic>))
          .toList();

      // Update local storage with latest data
      for (var booking in bookings) {
        await _saveBookingToLocalStorage(booking as BookingModel);
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
