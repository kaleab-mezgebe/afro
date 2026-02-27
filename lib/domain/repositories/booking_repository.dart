import '../entities/booking.dart';
import '../entities/provider.dart';
import '../entities/service.dart';
import '../entities/time_slot.dart';

abstract class BookingRepository {
  Future<List<Provider>> getProviders();
  Future<List<Service>> getServices({required String providerId});

  Future<List<TimeSlot>> getAvailability({
    required String providerId,
    required String serviceId,
    required DateTime date,
  });

  Future<Booking> createBooking({
    required Provider provider,
    required Service service,
    required DateTime start,
    required DateTime end,
  });

  Future<List<Booking>> getMyBookings();
}

