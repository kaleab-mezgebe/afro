import '../../entities/booking.dart';
import '../../entities/provider.dart';
import '../../entities/service.dart';
import '../../repositories/booking_repository.dart';

class CreateBooking {
  final BookingRepository repository;
  CreateBooking(this.repository);

  Future<Booking> call({
    required Provider provider,
    required Service service,
    required DateTime start,
    required DateTime end,
  }) {
    return repository.createBooking(
      provider: provider,
      service: service,
      start: start,
      end: end,
    );
  }
}

