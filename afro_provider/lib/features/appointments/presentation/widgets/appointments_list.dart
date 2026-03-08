import 'package:flutter/material.dart';

class AppointmentsList extends StatelessWidget {
  final DateTime selectedDate;

  const AppointmentsList({
    super.key,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    // Mock appointments for the selected date
    final appointments = [
      {
        'time': '9:00 AM',
        'customer': 'John Smith',
        'service': 'Classic Haircut',
        'staff': 'Sarah Johnson',
        'status': 'Confirmed',
        'price': '\$25.00',
      },
      {
        'time': '9:30 AM',
        'customer': 'Mike Wilson',
        'service': 'Beard Trim',
        'staff': 'Mike Wilson',
        'status': 'Confirmed',
        'price': '\$15.00',
      },
      {
        'time': '10:00 AM',
        'customer': 'Emily Davis',
        'service': 'Hair Coloring',
        'staff': 'Sarah Johnson',
        'status': 'In Progress',
        'price': '\$60.00',
      },
    ];

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
            ...appointments.map((appointment) => _AppointmentItem(
              time: appointment['time'] as String,
              customer: appointment['customer'] as String,
              service: appointment['service'] as String,
              staff: appointment['staff'] as String,
              status: appointment['status'] as String,
              price: appointment['price'] as String,
            )).toList(),
          ],
        ),
      ),
    );
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
