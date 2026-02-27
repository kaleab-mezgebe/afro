import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/date_utils.dart';
import '../controllers/booking_controller.dart';

class BookingTimePage extends GetView<BookingController> {
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
            // Date Selection
            _buildDateSelection(context),
            // Time Slots
            Expanded(
              child: _buildTimeSlots(context),
            ),
            // Continue Button
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
          Text(
            'Select Date',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 30, // Show next 30 days
              itemBuilder: (context, index) {
                final date = DateTime.now().add(Duration(days: index));
                final isSelected = controller.selectedDate.value.year == date.year &&
                    controller.selectedDate.value.month == date.month &&
                    controller.selectedDate.value.day == date.day;
                
                return GestureDetector(
                  onTap: () => controller.selectDate(date),
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
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

  Widget _buildTimeSlots(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Time Slots',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          if (controller.timeSlots.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  'No available time slots for selected date',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: controller.timeSlots.length,
                itemBuilder: (context, index) {
                  final timeSlot = controller.timeSlots[index];
                  final isSelected = controller.selectedTimeSlot.value?.start == timeSlot.start;
                  
                  return GestureDetector(
                    onTap: timeSlot.isAvailable
                        ? () => controller.selectTimeSlot(timeSlot)
                        : null,
                    child: Container(
                      decoration: BoxDecoration(
                        color: !timeSlot.isAvailable
                            ? Colors.grey[300]
                            : isSelected
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          AppDateUtils.formatDisplayTime(timeSlot.start),
                          style: TextStyle(
                            color: !timeSlot.isAvailable
                                ? Colors.grey[600]
                                : isSelected
                                    ? Colors.white
                                    : Theme.of(context).primaryColor,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
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

  Widget _buildContinueButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Obx(() => ElevatedButton(
        onPressed: controller.selectedTimeSlot.value != null
            ? () => Get.toNamed('/booking/summary')
            : null,
        child: const Text('Continue to Summary'),
      )),
    );
  }

  String _getWeekday(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}
