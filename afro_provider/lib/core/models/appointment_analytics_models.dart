import 'package:equatable/equatable.dart';

// Appointment Models
class Appointment extends Equatable {
  final String id;
  final String customerId;
  final String shopId;
  final String? branchId;
  final String? staffId;
  final BookingType bookingType;
  final AppointmentStatus status;
  final DateTime appointmentDateTime;
  final int duration;
  final double totalPrice;
  final double depositAmount;
  final double tipAmount;
  final String? customerNotes;
  final String? staffNotes;
  final String? rejectionReason;
  final String? cancellationReason;
  final String? cancelledBy;
  final DateTime? rescheduledFrom;
  final DateTime? rescheduledTo;
  final List<Reminder> reminders;
  final PaymentDetails? paymentDetails;
  final DateTime? checkInTime;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool isNoShow;
  final DateTime? noShowTime;
  final AppointmentMetadata? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final CustomerInfo? customer;
  final StaffInfo? staff;
  final List<AppointmentService> services;

  const Appointment({
    required this.id,
    required this.customerId,
    required this.shopId,
    this.branchId,
    this.staffId,
    required this.bookingType,
    required this.status,
    required this.appointmentDateTime,
    required this.duration,
    required this.totalPrice,
    required this.depositAmount,
    required this.tipAmount,
    this.customerNotes,
    this.staffNotes,
    this.rejectionReason,
    this.cancellationReason,
    this.cancelledBy,
    this.rescheduledFrom,
    this.rescheduledTo,
    this.reminders = const [],
    this.paymentDetails,
    this.checkInTime,
    this.startTime,
    this.endTime,
    required this.isNoShow,
    this.noShowTime,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.customer,
    this.staff,
    this.services = const [],
  });

  @override
  List<Object?> get props => [
    id, customerId, shopId, branchId, staffId, bookingType, status,
    appointmentDateTime, duration, totalPrice, depositAmount, tipAmount,
    customerNotes, staffNotes, rejectionReason, cancellationReason,
    cancelledBy, rescheduledFrom, rescheduledTo, reminders, paymentDetails,
    checkInTime, startTime, endTime, isNoShow, noShowTime, metadata,
    createdAt, updatedAt, customer, staff, services
  ];
}

enum AppointmentStatus {
  pending('pending'),
  accepted('accepted'),
  rejected('rejected'),
  confirmed('confirmed'),
  inProgress('in_progress'),
  completed('completed'),
  cancelled('cancelled'),
  noShow('no_show');

  const AppointmentStatus(this.value);
  final String value;
}

enum BookingType {
  online('online'),
  walkIn('walk_in'),
  phone('phone'),
  manager('manager');

  const BookingType(this.value);
  final String value;
}

class Reminder extends Equatable {
  final ReminderType type;
  final DateTime scheduledAt;
  final bool sent;
  final DateTime? sentAt;

  const Reminder({
    required this.type,
    required this.scheduledAt,
    required this.sent,
    this.sentAt,
  });

  @override
  List<Object?> get props => [type, scheduledAt, sent, sentAt];
}

enum ReminderType {
  email('email'),
  sms('sms'),
  push('push');

  const ReminderType(this.value);
  final String value;
}

class PaymentDetails extends Equatable {
  final PaymentMethod method;
  final PaymentStatus status;
  final String? transactionId;
  final DateTime? paidAt;

  const PaymentDetails({
    required this.method,
    required this.status,
    this.transactionId,
    this.paidAt,
  });

  @override
  List<Object?> get props => [method, status, transactionId, paidAt];
}

enum PaymentMethod {
  cash('cash'),
  card('card'),
  online('online');

  const PaymentMethod(this.value);
  final String value;
}

enum PaymentStatus {
  pending('pending'),
  paid('paid'),
  refunded('refunded');

  const PaymentStatus(this.value);
  final String value;
}

class AppointmentMetadata extends Equatable {
  final String? source;
  final String? userAgent;
  final String? ipAddress;
  final String? referralCode;

  const AppointmentMetadata({
    this.source,
    this.userAgent,
    this.ipAddress,
    this.referralCode,
  });

  @override
  List<Object?> get props => [source, userAgent, ipAddress, referralCode];
}

class CustomerInfo extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String? avatar;

  const CustomerInfo({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.avatar,
  });

  @override
  List<Object?> get props => [id, name, email, phoneNumber, avatar];
}

class StaffInfo extends Equatable {
  final String id;
  final String name;
  final String role;
  final String? profileImage;

  const StaffInfo({
    required this.id,
    required this.name,
    required this.role,
    this.profileImage,
  });

  @override
  List<Object?> get props => [id, name, role, profileImage];
}

class AppointmentService extends Equatable {
  final String id;
  final String serviceId;
  final String? variantId;
  final List<String> selectedAddOns;
  final double price;
  final int duration;
  final ServiceInfo? service;

  const AppointmentService({
    required this.id,
    required this.serviceId,
    this.variantId,
    this.selectedAddOns = const [],
    required this.price,
    required this.duration,
    this.service,
  });

  @override
  List<Object?> get props => [
    id, serviceId, variantId, selectedAddOns, price, duration, service
  ];
}

class ServiceInfo extends Equatable {
  final String id;
  final String name;
  final String? image;

  const ServiceInfo({
    required this.id,
    required this.name,
    this.image,
  });

  @override
  List<Object?> get props => [id, name, image];
}

// Analytics Models
class ShopAnalytics extends Equatable {
  final double totalRevenue;
  final int totalBookings;
  final double averageBookingValue;
  final List<TopService> topServices;
  final AnalyticsPeriod period;
  final DateTime startDate;
  final DateTime endDate;
  final List<DailyRevenue> dailyRevenue;
  final List<StaffPerformance> staffPerformance;

  const ShopAnalytics({
    required this.totalRevenue,
    required this.totalBookings,
    required this.averageBookingValue,
    this.topServices = const [],
    required this.period,
    required this.startDate,
    required this.endDate,
    this.dailyRevenue = const [],
    this.staffPerformance = const [],
  });

  @override
  List<Object?> get props => [
    totalRevenue, totalBookings, averageBookingValue, topServices,
    period, startDate, endDate, dailyRevenue, staffPerformance
  ];
}

enum AnalyticsPeriod {
  today('today'),
  week('week'),
  month('month'),
  year('year');

  const AnalyticsPeriod(this.value);
  final String value;
}

class TopService extends Equatable {
  final String name;
  final int count;
  final double revenue;

  const TopService({
    required this.name,
    required this.count,
    required this.revenue,
  });

  @override
  List<Object?> get props => [name, count, revenue];
}

class DailyRevenue extends Equatable {
  final DateTime date;
  final double revenue;
  final int bookings;

  const DailyRevenue({
    required this.date,
    required this.revenue,
    required this.bookings,
  });

  @override
  List<Object?> get props => [date, revenue, bookings];
}

class StaffPerformance extends Equatable {
  final String staffId;
  final String staffName;
  final int appointments;
  final double revenue;
  final double averageRating;
  final double totalEarnings;

  const StaffPerformance({
    required this.staffId,
    required this.staffName,
    required this.appointments,
    required this.revenue,
    required this.averageRating,
    required this.totalEarnings,
  });

  @override
  List<Object?> get props => [
    staffId, staffName, appointments, revenue, averageRating, totalEarnings
  ];
}
