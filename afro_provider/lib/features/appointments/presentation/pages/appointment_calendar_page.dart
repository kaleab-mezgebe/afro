import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/appointment_provider.dart';

class AppointmentCalendarPage extends ConsumerWidget {
  const AppointmentCalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentState = ref.watch(appointmentProvider);
    final selectedDate = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              // TODO: Navigate to today
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Add new appointment
            },
          ),
        ],
      ),
      body: appointmentState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Calendar View
                Expanded(
                  flex: 2,
                  child: _CalendarView(
                    selectedDate: selectedDate,
                    onDateSelected: (date) {
                      // TODO: Handle date selection
                    },
                  ),
                ),

                // Appointments List
                Expanded(
                  flex: 1,
                  child: _AppointmentsList(
                    selectedDate: selectedDate,
                  ),
                ),
              ],
            ),
    );
  }
}

// Calendar View Widget
class _CalendarView extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const _CalendarView({
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Simple calendar header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  // TODO: Navigate to previous month
                },
              ),
              Text(
                '${selectedDate.month}/${selectedDate.year}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  // TODO: Navigate to next month
                },
              ),
            ],
          ),
          // Simple calendar grid placeholder
          const Expanded(
            child: Center(
              child: Text(
                'Calendar View\n(TODO: Implement calendar grid)',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Appointments List Widget
class _AppointmentsList extends StatelessWidget {
  final DateTime selectedDate;

  const _AppointmentsList({
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Appointments for ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Expanded(
            child: Center(
              child: Text(
                'No appointments scheduled\n(TODO: Load appointments for selected date)',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
