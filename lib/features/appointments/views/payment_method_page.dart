import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/services/payment_api_service.dart';
import '../../../core/utils/error_handler.dart';
import '../controllers/appointments_controller.dart';

class PaymentMethodPage extends StatefulWidget {
  const PaymentMethodPage({super.key});

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  final AppointmentsController _appointmentsController =
      Get.find<AppointmentsController>();

  PaymentMethod _selectedMethod = PaymentMethod.cash;
  bool _isProcessing = false;

  final List<_PaymentOption> _options = [
    _PaymentOption(
      method: PaymentMethod.cash,
      label: 'Pay at Shop',
      subtitle: 'Pay in cash when you arrive',
      icon: Icons.payments_outlined,
      color: const Color(0xFF4CAF50),
    ),
    _PaymentOption(
      method: PaymentMethod.telebirr,
      label: 'Telebirr',
      subtitle: 'Pay with Telebirr mobile money',
      icon: Icons.phone_android_outlined,
      color: const Color(0xFF2196F3),
    ),
    _PaymentOption(
      method: PaymentMethod.cbeBirr,
      label: 'CBE Birr',
      subtitle: 'Pay with CBE Birr',
      icon: Icons.account_balance_outlined,
      color: const Color(0xFF9C27B0),
    ),
    _PaymentOption(
      method: PaymentMethod.chapa,
      label: 'Chapa',
      subtitle: 'Pay with Chapa payment gateway',
      icon: Icons.credit_card_outlined,
      color: const Color(0xFFFF9800),
    ),
    _PaymentOption(
      method: PaymentMethod.card,
      label: 'Credit / Debit Card',
      subtitle: 'Visa, Mastercard accepted',
      icon: Icons.credit_card,
      color: const Color(0xFF607D8B),
    ),
  ];

  Future<void> _confirmPayment() async {
    final service = _appointmentsController.selectedService.value;
    if (service == null) {
      ErrorHandler.showErrorSnackbar(
        'No service selected. Please go back and try again.',
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Create the booking first
      await _appointmentsController.createNewBooking();
    } catch (e) {
      ErrorHandler.handleError(e, onRetry: _confirmPayment);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppTheme.black,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Payment Method',
          style: TextStyle(
            color: AppTheme.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose how you\'d like to pay',
                    style: TextStyle(fontSize: 15, color: AppTheme.grey600),
                  ),
                  const SizedBox(height: 24),
                  ..._options.map((option) => _buildPaymentTile(option)),
                  const SizedBox(height: 24),
                  // Security note
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.grey50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.grey200),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lock_outline,
                          size: 20,
                          color: AppTheme.grey500,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your payment information is secure and encrypted.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.grey600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Confirm button
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.white,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _confirmPayment,
                  style: AppTheme.primaryButton,
                  child: _isProcessing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: AppTheme.black,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _selectedMethod == PaymentMethod.cash
                              ? 'Confirm Booking'
                              : 'Proceed to Pay',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTile(_PaymentOption option) {
    final isSelected = _selectedMethod == option.method;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = option.method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryYellow.withValues(alpha: 0.08)
              : AppTheme.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryYellow : AppTheme.grey200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [] : [AppTheme.softShadow],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: option.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(option.icon, color: option.color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppTheme.black : AppTheme.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    option.subtitle,
                    style: TextStyle(fontSize: 13, color: AppTheme.grey500),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppTheme.primaryYellow : AppTheme.white,
                border: Border.all(
                  color: isSelected ? AppTheme.primaryYellow : AppTheme.grey300,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: AppTheme.black)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentOption {
  final PaymentMethod method;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _PaymentOption({
    required this.method,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
