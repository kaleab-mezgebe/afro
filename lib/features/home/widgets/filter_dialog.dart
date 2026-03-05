import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../core/theme/app_theme.dart';

class FilterDialog extends StatelessWidget {
  const FilterDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.black,
                ),
              ),
              TextButton(
                onPressed: () {
                  controller.clearAllFilters();
                },
                child: const Text(
                  'Reset',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Gender Filter
          const Text(
            'Gender',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 12),
          Obx(() => Row(
            children: [
              _buildGenderChip(controller, 'all', 'All'),
              const SizedBox(width: 8),
              _buildGenderChip(controller, 'male', 'Male'),
              const SizedBox(width: 8),
              _buildGenderChip(controller, 'female', 'Female'),
            ],
          )),
          const SizedBox(height: 24),

          // Rating Filter
          const Text(
            'Minimum Rating',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          Obx(() => Slider(
            value: controller.minRating.value,
            min: 0,
            max: 5,
            divisions: 5,
            activeColor: AppTheme.primaryYellow,
            inactiveColor: AppTheme.grey200,
            label: controller.minRating.value.toString(),
            onChanged: (value) => controller.minRating.value = value,
          )),
          const SizedBox(height: 24),

          // Price Range Filter
          const Text(
            'Price Range',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          Obx(() => RangeSlider(
            values: RangeValues(controller.minPrice.value, controller.maxPrice.value),
            min: 0,
            max: 100,
            divisions: 20,
            activeColor: AppTheme.primaryYellow,
            inactiveColor: AppTheme.grey200,
            labels: RangeLabels(
              '\$${controller.minPrice.value.round()}',
              '\$${controller.maxPrice.value.round()}',
            ),
            onChanged: (values) {
              controller.minPrice.value = values.start;
              controller.maxPrice.value = values.end;
            },
          )),
          const SizedBox(height: 32),

          // Apply Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                controller.filtersApplied.value = true;
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.black,
                foregroundColor: AppTheme.primaryYellow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Apply Filters',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildGenderChip(HomeController controller, String value, String label) {
    bool isSelected = controller.selectedGender.value == value;
    return GestureDetector(
      onTap: () => controller.selectedGender.value = value,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.black : AppTheme.grey100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.primaryYellow : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
