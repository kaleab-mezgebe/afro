import 'package:equatable/equatable.dart';
import 'staff_service_models.dart';

// Provider Models
class Provider extends Equatable {
  final String id;
  final String email;
  final String phoneNumber;
  final String? firstName;
  final String? lastName;
  final String? profileImage;
  final ProviderStatus status;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Shop> shops;

  const Provider({
    required this.id,
    required this.email,
    required this.phoneNumber,
    this.firstName,
    this.lastName,
    this.profileImage,
    required this.status,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
    this.shops = const [],
  });

  @override
  List<Object?> get props => [
        id,
        email,
        phoneNumber,
        firstName,
        lastName,
        profileImage,
        status,
        isVerified,
        createdAt,
        updatedAt,
        shops
      ];
}

enum ProviderStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected'),
  suspended('suspended');

  const ProviderStatus(this.value);
  final String value;
}

// Shop Models
class Shop extends Equatable {
  final String id;
  final String providerId;
  final String name;
  final String? logo;
  final String? description;
  final ShopCategory category;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? phoneNumber;
  final String? email;
  final String? website;
  final SocialMediaLinks? socialMedia;
  final WorkingHours? workingHours;
  final List<String> shopPhotos;
  final bool isActive;
  final double rating;
  final int totalReviews;
  final ShopSettings? settings;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ShopBranch> branches;
  final List<Staff> staff;
  final List<Service> services;

  const Shop({
    required this.id,
    required this.providerId,
    required this.name,
    this.logo,
    this.description,
    required this.category,
    this.latitude,
    this.longitude,
    this.address,
    this.city,
    this.state,
    this.country,
    this.phoneNumber,
    this.email,
    this.website,
    this.socialMedia,
    this.workingHours,
    this.shopPhotos = const [],
    required this.isActive,
    required this.rating,
    required this.totalReviews,
    this.settings,
    required this.createdAt,
    required this.updatedAt,
    this.branches = const [],
    this.staff = const [],
    this.services = const [],
  });

  @override
  List<Object?> get props => [
        id,
        providerId,
        name,
        logo,
        description,
        category,
        latitude,
        longitude,
        address,
        city,
        state,
        country,
        phoneNumber,
        email,
        website,
        socialMedia,
        workingHours,
        shopPhotos,
        isActive,
        rating,
        totalReviews,
        settings,
        createdAt,
        updatedAt,
        branches,
        staff,
        services
      ];
}

enum ShopCategory {
  barberShop('barber_shop'),
  hairSalon('hair_salon'),
  beautySalon('beauty_salon'),
  makeupStudio('makeup_studio'),
  nailStudio('nail_studio');

  const ShopCategory(this.value);
  final String value;
}

class SocialMediaLinks extends Equatable {
  final String? facebook;
  final String? instagram;
  final String? twitter;
  final String? youtube;

  const SocialMediaLinks({
    this.facebook,
    this.instagram,
    this.twitter,
    this.youtube,
  });

  @override
  List<Object?> get props => [facebook, instagram, twitter, youtube];
}

class WorkingHours extends Equatable {
  final DaySchedule monday;
  final DaySchedule tuesday;
  final DaySchedule wednesday;
  final DaySchedule thursday;
  final DaySchedule friday;
  final DaySchedule saturday;
  final DaySchedule sunday;

  const WorkingHours({
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
  });

  @override
  List<Object?> get props =>
      [monday, tuesday, wednesday, thursday, friday, saturday, sunday];
}

class DaySchedule extends Equatable {
  final String open;
  final String close;
  final bool closed;

  const DaySchedule({
    required this.open,
    required this.close,
    required this.closed,
  });

  @override
  List<Object?> get props => [open, close, closed];
}

class ShopSettings extends Equatable {
  final bool allowOnlineBooking;
  final bool requireDeposit;
  final double depositAmount;
  final String cancellationPolicy;
  final int advanceBookingDays;

  const ShopSettings({
    required this.allowOnlineBooking,
    required this.requireDeposit,
    required this.depositAmount,
    required this.cancellationPolicy,
    required this.advanceBookingDays,
  });

  @override
  List<Object?> get props => [
        allowOnlineBooking,
        requireDeposit,
        depositAmount,
        cancellationPolicy,
        advanceBookingDays
      ];
}

class ShopBranch extends Equatable {
  final String id;
  final String mainShopId;
  final String name;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? phoneNumber;
  final WorkingHours? workingHours;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ShopBranch({
    required this.id,
    required this.mainShopId,
    required this.name,
    this.latitude,
    this.longitude,
    this.address,
    this.phoneNumber,
    this.workingHours,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        mainShopId,
        name,
        latitude,
        longitude,
        address,
        phoneNumber,
        workingHours,
        isActive,
        createdAt,
        updatedAt
      ];
}
