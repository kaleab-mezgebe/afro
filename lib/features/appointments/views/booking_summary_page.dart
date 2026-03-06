import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../routes/app_routes.dart';
import '../controllers/appointments_controller.dart';

class BookingSummaryPage extends GetView<AppointmentsController> {
  const BookingSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Checkout',
          style: TextStyle(
            color: AppTheme.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        final provider = controller.selectedProvider.value;
        final service = controller.selectedService.value;
        final timeSlot = controller.selectedTimeSlot.value;

        if (provider == null || service == null || timeSlot == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppTheme.error),
                const SizedBox(height: 16),
                const Text('Missing booking information'),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Get.offAllNamed(AppRoutes.home),
                  child: const Text('Return Home'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            _buildProgressIndicator(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildSectionHeader('Specialist'),
                    _buildProviderCard(provider),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Appointment Details'),
                    _buildDetailsCard(service, timeSlot),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Payment Method'),
                    _buildPaymentCard(),
                    const SizedBox(height: 32),
                    _buildPriceSummary(service),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
      bottomSheet: _buildPayButton(),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          _buildProgressStep(1, 'Service', true, true),
          _buildProgressLine(true),
          _buildProgressStep(2, 'DateTime', true, true),
          _buildProgressLine(true),
          _buildProgressStep(3, 'Review', true, false),
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
            color: isCompleted ? AppTheme.primaryYellow : (isActive ? AppTheme.white : AppTheme.grey100),
            shape: BoxShape.circle,
            border: Border.all(color: isActive ? AppTheme.primaryYellow : AppTheme.grey300),
          ),
          child: Center(
            child: isCompleted
                ? Icon(Icons.check, size: 16, color: AppTheme.black)
                : Text(
                    '$step',
                    style: TextStyle(
                      color: isActive ? AppTheme.black : AppTheme.grey500,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(
            color: isActive ? AppTheme.black : AppTheme.grey500,
            fontSize: 11,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine(bool isCompleted) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: isCompleted ? AppTheme.primaryYellow : AppTheme.grey200,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildProviderCard(provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [AppTheme.softShadow],
        border: Border.all(color: AppTheme.grey100),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.grey50,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.grey200, width: 2),
            ),
            child: Icon(Icons.person, color: AppTheme.primaryYellow, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  provider.category.toUpperCase(),
                  style: TextStyle(color: AppTheme.grey500, fontSize: 12, letterSpacing: 1),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryYellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: AppTheme.primaryYellow, size: 14),
                const SizedBox(width: 4),
                Text(
                  provider.rating.toStringAsFixed(1),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(service, timeSlot) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [AppTheme.softShadow],
        border: Border.all(color: AppTheme.grey100),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            Icons.content_cut,
            'Service',
            service.name,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          _buildDetailRow(
            Icons.calendar_today,
            'Date',
            AppDateUtils.formatDisplayDate(timeSlot.start),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          _buildDetailRow(
            Icons.access_time,
            'Time',
            '${AppDateUtils.formatDisplayTime(timeSlot.start)} - ${AppDateUtils.formatDisplayTime(timeSlot.end)}',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.grey50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: AppTheme.grey600),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: AppTheme.grey500, fontSize: 12)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [AppTheme.softShadow],
        border: Border.all(color: AppTheme.grey100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.credit_card, size: 24, color: AppTheme.primaryYellow),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mastercard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text('**** **** **** 4582', style: TextStyle(color: AppTheme.grey500, fontSize: 13)),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: AppTheme.primaryYellow),
        ],
      ),
    );
  }

  Widget _buildPriceSummary(service) {
    final subtotal = service.priceCents;
    final tax = (subtotal * 0.15).round(); // 15% VAT
    final total = subtotal + tax;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.grey50,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _buildPriceRow('Subtotal', AppDateUtils.formatPrice(subtotal), isBold: false),
          const SizedBox(height: 12),
          _buildPriceRow('VAT (15%)', AppDateUtils.formatPrice(tax), isBold: false),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          _buildPriceRow('Total Amount', AppDateUtils.formatPrice(total), isBold: true, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {required bool isBold, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? AppTheme.black : AppTheme.grey600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 22 : 16,
            fontWeight: FontWeight.bold,
            color: isTotal ? AppTheme.primaryYellow : AppTheme.black,
          ),
        ),
      ],
    );
  }

  Widget _buildPayButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.createNewBooking,
                style: AppTheme.primaryButton,
                child: controller.isLoading.value
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: AppTheme.black, strokeWidth: 2),
                      )
                    : const Text('Complete Payment'),
              )),
        ),
      ),
    );
  }
}
