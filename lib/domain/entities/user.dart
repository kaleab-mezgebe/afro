import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? avatar;
  final bool isEmailVerified;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Extended profile fields for registration
  final String? firstName;
  final String? lastName;
  final String? location;
  final String? gender;
  final String? dateOfBirth;
  final String? hairType;
  final String? skinType;
  final List<String>? preferredServices;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.avatar,
    this.isEmailVerified = false,
    required this.createdAt,
    this.updatedAt,
    this.firstName,
    this.lastName,
    this.location,
    this.gender,
    this.dateOfBirth,
    this.hairType,
    this.skinType,
    this.preferredServices,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phoneNumber,
    avatar,
    isEmailVerified,
    createdAt,
    updatedAt,
    firstName,
    lastName,
    location,
    gender,
    dateOfBirth,
    hairType,
    skinType,
    preferredServices,
  ];

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? avatar,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? firstName,
    String? lastName,
    String? location,
    String? gender,
    String? dateOfBirth,
    String? hairType,
    String? skinType,
    List<String>? preferredServices,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatar: avatar ?? this.avatar,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      location: location ?? this.location,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      hairType: hairType ?? this.hairType,
      skinType: skinType ?? this.skinType,
      preferredServices: preferredServices ?? this.preferredServices,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'avatar': avatar,
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'firstName': firstName,
      'lastName': lastName,
      'location': location,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'hairType': hairType,
      'skinType': skinType,
      'preferredServices': preferredServices,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      avatar: json['avatar'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      location: json['location'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      hairType: json['hairType'] as String?,
      skinType: json['skinType'] as String?,
      preferredServices: (json['preferredServices'] as List<dynamic>?)
          ?.cast<String>(),
    );
  }
}
