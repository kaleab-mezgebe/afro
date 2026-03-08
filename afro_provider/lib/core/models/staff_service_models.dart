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
  makeupArtist('makeup_artist'),
  nailTechnician('nail_technician'),
  receptionist('receptionist'),
  manager('manager'),
  owner('owner');

  const StaffRole(this.value);
  final String value;
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
  haircut('haircut'),
  beardTrim('beard_trim'),
  hairColoring('hair_coloring'),
  hairStyling('hair_styling'),
  makeup('makeup'),
  nailCare('nail_care'),
  skinCare('skin_care'),
  waxing('waxing'),
  facial('facial'),
  other('other');

  const ServiceCategory(this.value);
  final String value;
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
