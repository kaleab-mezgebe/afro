import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? avatar;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? bio;
  final List<String> preferences;

  const Profile({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.avatar,
    this.dateOfBirth,
    this.gender,
    this.bio,
    this.preferences = const [],
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phoneNumber,
        avatar,
        dateOfBirth,
        gender,
        bio,
        preferences,
      ];

  Profile copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? avatar,
    DateTime? dateOfBirth,
    String? gender,
    String? bio,
    List<String>? preferences,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatar: avatar ?? this.avatar,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bio: bio ?? this.bio,
      preferences: preferences ?? this.preferences,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'avatar': avatar,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'bio': bio,
      'preferences': preferences,
    };
  }

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      avatar: json['avatar'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      gender: json['gender'] as String?,
      bio: json['bio'] as String?,
      preferences: List<String>.from(json['preferences'] ?? []),
    );
  }
}
