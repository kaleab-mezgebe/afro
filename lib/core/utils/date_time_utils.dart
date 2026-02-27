import 'package:intl/intl.dart';

class DateTimeUtils {
  static String formatDate(DateTime date) => DateFormat('EEE, MMM d').format(date);

  static String formatTime(DateTime date) => DateFormat('h:mm a').format(date);

  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}

