import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/appointment_provider.dart';

class AppointmentsList extends ConsumerWidget {
  final DateTime selectedDate;

  const AppointmentsList({
    super.key,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentState = ref.watch(appointmentProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appointments for ${selectedDate.day}/${selectedDate.month}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (appointmentState.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (appointmentState.error != null)
              Center(
                child: Text(
                  appointmentState.error!,
                  style: TextStyle(color: Colors.red[700]),
                ),
              )
            else if (appointmentState.appointments.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('No appointments for this date'),
                ),
              )
            else
              ...appointmentState.appointments.map((appointment) {
                final timeFormat = DateFormat('h:mm a');
                final startTime = appointment.startTime ?? DateTime.now();
                return _AppointmentItem(
                  time: timeFormat.format(startTime),
                  customer:
                      'Customer ${appointment.customerId}', // TODO: Get customer name
                  service: appointment.services.isNotEmpty
                      ? 'Service ${appointment.services[0].serviceId}'
                      : 'Service',
                  staff: 'Staff ${appointment.staffId}', // TODO: Get staff name
                  status: _getStatusText(appointment.status.toString()),
                  price: '\$${appointment.totalPrice.toStringAsFixed(2)}',
                );
              }),
          ],
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    // Convert enum string to readable text
    return status
        .split('.')
        .last
        .replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(0)}',
        )
        .trim();
  }
}

class _AppointmentItem extends StatelessWidget {
  final String time;
  final String customer;
  final String service;
  final String staff;
  final String status;
  final String price;

  const _AppointmentItem({
    required this.time,
    required this.customer,
    required this.service,
    required this.staff,
    required this.status,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                time,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(status),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            customer,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            service,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'with $staff',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                price,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 16),
                    onPressed: () {
                      // TODO: Edit appointment
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.phone, size: 16),
                    onPressed: () {
                      // TODO: Call customer
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, size: 16),
                    onPressed: () {
                      // TODO: Show options
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return Colors.green;
      case 'In Progress':
        return Colors.blue;
      case 'Completed':
        return Colors.purple;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
