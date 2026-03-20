import 'package:equatable/equatable.dart';

class SearchFilter extends Equatable {
  final String? query;
  final String? category;
  final double? minRating;
  final double? maxPrice;
  final double? minPrice;
  final String? location;
  final double? latitude;
  final double? longitude;
  final double? radius;
  final DateTime? date;
  final List<String> services;

  const SearchFilter({
    this.query,
    this.category,
    this.minRating,
    this.maxPrice,
    this.minPrice,
    this.location,
    this.latitude,
    this.longitude,
    this.radius,
    this.date,
    this.services = const [],
  });

  @override
  List<Object?> get props => [
        query,
        category,
        minRating,
        maxPrice,
        minPrice,
        location,
        latitude,
        longitude,
        radius,
        date,
        services,
      ];

  SearchFilter copyWith({
    String? query,
    String? category,
    double? minRating,
    double? maxPrice,
    double? minPrice,
    String? location,
    double? latitude,
    double? longitude,
    double? radius,
    DateTime? date,
    List<String>? services,
  }) {
    return SearchFilter(
      query: query ?? this.query,
      category: category ?? this.category,
      minRating: minRating ?? this.minRating,
      maxPrice: maxPrice ?? this.maxPrice,
      minPrice: minPrice ?? this.minPrice,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radius: radius ?? this.radius,
      date: date ?? this.date,
      services: services ?? this.services,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'category': category,
      'minRating': minRating,
      'maxPrice': maxPrice,
      'minPrice': minPrice,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'date': date?.toIso8601String(),
      'services': services,
    };
  }

  bool get isEmpty => 
      query == null &&
      category == null &&
      minRating == null &&
      maxPrice == null &&
      minPrice == null &&
      location == null &&
      latitude == null &&
      longitude == null &&
      radius == null &&
      date == null &&
      services.isEmpty;

  bool get hasActiveFilters => 
      query != null ||
      category != null ||
      minRating != null ||
      maxPrice != null ||
      minPrice != null ||
      location != null ||
      latitude != null ||
      longitude != null ||
      radius != null ||
      date != null ||
      services.isNotEmpty;
}
