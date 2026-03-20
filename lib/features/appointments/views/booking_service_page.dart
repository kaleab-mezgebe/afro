import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';
import '../controllers/appointments_controller.dart';

class BookingServicePage extends GetView<AppointmentsController> {
  const BookingServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'SELECT SERVICE',
          style: TextStyle(color: AppTheme.black, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        final provider = controller.selectedProvider.value;
        if (provider == null) return _buildNoProviderSelected();

        return Column(
          children: [
            _buildProgressIndicator(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProviderCard(provider),
                    const SizedBox(height: 32),
                    const Text(
                      'AVAILABLE SERVICES',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.greyMedium, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 16),
                    if (controller.isLoading.value)
                      const Center(child: CircularProgressIndicator(color: AppTheme.primaryYellow))
                    else if (controller.services.isEmpty)
                      _buildNoServicesState()
                    else
                      ...controller.services.map((service) => _buildServiceTile(service)).toList(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
      bottomSheet: _buildContinueButton(),
    );
  }

  Widget _buildNoProviderSelected() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store_rounded, size: 64, color: AppTheme.greyMedium.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text('Please select a specialist first'),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: () => Get.toNamed(AppRoutes.search), child: const Text('Find Specialist')),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      child: Row(
        children: [
          _buildProgressStep(1, 'SERVICE', true, false),
          _buildProgressLine(false),
          _buildProgressStep(2, 'TIME', false, false),
          _buildProgressLine(false),
          _buildProgressStep(3, 'REVIEW', false, false),
        ],
      ),
    );
  }

  Widget _buildProgressStep(int step, String title, bool isActive, bool isCompleted) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.black : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: isActive ? AppTheme.black : AppTheme.greyMedium.withOpacity(0.3), width: 2),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                    '$step',
                    style: TextStyle(
                      color: isActive ? Colors.white : AppTheme.greyMedium,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(
            color: isActive ? AppTheme.black : AppTheme.greyMedium,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine(bool isCompleted) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isCompleted ? AppTheme.black : AppTheme.greyMedium.withOpacity(0.1),
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }

  Widget _buildProviderCard(provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.black,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              provider.imageUrl ?? 'https://picsum.photos/seed/${provider.id}/200/200',
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                ),
                Text(
                  provider.category.toUpperCase(),
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: AppTheme.primaryYellow, borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, size: 14, color: AppTheme.black),
                const SizedBox(width: 4),
                Text(provider.rating.toString(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceTile(service) {
    final isSelected = controller.selectedService.value?.id == service.id;
    return GestureDetector(
      onTap: () => controller.selectService(service),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryYellow : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isSelected ? AppTheme.primaryYellow : const Color(0xFFEEEEEE), width: 2),
          boxShadow: isSelected ? [BoxShadow(color: AppTheme.primaryYellow.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))] : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: isSelected ? AppTheme.black : AppTheme.black),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 14, color: isSelected ? AppTheme.black : AppTheme.greyMedium),
                      const SizedBox(width: 4),
                      Text('${service.durationMinutes} MIN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isSelected ? AppTheme.black : AppTheme.greyMedium)),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              '\$${(service.priceCents / 100).toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: isSelected ? AppTheme.black : AppTheme.black),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoServicesState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.sentiment_dissatisfied_rounded, size: 48, color: AppTheme.greyMedium.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text('No individual services listed yet.'),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return Obx(() {
      final isSelected = controller.selectedService.value != null;
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -10))],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TOTAL ESTIMATE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: AppTheme.greyMedium, letterSpacing: 1)),
                      Text(
                        '\$${(controller.selectedService.value!.priceCents / 100).toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -1),
                      ),
                    ],
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSelected ? () => Get.toNamed(AppRoutes.bookingTime) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.black,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppTheme.greyMedium.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('PICK DATE & TIME', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
