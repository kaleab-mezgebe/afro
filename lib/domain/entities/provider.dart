class Provider {
  final String id;
  final String name;
  final String category; // barber | salon
  final double rating;
  final String? imageUrl;

  const Provider({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    this.imageUrl,
  });
}

