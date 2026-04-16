import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/services/review_api_service.dart';
import '../../../core/utils/error_handler.dart';
import '../../../routes/app_routes.dart';

class ReviewSubmissionPage extends StatefulWidget {
  const ReviewSubmissionPage({super.key});

  @override
  State<ReviewSubmissionPage> createState() => _ReviewSubmissionPageState();
}

class _ReviewSubmissionPageState extends State<ReviewSubmissionPage> {
  final ReviewApiService _reviewService = Get.find<ReviewApiService>();
  final TextEditingController _commentController = TextEditingController();

  int _rating = 0;
  bool _isSubmitting = false;

  late final String _barberId;
  late final String? _appointmentId;
  late final String _barberName;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    _barberId = args['barberId'] ?? '';
    _appointmentId = args['appointmentId'];
    _barberName = args['barberName'] ?? 'Specialist';
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      Get.snackbar(
        'Rating Required',
        'Please select a star rating before submitting.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.error,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _reviewService.createReview(
        barberId: _barberId,
        appointmentId: _appointmentId,
        rating: _rating,
        comment: _commentController.text.trim().isEmpty
            ? null
            : _commentController.text.trim(),
      );

      Get.snackbar(
        'Review Submitted',
        'Thank you for your feedback!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.success,
        colorText: Colors.white,
      );

      Get.offAllNamed(AppRoutes.bookingHistory);
    } catch (e) {
      ErrorHandler.handleError(e, onRetry: _submitReview);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
          icon: const Icon(Icons.close, color: AppTheme.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Leave a Review',
          style: TextStyle(
            color: AppTheme.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            // Specialist avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryYellow.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                size: 44,
                color: AppTheme.primaryYellow,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _barberName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'How was your experience?',
              style: TextStyle(fontSize: 15, color: AppTheme.grey600),
            ),
            const SizedBox(height: 32),

            // Star rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return GestureDetector(
                  onTap: () => setState(() => _rating = starIndex),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      starIndex <= _rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 48,
                      color: starIndex <= _rating
                          ? AppTheme.primaryYellow
                          : AppTheme.grey300,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            Text(
              _ratingLabel(_rating),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _rating > 0 ? AppTheme.primaryYellow : AppTheme.grey400,
              ),
            ),
            const SizedBox(height: 32),

            // Comment field
            TextField(
              controller: _commentController,
              maxLines: 5,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Share details about your experience (optional)...',
                hintStyle: TextStyle(color: AppTheme.grey400, fontSize: 14),
                filled: true,
                fillColor: AppTheme.grey50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppTheme.grey200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppTheme.grey200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppTheme.primaryYellow,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 32),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                style: AppTheme.primaryButton,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: AppTheme.black,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Submit Review',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Skip for now',
                style: TextStyle(color: AppTheme.grey500, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _ratingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent!';
      default:
        return 'Tap to rate';
    }
  }
}
