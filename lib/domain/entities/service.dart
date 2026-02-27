class Service {
  final String id;
  final String providerId;
  final String name;
  final int durationMinutes;
  final int priceCents;

  const Service({
    required this.id,
    required this.providerId,
    required this.name,
    required this.durationMinutes,
    required this.priceCents,
  });
}

