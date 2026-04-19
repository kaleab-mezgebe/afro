import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../routes/app_routes.dart';
import '../controllers/appointments_controller.dart';

class BookingTimePage extends GetView<AppointmentsController> {
  const BookingTimePage({super.key});

  static const _yellow = AppTheme.primaryYellow;
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  Widget build(BuildContext context) {
    // Load availability for today as soon as the page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.timeSlots.isEmpty &&
          controller.selectedProvider.value != null &&
          controller.selectedService.value != null) {
        controller.loadAvailability(
          providerId: controller.selectedProvider.value!.id,
          serviceId: controller.selectedService.value!.id,
          date: controller.selectedDate.value,
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Colors.black,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Select Date & Time',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCalendar(),
                    const SizedBox(height: 24),
                    _buildTimeSlotsSection(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        );
      }),
    );
  }

  // ─── CALENDAR ────────────────────────────────────────────────────────────
  Widget _buildCalendar() {
    final now = DateTime.now();
    final selected = controller.selectedDate.value;
    // Use a local display month — track via the selected date's month
    final displayMonth = DateTime(selected.year, selected.month, 1);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Month header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    final prev = DateTime(
                      displayMonth.year,
                      displayMonth.month - 1,
                      1,
                    );
                    if (!prev.isBefore(DateTime(now.year, now.month, 1))) {
                      controller.selectDate(
                        DateTime(
                          prev.year,
                          prev.month,
                          selected.day.clamp(
                            1,
                            _daysInMonth(prev.year, prev.month),
                          ),
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Text(
                  '${_months[displayMonth.month - 1]} ${displayMonth.year}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    final next = DateTime(
                      displayMonth.year,
                      displayMonth.month + 1,
                      1,
                    );
                    controller.selectDate(DateTime(next.year, next.month, 1));
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Day headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: _days
                  .map(
                    (d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: d == 'Sat' || d == 'Sun'
                                ? Colors.red.shade300
                                : AppTheme.grey500,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          // Calendar grid
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: _buildCalendarGrid(displayMonth, selected, now),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(
    DateTime displayMonth,
    DateTime selected,
    DateTime now,
  ) {
    final firstDay = displayMonth;
    // weekday: 1=Mon, 7=Sun — offset to align grid
    final startOffset = (firstDay.weekday - 1) % 7;
    final daysInMonth = _daysInMonth(displayMonth.year, displayMonth.month);
    final totalCells = startOffset + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rows, (row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: List.generate(7, (col) {
              final cellIndex = row * 7 + col;
              final dayNum = cellIndex - startOffset + 1;

              if (dayNum < 1 || dayNum > daysInMonth) {
                return const Expanded(child: SizedBox(height: 40));
              }

              final date = DateTime(
                displayMonth.year,
                displayMonth.month,
                dayNum,
              );
              final isToday = AppDateUtils.isSameDay(date, now);
              final isSelected = AppDateUtils.isSameDay(date, selected);
              final isPast = date.isBefore(
                DateTime(now.year, now.month, now.day),
              );
              final isWeekend = date.weekday == 6 || date.weekday == 7;

              return Expanded(
                child: GestureDetector(
                  onTap: isPast ? null : () => controller.selectDate(date),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 40,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _yellow
                          : isToday
                          ? _yellow.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '$dayNum',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected || isToday
                              ? FontWeight.w800
                              : FontWeight.w500,
                          color: isSelected
                              ? Colors.black
                              : isPast
                              ? AppTheme.grey300
                              : isWeekend
                              ? Colors.red.shade400
                              : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  int _daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  // ─── TIME SLOTS ──────────────────────────────────────────────────────────
  Widget _buildTimeSlotsSection() {
    final selected = controller.selectedDate.value;
    final dateLabel = AppDateUtils.formatDisplayDate(selected);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Available Times',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _yellow.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                dateLabel,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (controller.isLoading.value)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: _yellow),
            ),
          )
        else if (controller.timeSlots.isEmpty)
          _buildNoSlots()
        else
          _buildSlotGroups(),
      ],
    );
  }

  Widget _buildNoSlots() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.event_busy_rounded, size: 52, color: AppTheme.grey300),
          const SizedBox(height: 12),
          const Text(
            'No slots available',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try a different date',
            style: TextStyle(fontSize: 13, color: AppTheme.grey500),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotGroups() {
    final morning = controller.timeSlots
        .where((s) => s.start.hour < 12)
        .toList();
    final afternoon = controller.timeSlots
        .where((s) => s.start.hour >= 12 && s.start.hour < 17)
        .toList();
    final evening = controller.timeSlots
        .where((s) => s.start.hour >= 17)
        .toList();

    return Column(
      children: [
        if (morning.isNotEmpty)
          _slotGroup('Morning', Icons.wb_sunny_outlined, morning),
        if (afternoon.isNotEmpty) ...[
          const SizedBox(height: 16),
          _slotGroup('Afternoon', Icons.wb_cloudy_outlined, afternoon),
        ],
        if (evening.isNotEmpty) ...[
          const SizedBox(height: 16),
          _slotGroup('Evening', Icons.nightlight_round_outlined, evening),
        ],
      ],
    );
  }

  Widget _slotGroup(String title, IconData icon, List slots) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: _yellow),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${slots.where((s) => s.isAvailable).length} available',
                style: TextStyle(fontSize: 12, color: AppTheme.grey500),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: slots.map((slot) {
              final isSelected =
                  controller.selectedTimeSlot.value?.start == slot.start;
              final isAvailable = slot.isAvailable as bool;

              return GestureDetector(
                onTap: isAvailable
                    ? () => controller.selectTimeSlot(slot)
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _yellow
                        : isAvailable
                        ? const Color(0xFFF5F5F5)
                        : const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? _yellow : Colors.transparent,
                      width: isSelected ? 0 : 0,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: _yellow.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    AppDateUtils.formatDisplayTime(slot.start),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                      color: isSelected
                          ? Colors.black
                          : isAvailable
                          ? Colors.black87
                          : AppTheme.grey300,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ─── BOTTOM BAR ──────────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    final slot = controller.selectedTimeSlot.value;
    final hasSlot = slot != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Row(
            children: [
              if (hasSlot) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Selected',
                      style: TextStyle(fontSize: 11, color: AppTheme.grey500),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppDateUtils.formatDisplayTime(slot.start),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      AppDateUtils.formatDisplayDate(slot.start),
                      style: TextStyle(fontSize: 11, color: AppTheme.grey500),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: GestureDetector(
                  onTap: hasSlot
                      ? () => Get.toNamed(AppRoutes.bookingSummary)
                      : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: hasSlot ? _yellow : AppTheme.grey200,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: hasSlot
                          ? [
                              BoxShadow(
                                color: _yellow.withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        hasSlot ? 'Continue' : 'Select a time slot',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: hasSlot ? Colors.black : AppTheme.grey500,
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
