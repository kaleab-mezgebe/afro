import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/services/appointment_api_service.dart';
import '../../../domain/entities/booking.dart';
import '../../../routes/app_routes.dart';
import '../controllers/appointments_controller.dart';

// ─── Palette ────────────────────────────────────────────────────────────────
const _yellow = AppTheme.primaryYellow;
const _black = AppTheme.black;

class BookingHistoryPage extends GetView<AppointmentsController> {
  const BookingHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Appointments',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: _black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: _yellow),
            onPressed: controller.loadBookingHistory,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.bookings.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: _yellow));
        }
        if (controller.error.value.isNotEmpty) {
          return _ErrorState(controller: controller);
        }
        if (controller.bookings.isEmpty) {
          return _EmptyState();
        }

        final now = DateTime.now();
        final upcoming = controller.bookings
            .where(
              (b) =>
                  b.start.isAfter(now) ||
                  b.status == BookingStatus.confirmed ||
                  b.status == BookingStatus.pending,
            )
            .toList();
        final past = controller.bookings
            .where(
              (b) =>
                  b.start.isBefore(now) &&
                  b.status != BookingStatus.confirmed &&
                  b.status != BookingStatus.pending,
            )
            .toList();

        return RefreshIndicator(
          onRefresh: controller.loadBookingHistory,
          color: _yellow,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              if (upcoming.isNotEmpty) ...[
                _sectionHeader('Upcoming'),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _BookingCard(
                        booking: upcoming[i],
                        isUpcoming: true,
                        onTap: () => _showDetail(ctx, upcoming[i]),
                      ),
                      childCount: upcoming.length,
                    ),
                  ),
                ),
              ],
              if (past.isNotEmpty) ...[
                _sectionHeader('Past'),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _BookingCard(
                        booking: past[i],
                        isUpcoming: false,
                        onTap: () => _showDetail(ctx, past[i]),
                      ),
                      childCount: past.length,
                    ),
                  ),
                ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        );
      }),
    );
  }

  SliverToBoxAdapter _sectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: _black,
            letterSpacing: -0.3,
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, Booking booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _AppointmentDetailSheet(booking: booking, controller: controller),
    );
  }
}

// ─── Booking Card ────────────────────────────────────────────────────────────
class _BookingCard extends StatelessWidget {
  final Booking booking;
  final bool isUpcoming;
  final VoidCallback onTap;

  const _BookingCard({
    required this.booking,
    required this.isUpcoming,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(booking.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Status bar
                Container(width: 5, color: statusColor),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Avatar
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: _yellow.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                color: _yellow,
                                size: 22,
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
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: _black,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    booking.service.name,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.grey500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            // Status badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _statusLabel(booking.status),
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 13,
                              color: AppTheme.grey400,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              AppDateUtils.formatDisplayDate(booking.start),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.grey600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.access_time_rounded,
                              size: 13,
                              color: AppTheme.grey400,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              AppDateUtils.formatDisplayTime(booking.start),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.grey600,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 18,
                              color: AppTheme.grey400,
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
        ),
      ),
    );
  }
}

// ─── Detail Bottom Sheet ─────────────────────────────────────────────────────
class _AppointmentDetailSheet extends StatelessWidget {
  final Booking booking;
  final AppointmentsController controller;

