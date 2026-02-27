class TimeSlot {
  final DateTime start;
  final DateTime end;
  final bool isAvailable;

  const TimeSlot({
    required this.start,
    required this.end,
    required this.isAvailable,
  });
}

