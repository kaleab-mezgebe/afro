import '../../domain/entities/booking.dart';
import '../../domain/entities/provider.dart';
import '../../domain/entities/service.dart';

class BookingModel extends Booking {
  const BookingModel({
    required super.id,
    required super.provider,
    required super.service,
    required super.start,
    required super.end,
    required super.status,
    required super.totalPriceCents,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      provider: ProviderModel.fromJson(
        json['provider'] as Map<String, dynamic>,
      ),
      service: ServiceModel.fromJson(json['service'] as Map<String, dynamic>),
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
      status: BookingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BookingStatus.pending,
      ),
      totalPriceCents: json['totalPriceCents'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider': (provider as ProviderModel).toJson(),
      'service': (service as ServiceModel).toJson(),
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'status': status.name,
      'totalPriceCents': totalPriceCents,
    };
  }
}

class ProviderModel extends Provider {
  const ProviderModel({
    required super.id,
    required super.name,
    required super.category,
    required super.rating,
    required super.location,
    super.services = const [],
    super.minPrice = 0.0,
    super.maxPrice = 0.0,
    super.imageUrl,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    return ProviderModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      rating: (json['rating'] as num).toDouble(),
      location: json['location'] as String? ?? '',
      services: List<String>.from(json['services'] ?? []),
      minPrice: (json['minPrice'] ?? 0.0).toDouble(),
      maxPrice: (json['maxPrice'] ?? 0.0).toDouble(),
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'rating': rating,
      'location': location,
      'services': services,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'imageUrl': imageUrl,
    };
  }
}

class ServiceModel extends Service {
  const ServiceModel({
    required super.id,
    required super.providerId,
    required super.name,
    required super.durationMinutes,
    required super.priceCents,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String,
      providerId: json['providerId'] as String,
      name: json['name'] as String,
      durationMinutes: json['durationMinutes'] as int,
      priceCents: json['priceCents'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'providerId': providerId,
      'name': name,
      'durationMinutes': durationMinutes,
      'priceCents': priceCents,
    };
  }
}

class TimeSlotModel {
  final DateTime start;
  final DateTime end;
  final bool isAvailable;

  const TimeSlotModel({
    required this.start,
    required this.end,
    required this.isAvailable,
  });

  factory TimeSlotModel.fromJson(Map<String, dynamic> json) {
    return TimeSlotModel(
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
      isAvailable: json['isAvailable'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'isAvailable': isAvailable,
    };
  }
}
