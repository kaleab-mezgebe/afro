import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../../../domain/entities/provider.dart';
import '../../../domain/entities/search_filter.dart';
import '../../../domain/usecases/search/search_providers.dart';
import '../../../domain/repositories/search_repository.dart';
import '../../../core/utils/map_helper.dart';
import 'package:flutter/material.dart';

class SearchController extends GetxController {
  final SearchProviders searchProviders;
  final SearchRepository searchRepository; // Add repository for history methods

  SearchController({
    required this.searchProviders,
    required this.searchRepository,
  });

  // State
  final RxString query = ''.obs;
  final RxString selectedCategory = 'All'.obs;
  final RxDouble minRating = 0.0.obs;
  final RxDouble maxPrice = 500.0.obs;
  final RxDouble minPrice = 0.0.obs;
  final RxString location = ''.obs;
  final RxString sortBy = 'rating'.obs; // rating, price, distance, reviews
  final RxBool sortOrder = false.obs; // false = ascending, true = descending
  final RxString availability = 'any'.obs; // any, today, this_week, this_month
  final RxString gender = 'any'.obs; // any, male, female, unisex
  final RxBool onlyOpenNow = false.obs;
  final RxBool onlyFeatured = false.obs;
  final RxBool onlyVerified = false.obs;
  final RxDouble maxDistance = 50.0.obs; // in km
  final RxList<String> selectedServices = <String>[].obs;
  final RxList<Provider> providers = <Provider>[].obs;
  final RxList<Provider> filteredProviders = <Provider>[].obs;
  final RxBool isLoading = false.obs;
  final RxList<String> searchHistory = <String>[].obs;
  final RxBool showMap = false.obs;
  final RxSet<Marker> markers = <Marker>{}.obs;

  final List<String> categories = ['All', 'salon', 'barber'];
  final List<String> availableServices = [
    'Haircut',
    'Beard Trim',
    'Hair & Beard',
    'Hot Towel Shave',
    'Hair Coloring',
    'Styling',
    'Facial',
    'Waxing',
    'Manicure',
    'Pedicure',
    'Hair Treatment',
    'Scalp Massage',
  ];

  final List<String> sortOptions = ['rating', 'price', 'distance', 'reviews'];
  final List<String> availabilityOptions = [
    'any',
    'today',
    'this_week',
    'this_month',
  ];
  final List<String> genderOptions = ['any', 'male', 'female', 'unisex'];

  @override
  void onInit() {
    super.onInit();
    loadProviders();
    loadSearchHistory();
  }

  Future<void> loadProviders() async {
    try {
      isLoading.value = true;
      final filter = SearchFilter(
        query: query.value.isEmpty ? null : query.value,
        category: selectedCategory.value == 'All'
            ? null
            : selectedCategory.value,
        minRating: minRating.value == 0.0 ? null : minRating.value,
        maxPrice: maxPrice.value == 500.0 ? null : maxPrice.value,
        minPrice: minPrice.value == 0.0 ? null : minPrice.value,
        location: location.value.isEmpty ? null : location.value,
        services: selectedServices,
      );

      final result = await searchProviders(filter);
      providers.assignAll(result);
      _applyLocalFilters();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load providers');
    } finally {
      isLoading.value = false;
    }
  }

  void _applyLocalFilters() {
    filteredProviders.assignAll(
      providers.where((provider) {
        // Rating filter
        if (minRating.value > 0 && provider.rating < minRating.value) {
          return false;
        }

        // Price filter
        if (maxPrice.value < 500 && provider.minPrice > maxPrice.value) {
          return false;
        }

        if (minPrice.value > 0 && provider.maxPrice < minPrice.value) {
          return false;
        }

        // Featured filter
        if (onlyFeatured.value && !(provider.isFeatured ?? false)) {
          return false;
        }

        // Verified filter
        if (onlyVerified.value && !(provider.isVerified ?? false)) {
          return false;
        }

        // Gender filter
        if (gender.value != 'any' &&
            provider.gender?.toLowerCase() != gender.value) {
          return false;
        }

        // Services filter
        if (selectedServices.isNotEmpty) {
          final hasMatchingService = selectedServices.any(
            (service) => provider.services.any(
              (providerService) =>
                  providerService.toLowerCase().contains(service.toLowerCase()),
            ),
          );
          if (!hasMatchingService) return false;
        }

        return true;
      }).toList(),
    );

    _applySorting();
    generateMarkers();
  }

