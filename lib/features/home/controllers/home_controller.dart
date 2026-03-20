import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/specialist_model.dart';
import '../models/category_model.dart';
import '../../../routes/app_routes.dart';
import '../../../core/services/barber_api_service.dart';

class HomeController extends GetxController {
  final RxString selectedCategory = 'Hairdressing'.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedGender = 'all'.obs;
  final RxDouble minPrice = 0.0.obs;
  final RxDouble maxPrice = 100.0.obs;
  final RxDouble minRating = 0.0.obs;
  final RxBool filtersApplied = false.obs;

  final BarberApiService _barberApiService = Get.find<BarberApiService>();
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSpecialists();
  }

  Future<void> fetchSpecialists() async {
    try {
      isLoading.value = true;
      final specialistsJson = await _barberApiService.getBarbers();
      
      final mappedSpecialists = specialistsJson.map((json) => Specialist(
        id: json['id'] ?? '',
        name: json['name'] ?? 'Unknown',
        price: '\$${json['minPrice'] ?? '0.00'}',
        image: json['imageUrl'] ?? 'https://picsum.photos/seed/${json['id']}/200/200.jpg',
        categories: List<String>.from(json['services']?.map((s) => s.toString()) ?? ['Hairdressing']),
        gender: json['gender'] ?? 'male',
        rating: (json['rating'] ?? 0.0).toDouble(),
      )).toList();

      allSpecialists.assignAll(mappedSpecialists);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch specialists from backend');
    } finally {
      isLoading.value = false;
    }
  }

  final RxList<HomeCategory> categories = <HomeCategory>[
    HomeCategory(
      name: 'All',
      icon: Icons.grid_view_rounded,
      gender: 'all',
      isSelected: true,
    ),
    HomeCategory(name: 'Hairdressing', icon: Icons.content_cut, gender: 'all'),
    HomeCategory(name: 'Hair Color', icon: Icons.color_lens, gender: 'all'),
    HomeCategory(name: 'Beard & Mustache', icon: Icons.face, gender: 'male'),
    HomeCategory(name: 'Makeup', icon: Icons.brush, gender: 'female'),
    HomeCategory(name: 'Shaving', icon: Icons.content_cut, gender: 'male'),
    HomeCategory(name: 'Nail Care', icon: Icons.back_hand, gender: 'female'),
    HomeCategory(name: 'Waxing', icon: Icons.spa, gender: 'all'),
    HomeCategory(name: 'Facial', icon: Icons.face, gender: 'all'),
  ].obs;

  final RxList<Specialist> allSpecialists = <Specialist>[].obs;

  List<Specialist> get filteredSpecialists {
    return allSpecialists.where((specialist) {
      bool categoryMatch =
          selectedCategory.value == 'All' ||
          specialist.categories.contains(selectedCategory.value);
      bool searchMatch =
          searchQuery.value.isEmpty ||
          specialist.name.toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          );
      bool genderMatch =
          selectedGender.value == 'all' ||
          specialist.gender == selectedGender.value;

      // Safe price parsing
      double priceValue = 0.0;
      try {
        priceValue = double.parse(
          specialist.price.replaceAll('\$', '').replaceAll(',', ''),
        );
      } catch (e) {
        priceValue = 0.0;
      }

      bool priceMatch =
          priceValue >= minPrice.value && priceValue <= maxPrice.value;
      bool ratingMatch = specialist.rating >= minRating.value;

      return categoryMatch &&
          searchMatch &&
          genderMatch &&
          priceMatch &&
          ratingMatch;
    }).toList();
  }

  void selectCategory(String categoryName) {
    selectedCategory.value = categoryName;
    for (int i = 0; i < categories.length; i++) {
      categories[i] = categories[i].copyWith(
        isSelected: categories[i].name == categoryName,
      );
    }
  }

  void updateSearch(String query) {
    searchQuery.value = query;
  }

  void clearAllFilters() {
    searchQuery.value = '';
    selectedGender.value = 'all';
    minPrice.value = 0.0;
    maxPrice.value = 100.0;
    minRating.value = 0.0;
    filtersApplied.value = false;
  }

  void navigateToSpecialistDetail(Specialist specialist) {
    Get.toNamed(
      AppRoutes.portfolio,
      arguments: {
        'id': specialist.id,
        'name': specialist.name,
        'image': specialist.image,
        'rating': specialist.rating,
        'categories': specialist.categories,
        'gender': specialist.gender,
        'price': specialist.price,
      },
    );
  }

  void bookSpecialist(Specialist specialist) {
    Get.toNamed(
      AppRoutes.bookingService,
      arguments: {
        'specialist': {
          'id': specialist.id,
          'name': specialist.name,
          'image': specialist.image,
          'rating': specialist.rating,
          'categories': specialist.categories,
          'gender': specialist.gender,
          'price': specialist.price,
        },
        'category': selectedCategory.value,
        'directBooking': true,
      },
    );
  }
}
