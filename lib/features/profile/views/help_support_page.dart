import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_settings/app_settings.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/error_handler.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  static const _faqs = [
    _FAQ(
      question: 'How do I book an appointment?',
      answer:
          'Browse specialists on the Home tab, tap on a specialist to view their profile, select a service, choose a date and time, then confirm your booking.',
    ),
    _FAQ(
      question: 'Can I cancel my appointment?',
      answer:
          'Yes. Go to My Bookings, find the appointment you want to cancel, and tap "Cancel Appointment". Cancellations made at least 2 hours before the appointment are free.',
    ),
    _FAQ(
      question: 'How do I pay for my appointment?',
      answer:
          'We support cash payment at the shop, Telebirr, CBE Birr, Chapa, and credit/debit cards. You can select your preferred method during checkout.',
    ),
    _FAQ(
      question: 'How do I leave a review?',
      answer:
          'After your appointment is completed, go to My Bookings and tap "Leave Review" on the completed appointment card.',
    ),
    _FAQ(
      question: 'What if the specialist is unavailable?',
      answer:
          'If a specialist cancels, you will receive a notification and a full refund if payment was made. You can then rebook with another specialist.',
    ),
    _FAQ(
      question: 'How do I update my profile?',
      answer:
          'Go to the Profile tab and tap "Edit Profile" to update your name, phone number, and other details.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.grey50,
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
          'Help & Support',
          style: TextStyle(
            color: AppTheme.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact options
            _buildSectionTitle('Contact Us'),
            const SizedBox(height: 12),
            _buildContactCard(
              icon: Icons.email_outlined,
              title: 'Email Support',
              subtitle: 'support@afrobooking.com',
              color: const Color(0xFF2196F3),
              onTap: () => _launchEmail('support@afrobooking.com'),
            ),
            const SizedBox(height: 12),
            _buildContactCard(
              icon: Icons.phone_outlined,
              title: 'Phone Support',
              subtitle: '+251 911 000 000',
              color: const Color(0xFF4CAF50),
              onTap: () => _launchPhone('+251911000000'),
            ),
            const SizedBox(height: 12),
            _buildContactCard(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Live Chat',
              subtitle: 'Available 8AM - 8PM',
              color: AppTheme.primaryYellow,
              onTap: () => Get.snackbar(
                'Coming Soon',
                'Live chat will be available soon.',
                snackPosition: SnackPosition.BOTTOM,
              ),
            ),
            const SizedBox(height: 32),

            // FAQs
            _buildSectionTitle('Frequently Asked Questions'),
            const SizedBox(height: 12),
            ..._faqs.map((faq) => _buildFaqTile(faq)),
            const SizedBox(height: 32),

            // App info
            _buildSectionTitle('App Information'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [AppTheme.softShadow],
              ),
              child: Column(
                children: [
                  _buildInfoRow('App Version', '1.0.0'),
                  const Divider(height: 24),
                  _buildInfoRow('Build Number', '100'),
                  const Divider(height: 24),
                  _buildInfoRow('Platform', 'Flutter'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Legal links
            _buildSectionTitle('Legal'),
            const SizedBox(height: 12),
            _buildLegalTile('Terms of Service', Icons.description_outlined),
            const SizedBox(height: 8),
            _buildLegalTile('Privacy Policy', Icons.privacy_tip_outlined),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: AppTheme.greyMedium,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [AppTheme.softShadow],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: AppTheme.grey500),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppTheme.grey400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqTile(_FAQ faq) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppTheme.softShadow],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        iconColor: AppTheme.primaryYellow,
        collapsedIconColor: AppTheme.grey400,
        title: Text(
          faq.question,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.black,
          ),
        ),
        children: [
          Text(
            faq.answer,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.grey600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: AppTheme.grey600)),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.black,
          ),
        ),
      ],
    );
  }

  Widget _buildLegalTile(String title, IconData icon) {
    return InkWell(
      onTap: () => Get.snackbar(
        title,
        'Coming soon.',
        snackPosition: SnackPosition.BOTTOM,
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [AppTheme.softShadow],
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.grey500),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.black,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppTheme.grey400,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    try {
      await AppSettings.openAppSettings(type: AppSettingsType.notification);
    } catch (_) {
      ErrorHandler.showErrorSnackbar(
        'Could not open email app. Please email us at $email',
      );
    }
  }

  Future<void> _launchPhone(String phone) async {
    Get.snackbar(
      'Call Us',
      'Please call $phone',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
    );
  }
}

class _FAQ {
  final String question;
  final String answer;
  const _FAQ({required this.question, required this.answer});
}