  void _applySorting() {
    switch (sortBy.value) {
      case 'rating':
        filteredProviders.sort(
          (a, b) => sortOrder.value
              ? a.rating.compareTo(b.rating)
              : b.rating.compareTo(a.rating),
        );
        break;
      case 'price':
        filteredProviders.sort(
          (a, b) => sortOrder.value
              ? a.minPrice.compareTo(b.minPrice)
              : b.minPrice.compareTo(a.minPrice),
        );
        break;
      case 'distance':
        // For demo purposes, sort by name (in real app, use actual distance)
        filteredProviders.sort(
          (a, b) => sortOrder.value
              ? a.name.compareTo(b.name)
              : b.name.compareTo(a.name),
        );
        break;
      case 'reviews':
        filteredProviders.sort(
          (a, b) => sortOrder.value
              ? (a.reviewCount ?? 0).compareTo(b.reviewCount ?? 0)
              : (b.reviewCount ?? 0).compareTo(a.reviewCount ?? 0),
        );
        break;
    }
  }

  Future<void> loadSearchHistory() async {
    final history = await searchRepository.getSearchHistory();
    searchHistory.assignAll(history);
  }

  Future<void> saveSearch(String q) async {
    if (q.isNotEmpty) {
      await searchRepository.saveSearchHistory(q);
      await loadSearchHistory();
    }
  }

  Future<void> clearHistory() async {
    await searchRepository.clearSearchHistory();
    searchHistory.clear();
  }

  void updateQuery(String value) {
    query.value = value;
    if (value.isEmpty) {
      applyFilters();
    }
  }

  void performSearch() {
    saveSearch(query.value);
    applyFilters();
  }

  void updateCategory(String value) {
    selectedCategory.value = value;
    applyFilters();
  }

  void updateMinRating(double value) => minRating.value = value;
  void updateMaxPrice(double value) => maxPrice.value = value;
  void updateMinPrice(double value) => minPrice.value = value;
  void updateLocation(String value) => location.value = value;
  void updateSortBy(String value) => sortBy.value = value;
  void updateSortOrder(bool value) => sortOrder.value = value;
  void updateAvailability(String value) => availability.value = value;
  void updateGender(String value) => gender.value = value;
  void updateMaxDistance(double value) => maxDistance.value = value;
  void toggleOpenNow() => onlyOpenNow.value = !onlyOpenNow.value;
  void toggleFeatured() => onlyFeatured.value = !onlyFeatured.value;
  void toggleVerified() => onlyVerified.value = !onlyVerified.value;

  void toggleService(String service) {
    if (selectedServices.contains(service)) {
      selectedServices.remove(service);
    } else {
      selectedServices.add(service);
    }
  }

  void clearFilters() {
    query.value = '';
    selectedCategory.value = 'All';
    minRating.value = 0.0;
    maxPrice.value = 500.0;
    minPrice.value = 0.0;
    location.value = '';
    sortBy.value = 'rating';
    sortOrder.value = false;
    availability.value = 'any';
    gender.value = 'any';
    onlyOpenNow.value = false;
    onlyFeatured.value = false;
    onlyVerified.value = false;
    maxDistance.value = 50.0;
    selectedServices.clear();
    applyFilters();
  }

  void applyFilters() {
    loadProviders();
  }

  bool get hasActiveFilters => activeFilterCount > 0;

  int get activeFilterCount {
    int count = 0;
    if (query.value.isNotEmpty) count++;
    if (selectedCategory.value != 'All') count++;
    if (minRating.value > 0.0) count++;
    if (maxPrice.value < 500.0) count++;
    if (minPrice.value > 0.0) count++;
    if (location.value.isNotEmpty) count++;
    if (selectedServices.isNotEmpty) count++;
    if (onlyOpenNow.value) count++;
    if (onlyFeatured.value) count++;
    if (onlyVerified.value) count++;
    if (availability.value != 'any') count++;
    if (gender.value != 'any') count++;
    if (maxDistance.value < 50.0) count++;
    return count;
  }

  void toggleMap() {
    showMap.value = !showMap.value;
    if (showMap.value) {
      generateMarkers();
    }
  }

  Future<void> generateMarkers() async {
    final Set<Marker> newMarkers = {};
    for (var provider in filteredProviders) {
      final marker = await _createMarker(provider);
      newMarkers.add(marker);
    }
    markers.value = newMarkers;
  }

  Future<Marker> _createMarker(Provider provider) async {
    final icon = await MapHelper.getMarkerIcon(
      provider.imageUrl ?? 'https://picsum.photos/seed/${provider.id}/200/200',
      const Size(100, 100),
    );

    return Marker(
      markerId: MarkerId(provider.id),
      position: LatLng(
        9.03 + (double.tryParse(provider.id) ?? 0) * 0.01,
        38.74 + (double.tryParse(provider.id) ?? 0) * 0.01,
      ),
      onTap: () {
        // Optional: Show provider detail card or navigate
      },
      icon: icon,
    );
  }
}
