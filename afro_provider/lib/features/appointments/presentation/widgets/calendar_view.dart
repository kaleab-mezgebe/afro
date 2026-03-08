import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarView extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const CalendarView({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Month Navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    // TODO: Navigate to previous month
                  },
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  'March 2024',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  onPressed: () {
                    // TODO: Navigate to next month
                  },
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Calendar Grid
            TableCalendar(
              firstDay: DateTime(2024, 3, 1),
              lastDay: DateTime(2024, 3, 31),
              focusedDay: selectedDate,
              calendarFormat:
                  CalendarFormat.week, // Fixed: Changed from weekOnly to week
              headerStyle: HeaderStyle(
                titleTextStyle:
                    Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ) ??
                        const TextStyle(fontWeight: FontWeight.bold),
                formatButtonVisible: false,
                leftChevronVisible: false,
                rightChevronVisible: false,
              ),
              calendarStyle: CalendarStyle(
                weekendTextStyle:
                    Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.red,
                            ) ??
                        const TextStyle(color: Colors.red),
                defaultTextStyle:
                    Theme.of(context).textTheme.bodyMedium ?? const TextStyle(),
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(selectedDay, focusedDay)) {
                  onDateSelected(selectedDay);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  bool isSameDay(DateTime day1, DateTime day2) {
    return day1.year == day2.year &&
        day1.month == day2.month &&
        day1.day == day2.day;
  }
}
