import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/specialist_model.dart';
import '../models/category_model.dart';
import '../../../routes/app_routes.dart';

class HomeController extends GetxController {
  final RxString selectedCategory = 'Hairdressing'.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedGender = 'all'.obs;
  final RxDouble minPrice = 0.0.obs;
  final RxDouble maxPrice = 100.0.obs;
  final RxDouble minRating = 0.0.obs;
  final RxBool filtersApplied = false.obs;
  final RxInt notificationCount = 3.obs;

  final RxList<HomeCategory> categories = <HomeCategory>[
    HomeCategory(name: 'All', icon: Icons.grid_view_rounded, gender: 'all', isSelected: true),
    HomeCategory(name: 'Hairdressing', icon: Icons.content_cut, gender: 'all'),
    HomeCategory(name: 'Hair Color', icon: Icons.color_lens, gender: 'all'),
    HomeCategory(name: 'Beard & Mustache', icon: Icons.face, gender: 'male'),
    HomeCategory(name: 'Makeup', icon: Icons.brush, gender: 'female'),
    HomeCategory(name: 'Shaving', icon: Icons.content_cut, gender: 'male'),
    HomeCategory(name: 'Nail Care', icon: Icons.back_hand, gender: 'female'),
    HomeCategory(name: 'Waxing', icon: Icons.spa, gender: 'all'),
    HomeCategory(name: 'Facial', icon: Icons.face, gender: 'all'),
  ].obs;

  final RxList<Specialist> allSpecialists = <Specialist>[
    Specialist(
      id: '1',
      name: 'David Marcomin',
      price: '\$49.32',
      image: 'https://picsum.photos/seed/david/200/200.jpg',
      categories: ['Hairdressing', 'Beard & Mustache'],
      gender: 'male',
      rating: 4.8,
    ),
    Specialist(
      id: '2',
      name: 'Richard Anderson',
      price: '\$28.48',
      image: 'https://picsum.photos/seed/richard/200/200.jpg',
      categories: ['Hairdressing', 'Styling'],
      gender: 'male',
      rating: 4.6,
    ),
    Specialist(
      id: '3',
      name: 'Sarah Johnson',
      price: '\$65.00',
      image: 'https://picsum.photos/seed/sarah/200/200.jpg',
      categories: ['Hairdressing', 'Hair Color', 'Styling'],
      gender: 'female',
      rating: 4.9,
    ),
    Specialist(
      id: '4',
      name: 'Emma Wilson',
      price: '\$55.75',
      image: 'https://picsum.photos/seed/emma/200/200.jpg',
      categories: ['Hair Color', 'Hair Treatment'],
      gender: 'female',
      rating: 4.7,
    ),
    Specialist(
      id: '5',
      name: 'Michael Brown',
      price: '\$35.50',
      image: 'https://picsum.photos/seed/michael/200/200.jpg',
      categories: ['Beard & Mustache', 'Shaving'],
      gender: 'male',
      rating: 4.5,
    ),
    Specialist(
      id: '6',
      name: 'Lisa Davis',
      price: '\$75.00',
      image: 'https://picsum.photos/seed/lisa/200/200.jpg',
      categories: ['Makeup', 'Facial'],
      gender: 'female',
      rating: 4.8,
    ),
    Specialist(
      id: '7',
      name: 'Jennifer Martinez',
      price: '\$45.25',
      image: 'https://picsum.photos/seed/jennifer/200/200.jpg',
      categories: ['Nail Care', 'Waxing'],
      gender: 'female',
      rating: 4.6,
    ),
    Specialist(
      id: '8',
      name: 'Robert Taylor',
      price: '\$40.00',
      image: 'https://picsum.photos/seed/robert/200/200.jpg',
      categories: ['Hairdressing', 'Hair Treatment'],
      gender: 'male',
      rating: 4.4,
    ),
  ].obs;

  List<Specialist> get filteredSpecialists {
    return allSpecialists.where((specialist) {
      bool categoryMatch = selectedCategory.value == 'All' || 
          specialist.categories.contains(selectedCategory.value);
      bool searchMatch = searchQuery.value.isEmpty ||
          specialist.name.toLowerCase().contains(searchQuery.value.toLowerCase());
      bool genderMatch = selectedGender.value == 'all' || specialist.gender == selectedGender.value;
      
      // Safe price parsing
      double priceValue = 0.0;
      try {
        priceValue = double.parse(specialist.price.replaceAll('\$', '').replaceAll(',', ''));
      } catch (e) {
        priceValue = 0.0;
      }
      
      bool priceMatch = priceValue >= minPrice.value && priceValue <= maxPrice.value;
      bool ratingMatch = specialist.rating >= minRating.value;

      return categoryMatch && searchMatch && genderMatch && priceMatch && ratingMatch;
    }).toList();
  }

  void selectCategory(String categoryName) {
    selectedCategory.value = categoryName;
    for (int i = 0; i < categories.length; i++) {
      categories[i] = categories[i].copyWith(isSelected: categories[i].name == categoryName);
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
    Get.toNamed(AppRoutes.portfolio, arguments: {
      'id': specialist.id,
      'name': specialist.name,
      'image': specialist.image,
      'rating': specialist.rating,
      'categories': specialist.categories,
      'gender': specialist.gender,
      'price': specialist.price,
    });
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
