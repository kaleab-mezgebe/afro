import '../../entities/booking.dart';
import '../../repositories/booking_repository.dart';

class GetBookingHistory {
  final BookingRepository repository;
  GetBookingHistory(this.repository);

  Future<List<Booking>> call() => repository.getMyBookings();
}

