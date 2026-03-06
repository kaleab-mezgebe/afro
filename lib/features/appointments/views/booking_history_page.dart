import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/entities/booking.dart';
import '../../../routes/app_routes.dart';
import '../controllers/appointments_controller.dart';

class BookingHistoryPage extends GetView<AppointmentsController> {
  const BookingHistoryPage({super.key});

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
            .where((b) => b.start.isAfter(now) || b.status == BookingStatus.confirmed)
            .toList();
        final pastBookings = controller.bookings
            .where((b) => b.start.isBefore(now) && b.status != BookingStatus.confirmed)
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
                      (context, index) => _buildBookingCard(context, upcomingBookings[index], isUpcoming: true),
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
                      (context, index) => _buildBookingCard(context, pastBookings[index], isUpcoming: false),
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

  Widget _buildBookingCard(BuildContext context, Booking booking, {required bool isUpcoming}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          isUpcoming ? AppTheme.mediumShadow : AppTheme.softShadow,
        ],
        border: Border.all(
          color: isUpcoming ? AppTheme.primaryYellow.withValues(alpha: 0.1) : AppTheme.grey100,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Row(
          children: [
            // Left Accent - specific to status or upcoming
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
                        // Avatar-style Circle
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppTheme.grey50,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.grey200, width: 2),
                          ),
                          child: Icon(Icons.person, color: AppTheme.primaryYellow),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.provider.name,
                                style: TextStyle(
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
                            Icon(Icons.calendar_today_outlined, size: 14, color: AppTheme.grey500),
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
                            Icon(Icons.access_time, size: 14, color: AppTheme.grey500),
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
                          style: TextStyle(
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
            child: Icon(Icons.calendar_month_outlined, size: 80, color: AppTheme.grey200),
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
          Text(controller.error.value, style: TextStyle(color: AppTheme.grey600)),
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
    return Center(child: CircularProgressIndicator(color: AppTheme.primaryYellow));
  }
}
