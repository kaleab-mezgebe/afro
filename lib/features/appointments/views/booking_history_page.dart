import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/services/appointment_api_service.dart';
import '../../../domain/entities/booking.dart';
import '../../../routes/app_routes.dart';
import '../controllers/appointments_controller.dart';

class BookingHistoryPage extends GetView<AppointmentsController> {
  const BookingHistoryPage({super.key});

  Future<void> _cancelAppointment(BuildContext context, Booking booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Cancel Appointment',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to cancel your appointment with ${booking.provider.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Keep It',
              style: TextStyle(color: AppTheme.greyMedium),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final appointmentService = Get.find<AppointmentApiService>();
      await appointmentService.cancelAppointment(
        booking.id,
        reason: 'Customer cancelled',
      );
      await controller.loadBookingHistory();
      Get.snackbar(
        'Cancelled',
        'Your appointment has been cancelled.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.success,
        colorText: Colors.white,
      );
    } catch (e) {
      ErrorHandler.handleError(
        e,
        onRetry: () => _cancelAppointment(context, booking),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text(
          'My Appointments',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppTheme.primaryYellow),
            onPressed: controller.loadBookingHistory,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.bookings.isEmpty) {
          return _buildShimmerLoading();
        }

        if (controller.error.value.isNotEmpty) {
          return _buildErrorState(context);
        }

        if (controller.bookings.isEmpty) {
          return _buildEmptyState(context);
        }

        final now = DateTime.now();
        final upcomingBookings = controller.bookings
            .where(
              (b) =>
                  b.start.isAfter(now) || b.status == BookingStatus.confirmed,
            )
            .toList();
        final pastBookings = controller.bookings
            .where(
              (b) =>
                  b.start.isBefore(now) && b.status != BookingStatus.confirmed,
            )
            .toList();

        return RefreshIndicator(
          onRefresh: controller.loadBookingHistory,
          color: AppTheme.primaryYellow,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              if (upcomingBookings.isNotEmpty) ...[
                _buildSectionHeader('Upcoming Appointments'),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildBookingCard(
                        context,
                        upcomingBookings[index],
                        isUpcoming: true,
                      ),
                      childCount: upcomingBookings.length,
                    ),
                  ),
                ),
              ],
              if (pastBookings.isNotEmpty) ...[
                _buildSectionHeader('Past Experience'),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildBookingCard(
                        context,
                        pastBookings[index],
                        isUpcoming: false,
                      ),
                      childCount: pastBookings.length,
                    ),
                  ),
                ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.black,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(
    BuildContext context,
    Booking booking, {
    required bool isUpcoming,
  }) {
    final canCancel =
        isUpcoming &&
        booking.status != BookingStatus.cancelled &&
        booking.start.difference(DateTime.now()).inHours >= 2;
    final canReview = !isUpcoming && booking.status == BookingStatus.completed;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [isUpcoming ? AppTheme.mediumShadow : AppTheme.softShadow],
        border: Border.all(
          color: isUpcoming
              ? AppTheme.primaryYellow.withValues(alpha: 0.1)
              : AppTheme.grey100,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 6,
                  height: 120,
                  color: _getStatusColor(booking.status),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppTheme.grey50,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.grey200,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.person,
                                color: AppTheme.primaryYellow,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    booking.provider.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.black,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    booking.service.name,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.grey600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildStatusBadge(booking.status),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 14,
                                  color: AppTheme.grey500,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  AppDateUtils.formatDisplayDate(booking.start),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.grey700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: AppTheme.grey500,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  AppDateUtils.formatDisplayTime(booking.start),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.grey700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              AppDateUtils.formatPrice(booking.totalPriceCents),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryYellow,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (canCancel || canReview)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  children: [
                    if (canReview)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Get.toNamed(
                            AppRoutes.reviewSubmission,
                            arguments: {
                              'barberId': booking.provider.id,
                              'appointmentId': booking.id,
                              'barberName': booking.provider.name,
                            },
                          ),
                          icon: const Icon(
                            Icons.star_outline_rounded,
                            size: 16,
                          ),
                          label: const Text('Leave Review'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryYellow,
                            side: const BorderSide(
                              color: AppTheme.primaryYellow,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    if (canCancel) ...[
                      if (canReview) const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _cancelAppointment(context, booking),
                          icon: const Icon(Icons.cancel_outlined, size: 16),
                          label: const Text('Cancel'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.error,
                            side: const BorderSide(color: AppTheme.error),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BookingStatus status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.name.capitalizeFirst!,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return Colors.green;
      case BookingStatus.completed:
        return AppTheme.primaryYellow;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.pending:
        return Colors.orange;
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.grey50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.calendar_month_outlined,
              size: 80,
              color: AppTheme.grey200,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Appointments Yet',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Experience the best services today.',
            style: TextStyle(color: AppTheme.grey600),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => Get.offAllNamed(AppRoutes.home),
            style: AppTheme.primaryButton,
            child: const Text('Book Your First Experience'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppTheme.error),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            controller.error.value,
            style: TextStyle(color: AppTheme.grey600),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: controller.loadBookingHistory,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Center(
      child: CircularProgressIndicator(color: AppTheme.primaryYellow),
    );
  }
}
