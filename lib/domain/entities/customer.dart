import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final int totalVisits;
  final double totalSpent;
  final DateTime lastVisit;
  final CustomerStatus status;

  const Customer({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.totalVisits,
    required this.totalSpent,
    required this.lastVisit,
    required this.status,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    firstName,
    lastName,
    phoneNumber,
    totalVisits,
    totalSpent,
    lastVisit,
    status,
  ];

  Customer copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    int? totalVisits,
    double? totalSpent,
    DateTime? lastVisit,
    CustomerStatus? status,
  }) {
    return Customer(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      totalVisits: totalVisits ?? this.totalVisits,
      totalSpent: totalSpent ?? this.totalSpent,
      lastVisit: lastVisit ?? this.lastVisit,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'totalVisits': totalVisits,
      'totalSpent': totalSpent,
      'lastVisit': lastVisit.toIso8601String(),
      'status': status.name,
    };
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      totalVisits: json['totalVisits'] as int,
      totalSpent: (json['totalSpent'] as num).toDouble(),
      lastVisit: DateTime.parse(json['lastVisit'] as String),
      status: CustomerStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CustomerStatus.active,
      ),
    );
  }
}

enum CustomerStatus {
  active('active'),
  inactive('inactive'),
  suspended('suspended'),
  vip('vip');

  const CustomerStatus(this.value);
  final String value;
}
