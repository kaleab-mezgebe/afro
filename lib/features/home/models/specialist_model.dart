class Specialist {
  final String id;
  final String name;
  final String price;
  final String image;
  final List<String> categories;
  final String gender;
  final double rating;

  Specialist({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.categories,
    required this.gender,
    required this.rating,
  });

  factory Specialist.fromMap(Map<String, dynamic> map) {
    return Specialist(
      id: map['id'] ?? map['name'],
      name: map['name'] ?? '',
      price: map['price'] ?? '',
      image: map['image'] ?? '',
      categories: List<String>.from(map['categories'] ?? []),
      gender: map['gender'] ?? 'all',
      rating: (map['rating'] ?? 0.0).toDouble(),
    );
  }
}