  const _AppointmentDetailSheet({
    required this.booking,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(booking.status);
    final now = DateTime.now();
    final isUpcoming =
        booking.start.isAfter(now) ||
        booking.status == BookingStatus.confirmed ||
        booking.status == BookingStatus.pending;
    final canCancel =
        isUpcoming &&
        booking.status != BookingStatus.cancelled &&
        booking.start.difference(now).inHours >= 2;
    final canReschedule = canCancel;
    final canReview = !isUpcoming && booking.status == BookingStatus.completed;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.grey300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 20),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _yellow.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: _yellow,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.provider.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: _black,
                        ),
                      ),
                      Text(
                        booking.service.name,
                        style: TextStyle(fontSize: 14, color: AppTheme.grey500),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _statusLabel(booking.status),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _detailRow(
                  Icons.calendar_today_rounded,
                  'Date',
                  AppDateUtils.formatDisplayDate(booking.start),
                ),
                const SizedBox(height: 14),
                _detailRow(
                  Icons.access_time_rounded,
                  'Time',
                  '${AppDateUtils.formatDisplayTime(booking.start)} – ${AppDateUtils.formatDisplayTime(booking.end)}',
                ),
                const SizedBox(height: 14),
                _detailRow(
                  Icons.content_cut_rounded,
                  'Service',
                  booking.service.name,
                ),
                const SizedBox(height: 14),
                _detailRow(
                  Icons.timer_outlined,
                  'Duration',
                  '${booking.service.durationMinutes} min',
                ),
                // Show price from totalPriceCents or fall back to service.priceCents
                if (booking.totalPriceCents > 0 ||
                    booking.service.priceCents > 0) ...[
                  const SizedBox(height: 14),
                  _detailRow(
                    Icons.payments_outlined,
                    'Price',
                    AppDateUtils.formatPrice(
                      booking.totalPriceCents > 0
                          ? booking.totalPriceCents
                          : booking.service.priceCents,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                _detailRow(
                  Icons.confirmation_number_outlined,
                  'Booking ID',
                  booking.id.substring(0, 8).toUpperCase(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                if (canReschedule)
                  _actionButton(
                    icon: Icons.edit_calendar_rounded,
                    label: 'Reschedule',
                    color: _black,
                    textColor: Colors.white,
                    onTap: () {
                      Navigator.pop(context);
                      _showRescheduleSheet(context);
                    },
                  ),
                if (canReschedule) const SizedBox(height: 10),
                if (canReview)
                  _actionButton(
                    icon: Icons.star_rounded,
                    label: 'Leave a Review',
                    color: _yellow,
                    textColor: _black,
                    onTap: () {
                      Navigator.pop(context);
                      Get.toNamed(
                        AppRoutes.reviewSubmission,
                        arguments: {
                          'barberId': booking.provider.id,
                          'appointmentId': booking.id,
                          'barberName': booking.provider.name,
                        },
                      );
                    },
                  ),
                if (canReview) const SizedBox(height: 10),
                if (canCancel)
                  _actionButton(
                    icon: Icons.cancel_outlined,
                    label: 'Cancel Appointment',
                    color: const Color(0xFFFFF0F0),
                    textColor: AppTheme.error,
                    onTap: () => _confirmCancel(context),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppTheme.grey500),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.grey400,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: textColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Cancel Appointment',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('Cancel your appointment with ${booking.provider.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Keep It',
              style: TextStyle(color: AppTheme.greyMedium),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx); // close dialog
              Navigator.pop(context); // close sheet
              try {
                final svc = Get.find<AppointmentApiService>();
                await svc.cancelAppointment(
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
                ErrorHandler.handleError(e);
              }
            },
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
  }

  void _showRescheduleSheet(BuildContext context) {
    DateTime selectedDate = booking.start;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 4, 24, 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Reschedule Appointment',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: _black,
                    ),
                  ),
                ),
              ),
              // Date picker
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime.now().add(const Duration(hours: 2)),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                      builder: (_, child) => Theme(
                        data: ThemeData.light().copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: _yellow,
                            onPrimary: _black,
                          ),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) setState(() => selectedDate = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          color: _yellow,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          AppDateUtils.formatDisplayDate(selectedDate),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _black,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppTheme.grey400,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GestureDetector(
                  onTap: () async {
                    Navigator.pop(ctx);
                    try {
                      final svc = Get.find<AppointmentApiService>();
                      await svc.rescheduleAppointment(booking.id, selectedDate);
                      await controller.loadBookingHistory();
                      Get.snackbar(
                        'Rescheduled',
                        'Your appointment has been rescheduled.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppTheme.success,
                        colorText: Colors.white,
                      );
                    } catch (e) {
                      ErrorHandler.handleError(e);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: _yellow,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        'Confirm Reschedule',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: _black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────
Color _statusColor(BookingStatus status) {
  switch (status) {
    case BookingStatus.pending:
      return Colors.orange;
    case BookingStatus.confirmed:
      return Colors.green;
    case BookingStatus.completed:
      return AppTheme.primaryYellow;
    case BookingStatus.cancelled:
      return Colors.red;
  }
}

String _statusLabel(BookingStatus status) {
  switch (status) {
    case BookingStatus.pending:
      return 'Pending';
    case BookingStatus.confirmed:
      return 'Confirmed';
    case BookingStatus.completed:
      return 'Completed';
    case BookingStatus.cancelled:
      return 'Cancelled';
  }
}

// ─── Empty / Error states ────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
}

class _ErrorState extends StatelessWidget {
  final AppointmentsController controller;
  const _ErrorState({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppTheme.error),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
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
}
