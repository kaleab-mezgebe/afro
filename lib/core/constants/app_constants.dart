class AppConstants {
  static const String appName = 'Afro';
  static const String apiBaseUrl = 'http://192.168.0.201:3001/api/v1';

  // For Android emulator use: http://10.0.2.2:3001/api/v1
  // For iOS simulator use: http://localhost:3001/api/v1
  // For physical device use: http://YOUR_IP:3001/api/v1

  // Storage keys
  static const String bookingsKey = 'my_bookings';
  static const String userPreferencesKey = 'user_preferences';

  // Time formats
  static const String timeFormat = 'HH:mm';
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm';

  // Business hours
  static const int openingHour = 9;
  static const int closingHour = 17;
  static const int bookingIntervalMinutes = 30;
}

class AppStrings {
  // General
  static const String appName = 'Afro';
  static const String bookAppointment = 'Book your next appointment';
  static const String pickProviderServiceTime =
      'Pick a provider, choose a service, then select a time slot.';
  static const String startBooking = 'Start booking';
  static const String viewBookingHistory = 'View booking history';

  // Booking flow
  static const String selectProvider = 'Select Provider';
  static const String selectService = 'Select Service';
  static const String selectTime = 'Select Time';
  static const String bookingSummary = 'Booking Summary';
  static const String confirmBooking = 'Confirm Booking';
  static const String bookingConfirmed = 'Booking Confirmed!';

  // Provider types
  static const String salon = 'salon';
  static const String barber = 'barber';

  // Status
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String retry = 'Retry';
  static const String cancel = 'Cancel';
  static const String ok = 'OK';

  // Booking status
  static const String pending = 'Pending';
  static const String confirmed = 'Confirmed';
  static const String cancelled = 'Cancelled';
  static const String completed = 'Completed';
}
