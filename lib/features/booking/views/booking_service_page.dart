import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/date_utils.dart';
import '../controllers/booking_controller.dart';

class BookingServicePage extends GetView<BookingController> {
  const BookingServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Provider'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${controller.error.value}',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.loadProviders,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Provider Selection
            Expanded(flex: 2, child: _buildProviderSection(context)),
            // Service Selection
            Expanded(flex: 3, child: _buildServiceSection(context)),
            // Continue Button
            _buildContinueButton(),
          ],
        );
      }),
    );
  }

  Widget _buildProviderSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Provider',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: controller.providers.length,
              itemBuilder: (context, index) {
                final provider = controller.providers[index];
                final isSelected =
                    controller.selectedProvider.value?.id == provider.id;

                return Card(
                  elevation: isSelected ? 4 : 1,
                  color: isSelected
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : null,
                  child: ListTile(
                    leading: CircleAvatar(child: Text(provider.name[0])),
                    title: Text(provider.name),
                    subtitle: Text(provider.category.toUpperCase()),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(provider.rating.toStringAsFixed(1)),
                      ],
                    ),
                    onTap: () => controller.selectProvider(provider),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Service', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          if (controller.selectedProvider.value == null)
            Expanded(
              child: Center(
                child: Text(
                  'Please select a provider first',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
              ),
            )
          else if (controller.services.isEmpty && !controller.isLoading.value)
            Expanded(
              child: Center(
                child: Text(
                  'No services available',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: controller.services.length,
                itemBuilder: (context, index) {
                  final service = controller.services[index];
                  final isSelected =
                      controller.selectedService.value?.id == service.id;

                  return Card(
                    elevation: isSelected ? 4 : 1,
                    color: isSelected
                        ? Theme.of(context).primaryColor.withOpacity(0.1)
                        : null,
                    child: ListTile(
                      title: Text(service.name),
                      subtitle: Text(
                        AppDateUtils.formatDuration(service.durationMinutes),
                      ),
                      trailing: Text(
                        AppDateUtils.formatPrice(service.priceCents),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      onTap: () => controller.selectService(service),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Obx(
        () => ElevatedButton(
          onPressed: controller.selectedService.value != null
              ? () => Get.toNamed('/booking/time')
              : null,
          child: const Text('Continue to Time Selection'),
        ),
      ),
    );
  }
}
