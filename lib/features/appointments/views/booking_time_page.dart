import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../routes/app_routes.dart';
import '../controllers/appointments_controller.dart';

class BookingTimePage extends GetView<AppointmentsController> {
  const BookingTimePage({super.key});

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
          'Select Schedule',
          style: TextStyle(
            color: AppTheme.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: AppTheme.primaryYellow));
        }

        return Column(
          children: [
            _buildProgressIndicator(),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildDateSelection(context)),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: _buildTimeSlots(context),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          ],
        );
      }),
      bottomSheet: _buildContinueButton(),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          _buildProgressStep(1, 'Service', true, true),
          _buildProgressLine(true),
          _buildProgressStep(2, 'DateTime', true, false),
          _buildProgressLine(false),
          _buildProgressStep(3, 'Review', false, false),
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
            color: isActive ? AppTheme.primaryYellow : AppTheme.grey100,
            shape: BoxShape.circle,
            border: isCompleted ? null : Border.all(color: isActive ? AppTheme.primaryYellow : AppTheme.grey300),
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

  Widget _buildDateSelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Choose Date',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.black,
                ),
              ),
              Text(
                _getMonthName(controller.selectedDate.value.month),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryYellow,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 110,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 65,
                  margin: const EdgeInsets.only(right: 12, bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryYellow : AppTheme.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isSelected ? [AppTheme.mediumShadow] : [AppTheme.softShadow],
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryYellow : AppTheme.grey100,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getWeekday(date.weekday),
                        style: TextStyle(
                          color: isSelected ? AppTheme.black : AppTheme.grey500,
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        date.day.toString(),
                        style: TextStyle(
                          color: isSelected ? AppTheme.black : AppTheme.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTimeSlots(BuildContext context) {
    if (controller.timeSlots.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.grey50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.event_busy, size: 64, color: AppTheme.grey300),
              ),
              const SizedBox(height: 24),
              Text(
                'No Slots Available',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.black),
              ),
              const SizedBox(height: 8),
              Text(
                'Try selecting another date.',
                style: TextStyle(color: AppTheme.grey600),
              ),
            ],
          ),
        ),
      );
    }

    final morningSlots = controller.timeSlots.where((s) => s.start.hour < 12).toList();
    final afternoonSlots = controller.timeSlots.where((s) => s.start.hour >= 12 && s.start.hour < 17).toList();
    final eveningSlots = controller.timeSlots.where((s) => s.start.hour >= 17).toList();

    return SliverList(
      delegate: SliverChildListDelegate([
        if (morningSlots.isNotEmpty) ...[
          _buildTimeSection('Morning', Icons.wb_sunny_outlined, morningSlots),
          const SizedBox(height: 24),
        ],
        if (afternoonSlots.isNotEmpty) ...[
          _buildTimeSection('Afternoon', Icons.wb_cloudy_outlined, afternoonSlots),
          const SizedBox(height: 24),
        ],
        if (eveningSlots.isNotEmpty) ...[
          _buildTimeSection('Evening', Icons.nightlight_round_outlined, eveningSlots),
          const SizedBox(height: 24),
        ],
      ]),
    );
  }

  Widget _buildTimeSection(String title, IconData icon, List slots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.primaryYellow),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: slots.length,
          itemBuilder: (context, index) {
            final slot = slots[index];
            final isSelected = controller.selectedTimeSlot.value?.start == slot.start;
            final isAvailable = slot.isAvailable;

            return GestureDetector(
              onTap: isAvailable ? () => controller.selectTimeSlot(slot) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppTheme.primaryYellow 
                      : isAvailable ? AppTheme.white : AppTheme.grey50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected 
                        ? AppTheme.primaryYellow 
                        : isAvailable ? AppTheme.grey200 : AppTheme.grey100,
                  ),
                  boxShadow: isSelected ? [AppTheme.softShadow] : null,
                ),
                child: Center(
                  child: Text(
                    AppDateUtils.formatDisplayTime(slot.start),
                    style: TextStyle(
                      color: isSelected 
                          ? AppTheme.black 
                          : isAvailable ? AppTheme.black : AppTheme.grey400,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (controller.selectedTimeSlot.value != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Selected Slot', style: TextStyle(color: AppTheme.grey500, fontSize: 13)),
                        Text(
                          '${AppDateUtils.formatDisplayDate(controller.selectedTimeSlot.value!.start)} at ${AppDateUtils.formatDisplayTime(controller.selectedTimeSlot.value!.start)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                    Text(
                      AppDateUtils.formatPrice(controller.selectedService.value?.priceCents ?? 0),
                      style: TextStyle(color: AppTheme.primaryYellow, fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ],
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: controller.selectedTimeSlot.value != null
                    ? () => Get.toNamed(AppRoutes.bookingSummary)
                    : null,
                style: AppTheme.primaryButton,
                child: const Text('Review Summary'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getWeekday(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}
