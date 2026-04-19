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
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Specialist',
      category:
          json['category']?.toString() ??
          (json['services'] is List && (json['services'] as List).isNotEmpty
              ? (json['services'] as List).first.toString()
              : 'Barber'),
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      location:
          json['location']?.toString() ?? json['address']?.toString() ?? '',
      services: json['services'] is List
          ? List<String>.from(json['services'])
          : [],
      minPrice: double.tryParse(json['minPrice']?.toString() ?? '0') ?? 0.0,
      maxPrice: double.tryParse(json['maxPrice']?.toString() ?? '0') ?? 0.0,
      imageUrl: json['imageUrl']?.toString() ?? json['image']?.toString(),
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
    // price comes as string "15.00" from the API
    final rawPrice = json['price'] ?? json['priceCents'] ?? 0;
    final priceDouble = double.tryParse(rawPrice.toString()) ?? 0.0;
    // if field is named priceCents it's already in cents, otherwise convert
    final priceCents =
        json.containsKey('priceCents') && !json.containsKey('price')
        ? (priceDouble).toInt()
        : (priceDouble * 100).toInt();

    return ServiceModel(
      id: json['id']?.toString() ?? '',
      providerId:
          json['barberId']?.toString() ?? json['providerId']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Service',
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 30,
      priceCents: priceCents,
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
