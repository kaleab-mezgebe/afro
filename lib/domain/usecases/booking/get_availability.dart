import '../../entities/time_slot.dart';
import '../../repositories/booking_repository.dart';

class GetAvailability {
  final BookingRepository repository;
  GetAvailability(this.repository);

  Future<List<TimeSlot>> call({
    required String providerId,
    required String serviceId,
    required DateTime date,
  }) {
    return repository.getAvailability(
      providerId: providerId,
      serviceId: serviceId,
      date: date,
    );
  }
}

