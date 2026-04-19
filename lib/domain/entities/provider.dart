class Provider {
  final String id;
  final String name;
  final String category;
  final double rating;
  final String location;
  final List<String> services;
  final double minPrice;
  final double maxPrice;
  final String? imageUrl;
  final bool? isFeatured;
  final bool? isVerified;
  final String? gender;
  final int? reviewCount;
  final double? latitude;
  final double? longitude;

  const Provider({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.location,
    this.services = const [],
    this.minPrice = 0.0,
    this.maxPrice = 0.0,
    this.imageUrl,
    this.isFeatured,
    this.isVerified,
    this.gender,
    this.reviewCount,
    this.latitude,
    this.longitude,
  });
}
