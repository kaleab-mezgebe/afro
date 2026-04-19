import 'package:equatable/equatable.dart';
import 'provider_models.dart';

// Staff Models
class Staff extends Equatable {
  final String id;
  final String shopId;
  final String? branchId;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phoneNumber;
  final String? profileImage;
  final StaffRole role;
  final StaffStatus status;
  final String? bio;
  final List<String> specialties;
  final int experience;
  final double rating;
  final int totalReviews;
  final double? commissionRate;
  final double baseSalary;
  final StaffPermissions? permissions;
  final WorkingHours? workingHours;
  final List<VacationDay> vacationDays;
  final List<String> services;
  final bool canAcceptOnlineBookings;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Staff({
    required this.id,
    required this.shopId,
    this.branchId,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phoneNumber,
    this.profileImage,
    required this.role,
    required this.status,
    this.bio,
    this.specialties = const [],
    required this.experience,
    required this.rating,
    required this.totalReviews,
    this.commissionRate,
    required this.baseSalary,
    this.permissions,
    this.workingHours,
    this.vacationDays = const [],
    this.services = const [],
    required this.canAcceptOnlineBookings,
    required this.isFeatured,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        shopId,
        branchId,
        firstName,
        lastName,
        email,
        phoneNumber,
        profileImage,
        role,
        status,
        bio,
        specialties,
        experience,
        rating,
        totalReviews,
        commissionRate,
        baseSalary,
        permissions,
        workingHours,
        vacationDays,
        services,
        canAcceptOnlineBookings,
        isFeatured,
        createdAt,
        updatedAt
      ];
}

enum StaffRole {
  barber('barber'),
  hairStylist('hair_stylist'),
  hairColorSpecialist('hair_color_specialist'),
  nailTechnician('nail_technician'),
  makeupArtist('makeup_artist'),
  eyelashTechnician('eyelash_technician'),
  browSpecialist('brow_specialist'),
  esthetician('esthetician'),
  massageTherapist('massage_therapist'),
  beardSpecialist('beard_specialist'),
  waxingSpecialist('waxing_specialist'),
  threadingSpecialist('threading_specialist'),
  receptionist('receptionist'),
  manager('manager'),
  owner('owner');

  const StaffRole(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case StaffRole.barber:
        return 'Barber';
      case StaffRole.hairStylist:
        return 'Hair Stylist';
      case StaffRole.hairColorSpecialist:
        return 'Hair Color Specialist';
      case StaffRole.nailTechnician:
        return 'Nail Technician';
      case StaffRole.makeupArtist:
        return 'Makeup Artist';
      case StaffRole.eyelashTechnician:
        return 'Eyelash Technician';
      case StaffRole.browSpecialist:
        return 'Brow Specialist';
      case StaffRole.esthetician:
        return 'Esthetician';
      case StaffRole.massageTherapist:
        return 'Massage Therapist';
      case StaffRole.beardSpecialist:
        return 'Beard Specialist';
      case StaffRole.waxingSpecialist:
        return 'Waxing Specialist';
      case StaffRole.threadingSpecialist:
        return 'Threading Specialist';
      case StaffRole.receptionist:
        return 'Receptionist';
      case StaffRole.manager:
        return 'Manager';
      case StaffRole.owner:
        return 'Owner';
    }
  }

