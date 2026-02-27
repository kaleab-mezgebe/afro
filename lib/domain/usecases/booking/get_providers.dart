import '../../entities/provider.dart';
import '../../repositories/booking_repository.dart';

class GetProviders {
  final BookingRepository repository;
  GetProviders(this.repository);

  Future<List<Provider>> call() => repository.getProviders();
}

