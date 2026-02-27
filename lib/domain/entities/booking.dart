import 'provider.dart';
import 'service.dart';

enum BookingStatus { pending, confirmed, cancelled, completed }

class Booking {
  final String id;
  final Provider provider;
  final Service service;
  final DateTime start;
  final DateTime end;
  final BookingStatus status;
  final int totalPriceCents;

  const Booking({
    required this.id,
    required this.provider,
    required this.service,
    required this.start,
    required this.end,
    required this.status,
    required this.totalPriceCents,
  });
}

