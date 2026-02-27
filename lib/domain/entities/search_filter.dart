import 'package:equatable/equatable.dart';

class SearchFilter extends Equatable {
  final String? query;
  final String? category;
  final double? minRating;
  final double? maxPrice;
  final double? minPrice;
  final String? location;
  final DateTime? date;
  final List<String> services;

  const SearchFilter({
    this.query,
    this.category,
    this.minRating,
    this.maxPrice,
    this.minPrice,
    this.location,
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
      date == null &&
      services.isEmpty;

  bool get hasActiveFilters => 
      query != null ||
      category != null ||
      minRating != null ||
      maxPrice != null ||
      minPrice != null ||
      location != null ||
      date != null ||
      services.isNotEmpty;
}
