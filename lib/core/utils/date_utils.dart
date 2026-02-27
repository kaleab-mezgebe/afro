import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  static String formatDisplayDate(DateTime date) {
    return DateFormat('EEEE, MMM d, y').format(date);
  }

  static String formatDisplayTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }

  static String formatPrice(int priceCents) {
    return '\$${(priceCents / 100).toStringAsFixed(2)}';
  }

  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${remainingMinutes}m';
      }
    }
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  static List<DateTime> generateTimeSlots({
    required DateTime date,
    int startHour = 9,
    int endHour = 17,
    int intervalMinutes = 30,
  }) {
    final slots = <DateTime>[];
    final startOfDay = DateTime(date.year, date.month, date.day, startHour);
    final endOfDay = DateTime(date.year, date.month, date.day, endHour);
    
    var current = startOfDay;
    while (current.isBefore(endOfDay)) {
      slots.add(current);
      current = current.add(Duration(minutes: intervalMinutes));
    }
    
    return slots;
  }
}