  /// Returns the default services for this professional role
  List<String> get defaultServices {
    switch (this) {
      case StaffRole.barber:
        return [
          'Haircut',
          'Beard Trim',
          'Beard Shaping',
          'Clean Shave',
          'Line-up / Edge-up',
          'Hair Styling',
          'Hair Coloring',
          'Kids Haircut',
          'Head Massage'
        ];
      case StaffRole.hairStylist:
        return [
          'Haircut',
          'Blow Dry',
          'Hair Styling',
          'Hair Coloring',
          'Highlights',
          'Balayage',
          'Hair Wash',
          'Hair Treatment',
          'Bridal Hairstyling'
        ];
      case StaffRole.hairColorSpecialist:
        return [
          'Full Hair Coloring',
          'Root Touch-up',
          'Highlights',
          'Balayage / Ombre',
          'Color Correction',
          'Toner Application'
        ];
      case StaffRole.nailTechnician:
        return [
          'Manicure',
          'Pedicure',
          'Gel Polish',
          'Acrylic Nails',
          'Nail Extensions',
          'Nail Art',
          'Nail Repair',
          'French Tips'
        ];
      case StaffRole.makeupArtist:
        return [
          'Full Makeup',
          'Bridal Makeup',
          'Natural Makeup',
          'Party Makeup',
          'Makeup Consultation',
          'Touch-up Services'
        ];
      case StaffRole.eyelashTechnician:
        return ['Eyelash Extensions', 'Lash Lift', 'Lash Tint', 'Lash Removal'];
      case StaffRole.browSpecialist:
        return [
          'Eyebrow Shaping',
          'Threading',
          'Brow Tinting',
          'Brow Lamination'
        ];
      case StaffRole.esthetician:
        return [
          'Facial',
          'Deep Cleansing Facial',
          'Acne Treatment',
          'Anti-aging Facial',
          'Skin Consultation',
          'Exfoliation / Peeling',
          'Blackhead Removal'
        ];
      case StaffRole.massageTherapist:
        return [
          'Full Body Massage',
          'Back Massage',
          'Head Massage',
          'Foot Massage',
          'Relaxation Massage',
          'Deep Tissue Massage'
        ];
      case StaffRole.beardSpecialist:
        return [
          'Beard Styling',
          'Beard Coloring',
          'Beard Treatment',
          'Precision Shaping'
        ];
      case StaffRole.waxingSpecialist:
        return [
          'Full Body Waxing',
          'Arm Waxing',
          'Leg Waxing',
          'Facial Waxing',
          'Bikini Waxing'
        ];
      case StaffRole.threadingSpecialist:
        return [
          'Eyebrow Threading',
          'Upper Lip Threading',
          'Full Face Threading'
        ];
      default:
        return [];
    }
  }
}

enum StaffStatus {
  active('active'),
  inactive('inactive'),
  onLeave('on_leave'),
  terminated('terminated');

  const StaffStatus(this.value);
  final String value;
}

class StaffPermissions extends Equatable {
  final bool canViewSchedule;
  final bool canManageBookings;
  final bool canEditServices;
  final bool canViewAnalytics;
  final bool canManageStaff;
  final bool canManageCustomers;

  const StaffPermissions({
    required this.canViewSchedule,
    required this.canManageBookings,
    required this.canEditServices,
    required this.canViewAnalytics,
    required this.canManageStaff,
    required this.canManageCustomers,
  });

  @override
  List<Object?> get props => [
        canViewSchedule,
        canManageBookings,
        canEditServices,
        canViewAnalytics,
        canManageStaff,
        canManageCustomers
      ];
}

class VacationDay extends Equatable {
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final bool approved;
  final String? approvedBy;

  const VacationDay({
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.approved,
    this.approvedBy,
  });

  @override
  List<Object?> get props => [startDate, endDate, reason, approved, approvedBy];
}

