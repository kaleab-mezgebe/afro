import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/date_utils.dart';
import '../../../routes/app_routes.dart';
import '../controllers/appointments_controller.dart';

class BookingTimePage extends GetView<AppointmentsController> {
  const BookingTimePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Time'),
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
                  onPressed: () => controller.loadAvailability(
                    providerId: controller.selectedProvider.value!.id,
                    serviceId: controller.selectedService.value!.id,
                    date: controller.selectedDate.value,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            _buildDateSelection(context),
            Expanded(child: _buildTimeSlots(context)),
            _buildContinueButton(),
          ],
        );
      }),
    );
  }

  Widget _buildDateSelection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Date', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 30,
              itemBuilder: (context, index) {
                final date = DateTime.now().add(Duration(days: index));
                final isSelected =
                    controller.selectedDate.value.year == date.year &&
                    controller.selectedDate.value.month == date.month &&
                    controller.selectedDate.value.day == date.day;

                return GestureDetector(
                  onTap: () => controller.selectDate(date),
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getWeekday(date.weekday),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLegendItem(
            context,
            'Available',
            Colors.white,
            Theme.of(context).primaryColor.withOpacity(0.2),
            Icons.check_circle_outline,
            Colors.green[600]!,
          ),
          const SizedBox(width: 8),
          _buildLegendItem(
            context,
            'Reserved',
            Colors.grey[50]!,
            Colors.grey[200]!,
            Icons.lock_outline,
            Colors.grey[500]!,
          ),
          const SizedBox(width: 8),
          _buildLegendItem(
            context,
            'Selected',
            Theme.of(context).primaryColor,
            Colors.transparent,
            Icons.check_circle,
            Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    String label,
    Color backgroundColor,
    Color borderColor,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: icon == Icons.check_circle
                  ? Colors.white
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(icon, size: 10, color: iconColor),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: label == 'Selected' ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlots(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daily Schedule',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              _buildLegend(context),
            ],
          ),
          const SizedBox(height: 16),
          if (controller.timeSlots.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Icon(
                        Icons.calendar_today_outlined,
                        size: 56,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No Available Time Slots',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'All time slots are reserved for this date',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            size: 16,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Try selecting a different date',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: _groupTimeSlotsByHour(controller.timeSlots).map((
                    hourGroup,
                  ) {
                    return _buildHourBlock(
                      context,
                      hourGroup['hour'] as int,
                      hourGroup['slots'] as List,
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _groupTimeSlotsByHour(List timeSlots) {
    Map<int, List> hourGroups = {};

    for (var timeSlot in timeSlots) {
      final hour = timeSlot.start.hour;
      if (!hourGroups.containsKey(hour)) {
        hourGroups[hour] = [];
      }
      hourGroups[hour]!.add(timeSlot);
    }

    // Sort by hour and convert to list
    final sortedHours = hourGroups.keys.toList()..sort();
    return sortedHours
        .map((hour) => {'hour': hour, 'slots': hourGroups[hour]!})
        .toList();
  }

  Widget _buildHourBlock(BuildContext context, int hour, List slots) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hour header with table-like appearance
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // Time column
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 18,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${hour.toString().padLeft(2, '0')}:00',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                // Divider
                Container(
                  width: 1,
                  height: 20,
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                ),
                // Status column
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      '${slots.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // Divider
                Container(
                  width: 1,
                  height: 20,
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                ),
                // Availability column
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      '${slots.where((s) => s.isAvailable).length}/${slots.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Time slots in table rows
          ...slots.asMap().entries.map((entry) {
            final index = entry.key;
            final timeSlot = entry.value;
            final isSelected =
                controller.selectedTimeSlot.value?.start == timeSlot.start;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : index % 2 == 0
                    ? Colors.grey[50]
                    : Colors.transparent,
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
              ),
              child: Row(
                children: [
                  // Time column
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppDateUtils.formatDisplayTime(timeSlot.start),
                          style: TextStyle(
                            color: !timeSlot.isAvailable
                                ? Colors.grey[500]
                                : isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.black87,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '- ${AppDateUtils.formatDisplayTime(timeSlot.end)}',
                          style: TextStyle(
                            color: !timeSlot.isAvailable
                                ? Colors.grey[400]
                                : isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.black54,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Divider
                  Container(width: 1, color: Colors.grey[200]!),
                  // Status column
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: !timeSlot.isAvailable
                              ? Colors.grey[200]
                              : Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              !timeSlot.isAvailable
                                  ? Icons.lock_outline
                                  : Icons.check_circle_outline,
                              size: 12,
                              color: !timeSlot.isAvailable
                                  ? Colors.grey[500]
                                  : Colors.green[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              !timeSlot.isAvailable ? 'Reserved' : 'Available',
                              style: TextStyle(
                                fontSize: 10,
                                color: !timeSlot.isAvailable
                                    ? Colors.grey[500]
                                    : Colors.green[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Divider
                  Container(width: 1, color: Colors.grey[200]!),
                  // Action column
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: GestureDetector(
                        onTap: timeSlot.isAvailable
                            ? () => controller.selectTimeSlot(timeSlot)
                            : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: !timeSlot.isAvailable
                                ? Colors.grey[100]
                                : isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: !timeSlot.isAvailable
                                  ? Colors.grey[300]!
                                  : isSelected
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(
                                      context,
                                    ).primaryColor.withOpacity(0.3),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (!timeSlot.isAvailable)
                                Icon(
                                  Icons.lock,
                                  size: 14,
                                  color: Colors.grey[500],
                                )
                              else if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  size: 14,
                                  color: Colors.white,
                                )
                              else
                                Icon(
                                  Icons.add_circle_outline,
                                  size: 14,
                                  color: Theme.of(context).primaryColor,
                                ),
                              const SizedBox(width: 6),
                              Text(
                                !timeSlot.isAvailable
                                    ? 'Booked'
                                    : isSelected
                                    ? 'Selected'
                                    : 'Select',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: !timeSlot.isAvailable
                                      ? Colors.grey[500]
                                      : isSelected
                                      ? Colors.white
                                      : Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Obx(
        () => ElevatedButton(
          onPressed: controller.selectedTimeSlot.value != null
              ? () => Get.toNamed(AppRoutes.bookingSummary)
              : null,
          child: const Text('Continue to Summary'),
        ),
      ),
    );
  }

  String _getWeekday(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}
