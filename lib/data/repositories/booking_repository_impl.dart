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
    try {
      final response = await _apiClient.get('/providers');
      final List<dynamic> data = response['providers'] ?? [];

      return data
          .map((json) => ProviderModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Fallback to mock data for demo purposes
      return _getMockProviders();
    }
  }

  @override
  Future<List<Service>> getServices({required String providerId}) async {
    try {
      final response = await _apiClient.get('/providers/$providerId/services');
      final List<dynamic> data = response['services'] ?? [];

      return data
          .map((json) => ServiceModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Fallback to mock data for demo purposes
      return _getMockServices(providerId);
    }
  }

  @override
  Future<List<TimeSlot>> getAvailability({
    required String providerId,
    required String serviceId,
    required DateTime date,
  }) async {
    try {
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
    } catch (e) {
      // Fallback to mock data for demo purposes
      return _getMockTimeSlots(date);
    }
  }

  @override
  Future<Booking> createBooking({
    required Provider provider,
    required Service service,
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final response = await _apiClient.post('/bookings', {
        'providerId': provider.id,
        'serviceId': service.id,
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
      });

      return BookingModel.fromJson(response);
    } catch (e) {
      // Fallback to mock booking for demo purposes
      final mockBooking = BookingModel(
        id: 'booking_${DateTime.now().millisecondsSinceEpoch}',
        provider: provider as ProviderModel,
        service: service as ServiceModel,
        start: start,
        end: end,
        status: BookingStatus.confirmed,
        totalPriceCents: service.priceCents,
      );

      // Save to local storage
      await _saveBookingToLocalStorage(mockBooking);

      return mockBooking;
    }
  }

  @override
  Future<List<Booking>> getMyBookings() async {
    try {
      final response = await _apiClient.get('/my-bookings');
      final List<dynamic> data = response['bookings'] ?? [];

      return data
          .map((json) => BookingModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Fallback to local storage for demo purposes
      return _getBookingsFromLocalStorage();
    }
  }

  Future<void> _saveBookingToLocalStorage(BookingModel booking) async {
    final existingBookings = await _getBookingsFromLocalStorage();
    existingBookings.add(booking);

    final bookingsJson = existingBookings
        .map((b) => (b as BookingModel).toJson())
        .toList();
    await _localStorage.save('my_bookings', jsonEncode(bookingsJson));
  }

  Future<List<Booking>> _getBookingsFromLocalStorage() async {
    final bookingsString = await _localStorage.get('my_bookings');
    if (bookingsString != null) {
      final List<dynamic> bookingsJson = jsonDecode(bookingsString);
      return bookingsJson
          .map((json) => BookingModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  List<Provider> _getMockProviders() {
    return [
      const ProviderModel(
        id: '1',
        name: 'Afro Cuts Salon',
        category: 'salon',
        rating: 4.8,
        location: 'Nairobi CBD',
        imageUrl: null,
      ),
      const ProviderModel(
        id: '2',
        name: 'Barber Joe',
        category: 'barber',
        rating: 4.9,
        location: 'Westlands',
        imageUrl: null,
      ),
      const ProviderModel(
        id: '3',
        name: 'Style Studio',
        category: 'salon',
        rating: 4.7,
        location: 'Kilimani',
        imageUrl: null,
      ),
    ];
  }

  List<Service> _getMockServices(String providerId) {
    return [
      ServiceModel(
        id: '1',
        providerId: providerId,
        name: 'Haircut',
        durationMinutes: 30,
        priceCents: 2500,
      ),
      ServiceModel(
        id: '2',
        providerId: providerId,
        name: 'Beard Trim',
        durationMinutes: 15,
        priceCents: 1500,
      ),
      ServiceModel(
        id: '3',
        providerId: providerId,
        name: 'Hair & Beard',
        durationMinutes: 45,
        priceCents: 3500,
      ),
    ];
  }

  List<TimeSlot> _getMockTimeSlots(DateTime date) {
    final timeSlots = <TimeSlot>[];
    final now = DateTime.now();

    for (int hour = 9; hour <= 17; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        final start = DateTime(date.year, date.month, date.day, hour, minute);
        final end = start.add(const Duration(minutes: 30));

        if (start.isAfter(now)) {
          timeSlots.add(
            TimeSlot(
              start: start,
              end: end,
              isAvailable: hour != 12, // Make 12:00 unavailable for demo
            ),
          );
        }
      }
    }

    return timeSlots;
  }
}