// Service Models
class Service extends Equatable {
  final String id;
  final String shopId;
  final String name;
  final ServiceCategory category;
  final String? description;
  final String? image;
  final double basePrice;
  final int duration;
  final ServiceStatus status;
  final bool isVariantBased;
  final List<ServiceVariant> variants;
  final List<ServiceAddOn> addOns;
  final List<DynamicPricing> dynamicPricing;
  final ServiceRequirements? requirements;
  final List<String> aftercareInstructions;
  final List<FAQ> faqs;
  final int popularityScore;
  final int totalBookings;
  final double averageRating;
  final int totalReviews;
  final List<String> staffIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Service({
    required this.id,
    required this.shopId,
    required this.name,
    required this.category,
    this.description,
    this.image,
    required this.basePrice,
    required this.duration,
    required this.status,
    required this.isVariantBased,
    this.variants = const [],
    this.addOns = const [],
    this.dynamicPricing = const [],
    this.requirements,
    this.aftercareInstructions = const [],
    this.faqs = const [],
    required this.popularityScore,
    required this.totalBookings,
    required this.averageRating,
    required this.totalReviews,
    this.staffIds = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        shopId,
        name,
        category,
        description,
        image,
        basePrice,
        duration,
        status,
        isVariantBased,
        variants,
        addOns,
        dynamicPricing,
        requirements,
        aftercareInstructions,
        faqs,
        popularityScore,
        totalBookings,
        averageRating,
        totalReviews,
        staffIds,
        createdAt,
        updatedAt
      ];
}

enum ServiceCategory {
  // Hair
  haircut('haircut'),
  beardTrim('beard_trim'),
  hairColoring('hair_coloring'),
  hairStyling('hair_styling'),
  hairTreatment('hair_treatment'),
  highlights('highlights'),
  balayage('balayage'),
  rootTouchUp('root_touch_up'),
  colorCorrection('color_correction'),
  blowDry('blow_dry'),
  bridalHair('bridal_hair'),
  // Beard
  beardShaping('beard_shaping'),
  cleanShave('clean_shave'),
  lineUp('line_up'),
  beardColoring('beard_coloring'),
  beardTreatment('beard_treatment'),
  // Nails
  manicure('manicure'),
  pedicure('pedicure'),
  gelPolish('gel_polish'),
  acrylicNails('acrylic_nails'),
  nailExtensions('nail_extensions'),
  nailArt('nail_art'),
  nailRepair('nail_repair'),
  nailCare('nail_care'),
  // Makeup
  makeup('makeup'),
  bridalMakeup('bridal_makeup'),
  partyMakeup('party_makeup'),
  naturalMakeup('natural_makeup'),
  makeupConsultation('makeup_consultation'),
  // Lashes & Brows
  eyelashExtensions('eyelash_extensions'),
  lashLift('lash_lift'),
  lashTint('lash_tint'),
  lashRemoval('lash_removal'),
  eyebrowShaping('eyebrow_shaping'),
  threading('threading'),
  browTinting('brow_tinting'),
  browLamination('brow_lamination'),
  // Skin
  facial('facial'),
  skinCare('skin_care'),
  acneTreatment('acne_treatment'),
  antiAgingFacial('anti_aging_facial'),
  exfoliation('exfoliation'),
  blackheadRemoval('blackhead_removal'),
  // Massage
  fullBodyMassage('full_body_massage'),
  backMassage('back_massage'),
  headMassage('head_massage'),
  footMassage('foot_massage'),
  deepTissueMassage('deep_tissue_massage'),
  // Waxing
  waxing('waxing'),
  fullBodyWaxing('full_body_waxing'),
  legWaxing('leg_waxing'),
  armWaxing('arm_waxing'),
  facialWaxing('facial_waxing'),
  bikiniWaxing('bikini_waxing'),
  other('other');

  const ServiceCategory(this.value);
  final String value;

  String get displayName => value
      .split('_')
      .map((w) => w[0].toUpperCase() + w.substring(1))
      .join(' ');
}

enum ServiceStatus {
  active('active'),
  inactive('inactive'),
  seasonal('seasonal');

  const ServiceStatus(this.value);
  final String value;
}

class ServiceVariant extends Equatable {
  final String id;
  final String name;
  final double price;
  final int? duration;
  final String? description;

  const ServiceVariant({
    required this.id,
    required this.name,
    required this.price,
    this.duration,
    this.description,
  });

  @override
  List<Object?> get props => [id, name, price, duration, description];
}

class ServiceAddOn extends Equatable {
  final String id;
  final String name;
  final double price;
  final int duration;
  final String? description;

  const ServiceAddOn({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    this.description,
  });

  @override
  List<Object?> get props => [id, name, price, duration, description];
}

class DynamicPricing extends Equatable {
  final DynamicPricingType type;
  final double priceMultiplier;
  final bool applicable;

  const DynamicPricing({
    required this.type,
    required this.priceMultiplier,
    required this.applicable,
  });

  @override
  List<Object?> get props => [type, priceMultiplier, applicable];
}

enum DynamicPricingType {
  weekend('weekend'),
  peakHours('peak_hours'),
  vipClient('vip_client'),
  holiday('holiday');

  const DynamicPricingType(this.value);
  final String value;
}

class ServiceRequirements extends Equatable {
  final int? minAge;
  final int? maxAge;
  final String? gender;
  final String? skinType;
  final String? hairType;

  const ServiceRequirements({
    this.minAge,
    this.maxAge,
    this.gender,
    this.skinType,
    this.hairType,
  });

  @override
  List<Object?> get props => [minAge, maxAge, gender, skinType, hairType];
}

class FAQ extends Equatable {
  final String question;
  final String answer;

  const FAQ({
    required this.question,
    required this.answer,
  });

  @override
  List<Object?> get props => [question, answer];
}
