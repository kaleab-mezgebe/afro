import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/specialist_model.dart';
import '../models/category_model.dart';
import '../../../routes/app_routes.dart';
import '../../../core/services/barber_api_service.dart';
import '../../../core/utils/error_handler.dart';

class HomeController extends GetxController {
  final RxString selectedCategory = 'All'.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedGender = 'all'.obs;
  final RxDouble minPrice = 0.0.obs;
  final RxDouble maxPrice = 10000.0.obs;
  final RxDouble minRating = 0.0.obs;
  final RxBool filtersApplied = false.obs;

  final BarberApiService _barberApiService = Get.find<BarberApiService>();
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSpecialists();
  }

  Future<void> fetchSpecialists() async {
    try {
      isLoading.value = true;
      error.value = '';
      final specialistsJson = await _barberApiService.getBarbers();

      final mappedSpecialists = specialistsJson.map((json) {
        // Safely parse services list
        List<String> cats = ['Hairdressing'];
        final rawServices = json['services'];
        if (rawServices is List && rawServices.isNotEmpty) {
          cats = rawServices.map((s) => s.toString()).toList();
        }

        // Safely parse price — backend returns dollar value directly
        final rawPrice =
            json['minPrice'] ?? json['price'] ?? json['startingPrice'] ?? 0;
        final priceDouble = double.tryParse(rawPrice.toString()) ?? 0.0;
        final priceStr = priceDouble == priceDouble.truncateToDouble()
            ? priceDouble.toInt().toString()
            : priceDouble.toStringAsFixed(2);

        // Safely parse rating
        final rawRating = json['rating'];
        double rating = 0.0;
        if (rawRating != null) {
          rating = double.tryParse(rawRating.toString()) ?? 0.0;
        }

        return Specialist(
          id: json['id']?.toString() ?? '',
          name: json['name']?.toString() ?? 'Unknown',
          price: '\$$priceStr',
          image:
              json['imageUrl']?.toString() ??
              'https://picsum.photos/seed/${json['id']}/200/200',
          categories: cats,
          gender: json['gender']?.toString() ?? 'unisex',
          rating: rating,
        );
      }).toList();

      allSpecialists.assignAll(mappedSpecialists);
    } catch (e) {
      error.value = ErrorHandler.getErrorMessage(e);
      ErrorHandler.handleError(e, onRetry: fetchSpecialists);
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
    HomeCategory(name: 'Barber', icon: Icons.content_cut, gender: 'male'),
    HomeCategory(
      name: 'Hair Stylist',
      icon: Icons.face_retouching_natural,
      gender: 'female',
    ),
    HomeCategory(name: 'Hair Color', icon: Icons.color_lens, gender: 'all'),
    HomeCategory(name: 'Beard', icon: Icons.face, gender: 'male'),
    HomeCategory(name: 'Nails', icon: Icons.back_hand, gender: 'all'),
    HomeCategory(name: 'Makeup', icon: Icons.brush, gender: 'all'),
    HomeCategory(name: 'Lashes', icon: Icons.remove_red_eye, gender: 'all'),
    HomeCategory(name: 'Brows', icon: Icons.auto_fix_high, gender: 'all'),
    HomeCategory(name: 'Skin Care', icon: Icons.spa, gender: 'all'),
    HomeCategory(name: 'Massage', icon: Icons.self_improvement, gender: 'all'),
    HomeCategory(name: 'Waxing', icon: Icons.waves, gender: 'all'),
    HomeCategory(name: 'Threading', icon: Icons.linear_scale, gender: 'all'),
  ].obs;

  final RxList<Specialist> allSpecialists = <Specialist>[].obs;

  List<Specialist> get filteredSpecialists {
    return allSpecialists.where((specialist) {
      // Category filter
      final categoryMatch =
          selectedCategory.value == 'All' ||
          specialist.categories.any(
            (c) =>
                c.toLowerCase().contains(
                  selectedCategory.value.toLowerCase(),
                ) ||
                selectedCategory.value.toLowerCase().contains(c.toLowerCase()),
          );

      // Search filter
      final searchMatch =
          searchQuery.value.isEmpty ||
          specialist.name.toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          );

      // Gender filter
      final genderMatch =
          selectedGender.value == 'all' ||
          specialist.gender == selectedGender.value ||
          specialist.gender == 'unisex';

      // Price filter — safe parse
      double priceValue = 0.0;
      try {
        priceValue = double.parse(
          specialist.price.replaceAll(RegExp(r'[^\d.]'), ''),
        );
      } catch (_) {
        priceValue = 0.0;
      }
      final priceMatch =
          priceValue >= minPrice.value && priceValue <= maxPrice.value;

      // Rating filter
      final ratingMatch = specialist.rating >= minRating.value;

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
    maxPrice.value = 10000.0;
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
