/// Predefined catalog of professional roles and their default services.
/// Used across the customer app for browsing, filtering, and booking.
class ProfessionalsCatalog {
  ProfessionalsCatalog._();

  static const List<ProfessionalType> all = [
    ProfessionalType(
      role: 'barber',
      displayName: 'Barber',
      emoji: '💇‍♂️',
      gender: 'men',
      services: [
        'Haircut',
        'Beard Trim',
        'Beard Shaping',
        'Clean Shave',
        'Line-up / Edge-up',
        'Hair Styling',
        'Hair Coloring',
        'Kids Haircut',
        'Head Massage',
      ],
    ),
    ProfessionalType(
      role: 'hair_stylist',
      displayName: 'Hair Stylist',
      emoji: '💇‍♀️',
      gender: 'women',
      services: [
        'Haircut',
        'Blow Dry',
        'Hair Styling',
        'Hair Coloring',
        'Highlights',
        'Balayage',
        'Hair Wash',
        'Hair Treatment',
        'Bridal Hairstyling',
      ],
    ),
    ProfessionalType(
      role: 'hair_color_specialist',
      displayName: 'Hair Color Specialist',
      emoji: '🎨',
      gender: 'unisex',
      services: [
        'Full Hair Coloring',
        'Root Touch-up',
        'Highlights',
        'Balayage / Ombre',
        'Color Correction',
        'Toner Application',
      ],
    ),
    ProfessionalType(
      role: 'nail_technician',
      displayName: 'Nail Technician',
      emoji: '💅',
      gender: 'unisex',
      services: [
        'Manicure',
        'Pedicure',
        'Gel Polish',
        'Acrylic Nails',
        'Nail Extensions',
        'Nail Art',
        'Nail Repair',
        'French Tips',
      ],
    ),
    ProfessionalType(
      role: 'makeup_artist',
      displayName: 'Makeup Artist',
      emoji: '💄',
      gender: 'unisex',
      services: [
        'Full Makeup',
        'Bridal Makeup',
        'Natural Makeup',
        'Party Makeup',
        'Makeup Consultation',
        'Touch-up Services',
      ],
    ),
    ProfessionalType(
      role: 'eyelash_technician',
      displayName: 'Eyelash Technician',
      emoji: '👁️',
      gender: 'unisex',
      services: [
        'Eyelash Extensions',
        'Lash Lift',
        'Lash Tint',
        'Lash Removal',
      ],
    ),
    ProfessionalType(
      role: 'brow_specialist',
      displayName: 'Brow Specialist',
      emoji: '🧵',
      gender: 'unisex',
      services: [
        'Eyebrow Shaping',
        'Threading',
        'Brow Tinting',
        'Brow Lamination',
      ],
    ),
    ProfessionalType(
      role: 'esthetician',
      displayName: 'Esthetician',
      emoji: '💆',
      gender: 'unisex',
      services: [
        'Facial',
        'Deep Cleansing Facial',
        'Acne Treatment',
        'Anti-aging Facial',
        'Skin Consultation',
        'Exfoliation / Peeling',
        'Blackhead Removal',
      ],
    ),
    ProfessionalType(
      role: 'massage_therapist',
      displayName: 'Massage Therapist',
      emoji: '💆‍♂️',
      gender: 'unisex',
      services: [
        'Full Body Massage',
        'Back Massage',
        'Head Massage',
        'Foot Massage',
        'Relaxation Massage',
        'Deep Tissue Massage',
      ],
    ),
    ProfessionalType(
      role: 'beard_specialist',
      displayName: 'Beard Specialist',
      emoji: '🪒',
      gender: 'men',
      services: [
        'Beard Styling',
        'Beard Coloring',
        'Beard Treatment',
        'Precision Shaping',
      ],
    ),
    ProfessionalType(
      role: 'waxing_specialist',
      displayName: 'Waxing Specialist',
      emoji: '🧼',
      gender: 'unisex',
      services: [
        'Full Body Waxing',
        'Arm Waxing',
        'Leg Waxing',
        'Facial Waxing',
        'Bikini Waxing',
      ],
    ),
    ProfessionalType(
      role: 'threading_specialist',
      displayName: 'Threading Specialist',
      emoji: '🧵',
      gender: 'unisex',
      services: [
        'Eyebrow Threading',
        'Upper Lip Threading',
        'Full Face Threading',
      ],
    ),
  ];

  /// Find a professional type by role key
  static ProfessionalType? byRole(String role) {
    try {
      return all.firstWhere((p) => p.role == role);
    } catch (_) {
      return null;
    }
  }

  /// Get all services for a given role
  static List<String> servicesFor(String role) {
    return byRole(role)?.services ?? [];
  }
}

class ProfessionalType {
  final String role;
  final String displayName;
  final String emoji;
  final String gender; // 'men' | 'women' | 'unisex'
  final List<String> services;

  const ProfessionalType({
    required this.role,
    required this.displayName,
    required this.emoji,
    required this.gender,
    required this.services,
  });
}
