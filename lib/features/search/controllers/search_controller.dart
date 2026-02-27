import 'package:get/get.dart';

import '../../../domain/entities/provider.dart';
import '../../../domain/entities/search_filter.dart';
import '../../../domain/usecases/search/search_providers.dart';
import '../../../core/theme/afro_theme.dart';

class SearchController extends GetxController {
  final SearchProviders searchProviders;

  SearchController({required this.searchProviders});

  // State
  final RxString query = ''.obs;
  final RxString selectedCategory = ''.obs;
  final RxDouble minRating = 0.0.obs;
  final RxDouble maxPrice = 100.0.obs;
  final RxDouble minPrice = 0.0.obs;
  final RxString location = ''.obs;
  final RxList<String> selectedServices = <String>[].obs;
  final RxList<Provider> providers = <Provider>[].obs;
  final RxList<Provider> filteredProviders = <Provider>[].obs;
  final RxBool isLoading = false.obs;

  final List<String> categories = ['All', 'salon', 'barber'];
  final List<String> availableServices = [
    'Haircut',
    'Beard Trim',
    'Hair & Beard',
    'Hot Towel Shave',
    'Hair Coloring',
    'Styling',
  ];

  @override
  void onInit() {
    super.onInit();
    loadProviders();
  }

  Future<void> loadProviders() async {
    try {
      isLoading.value = true;
      final result = await searchProviders(SearchFilter());
      providers.value = result;
      filteredProviders.value = result;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load providers');
    } finally {
      isLoading.value = false;
    }
  }

  void updateQuery(String value) => query.value = value;
  void updateCategory(String value) => selectedCategory.value = value;
  void updateMinRating(double value) => minRating.value = value;
  void updateMaxPrice(double value) => maxPrice.value = value;
  void updateMinPrice(double value) => minPrice.value = value;
  void updateLocation(String value) => location.value = value;

  void toggleService(String service) {
    if (selectedServices.contains(service)) {
      selectedServices.remove(service);
    } else {
      selectedServices.add(service);
    }
    applyFilters();
  }

  void clearFilters() {
    query.value = '';
    selectedCategory.value = '';
    minRating.value = 0.0;
    maxPrice.value = 100.0;
    minPrice.value = 0.0;
    location.value = '';
    selectedServices.clear();
    applyFilters();
  }

  void applyFilters() {
    final filter = SearchFilter(
      query: query.value.isEmpty ? null : query.value,
      category: selectedCategory.value.isEmpty ? null : selectedCategory.value,
      minRating: minRating.value == 0.0 ? null : minRating.value,
      maxPrice: maxPrice.value == 100.0 ? null : maxPrice.value,
      minPrice: minPrice.value == 0.0 ? null : minPrice.value,
      location: location.value.isEmpty ? null : location.value,
      services: selectedServices,
    );

    final filtered = providers.where((provider) {
      bool matches = true;
      
      if (filter.query != null && filter.query!.isNotEmpty) {
        matches = matches && provider.name.toLowerCase().contains(filter.query!.toLowerCase());
      }
      
      if (filter.category != null && matches) {
        matches = matches && provider.category.toLowerCase() == filter.category!.toLowerCase();
      }
      
      if (filter.minRating != null && matches) {
        matches = matches && provider.rating >= filter.minRating!;
      }
      
      if (filter.maxPrice != null && matches) {
        matches = matches; // Would need price comparison
      }
      
      if (filter.minPrice != null && matches) {
        matches = matches; // Would need price comparison
      }
      
      if (filter.location != null && matches) {
        matches = matches && provider.name.toLowerCase().contains(filter.location!.toLowerCase());
      }
      
      if (filter.services.isNotEmpty && matches) {
        matches = matches && filter.services!.every((service) =>
            provider.name.toLowerCase().contains(service.toLowerCase()));
      }
      
      return matches;
    }).toList();

    filteredProviders.value = filtered;
  }

  bool get hasActiveFilters => 
      query.value.isNotEmpty ||
      selectedCategory.value.isNotEmpty ||
      minRating.value > 0.0 ||
      maxPrice.value < 100.0 ||
      minPrice.value > 0.0 ||
      location.value.isNotEmpty ||
      selectedServices.isNotEmpty;
}
