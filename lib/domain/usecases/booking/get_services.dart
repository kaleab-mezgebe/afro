import '../../entities/service.dart';
import '../../repositories/booking_repository.dart';

class GetServices {
  final BookingRepository repository;
  GetServices(this.repository);

  Future<List<Service>> call({required String providerId}) {
    return repository.getServices(providerId: providerId);
  }
}

