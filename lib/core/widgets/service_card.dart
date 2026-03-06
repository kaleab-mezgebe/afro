import 'package:flutter/material.dart';
import '../../domain/entities/service.dart';
import '../utils/date_utils.dart';

class ServiceCard extends StatelessWidget {
  final Service service;
  final bool isSelected;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.service,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : null,
      child: ListTile(
        title: Text(
          service.name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(AppDateUtils.formatDuration(service.durationMinutes)),
        trailing: Text(
          AppDateUtils.formatPrice(service.priceCents),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isSelected ? Theme.of(context).primaryColor : null,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
