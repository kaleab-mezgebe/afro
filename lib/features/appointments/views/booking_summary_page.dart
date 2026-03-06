import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/date_utils.dart';
import '../../../routes/app_routes.dart';
import '../controllers/appointments_controller.dart';

class BookingSummaryPage extends GetView<AppointmentsController> {
  const BookingSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Summary'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final provider = controller.selectedProvider.value;
        final service = controller.selectedService.value;
        final timeSlot = controller.selectedTimeSlot.value;

        if (provider == null || service == null || timeSlot == null) {
          return const Center(
            child: Text('Missing booking information'),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Provider Info
              _buildSection(
                title: 'Provider',
                child: _buildProviderInfo(provider),
              ),
              const SizedBox(height: 16),
              
              // Service Info
              _buildSection(
                title: 'Service',
                child: _buildServiceInfo(service),
              ),
              const SizedBox(height: 16),
              
              // Time Info
              _buildSection(
                title: 'Appointment Time',
                child: _buildTimeInfo(timeSlot),
              ),
              const SizedBox(height: 16),
              
              // Price Info
              _buildSection(
                title: 'Price',
                child: _buildPriceInfo(service),
              ),
              
              const Spacer(),
              
              // Confirm Button
              Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.createNewBooking,
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Confirm Booking'),
              )),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildProviderInfo(provider) {
    return Row(
      children: [
        CircleAvatar(
          child: Text(provider.name[0]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                provider.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                provider.category.toUpperCase(),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 16),
            Text(provider.rating.toStringAsFixed(1)),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceInfo(service) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          service.name,
          style: const TextStyle(fontSize: 16),
        ),
        Text(
          AppDateUtils.formatDuration(service.durationMinutes),
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeInfo(timeSlot) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppDateUtils.formatDisplayDate(timeSlot.start),
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          '${AppDateUtils.formatDisplayTime(timeSlot.start)} - ${AppDateUtils.formatDisplayTime(timeSlot.end)}',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceInfo(service) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Total Price',
          style: TextStyle(fontSize: 16),
        ),
        Text(
          AppDateUtils.formatPrice(service.priceCents),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
