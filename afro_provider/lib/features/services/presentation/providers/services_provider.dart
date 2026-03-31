import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/staff_service_models.dart';
import '../../../../core/di/injection_container.dart';

// Services State
class ServicesState {
  final bool isLoading;
  final String? error;
  final List<Service> services;

  const ServicesState({
    this.isLoading = false,
    this.error,
    this.services = const [],
  });

  ServicesState copyWith({
    bool? isLoading,
    String? error,
    List<Service>? services,
  }) {
    return ServicesState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      services: services ?? this.services,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServicesState &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          error == other.error &&
          services == other.services;

  @override
  int get hashCode => Object.hash(isLoading, error, services);
}

// Services Notifier
class ServicesNotifier extends StateNotifier<ServicesState> {
  ServicesNotifier() : super(const ServicesState());

  Future<void> loadServices() async {
    state = const ServicesState(isLoading: true);

    try {
      // Get shop ID from provider service (assuming first shop)
      final shops = await shopService.getShops();
      if (shops.isEmpty) {
        state = const ServicesState(
          isLoading: false,
          error: 'No shop found. Please create a shop first.',
          services: [],
        );
        return;
      }

      final shopId = shops[0]['id'].toString();

      // Fetch services from API
      final response = await serviceService.getShopServices(shopId);

      // Convert API response to Service models
      final services = response.map((json) {
        return Service(
          id: json['id'].toString(),
          shopId: json['shopId']?.toString() ?? '',
          name: json['name'] ?? '',
          category: _parseCategory(json['category']),
          description: json['description'] ?? '',
          image: json['image'],
          basePrice: (json['basePrice'] ?? 0).toDouble(),
          duration: json['duration'] ?? 30,
          status: _parseStatus(json['status']),
          isVariantBased: json['isVariantBased'] ?? false,
          variants: (json['variants'] as List<dynamic>?)
                  ?.map((v) => ServiceVariant(
                        id: v['id']?.toString() ?? '',
                        name: v['name'] ?? '',
                        price: (v['price'] ?? 0).toDouble(),
                        duration: v['duration'],
                        description: v['description'],
                      ))
                  .toList() ??
              [],
          addOns: (json['addOns'] as List<dynamic>?)
                  ?.map((a) => ServiceAddOn(
                        id: a['id']?.toString() ?? '',
                        name: a['name'] ?? '',
                        price: (a['price'] ?? 0).toDouble(),
                        duration: a['duration'] ?? 0,
                        description: a['description'],
                      ))
                  .toList() ??
              [],
          popularityScore: (json['popularityScore'] ?? 0).toDouble(),
          totalBookings: json['totalBookings'] ?? 0,
          averageRating: (json['averageRating'] ?? 0).toDouble(),
          totalReviews: json['totalReviews'] ?? 0,
          createdAt: DateTime.parse(json['createdAt']),
          updatedAt: DateTime.parse(json['updatedAt']),
        );
      }).toList();

      state = ServicesState(
        isLoading: false,
        services: services,
        error: null,
      );
    } catch (e) {
      state = ServicesState(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  ServiceCategory _parseCategory(String? category) {
    switch (category?.toLowerCase()) {
      case 'haircut':
        return ServiceCategory.haircut;
      case 'beard_trim':
        return ServiceCategory.beardTrim;
      case 'hair_coloring':
        return ServiceCategory.hairColoring;
      case 'hair_styling':
        return ServiceCategory.hairStyling;
      case 'makeup':
        return ServiceCategory.makeup;
      case 'nail_care':
        return ServiceCategory.nailCare;
      case 'skin_care':
        return ServiceCategory.skinCare;
      case 'waxing':
        return ServiceCategory.waxing;
      case 'facial':
        return ServiceCategory.facial;
      case 'other':
      default:
        return ServiceCategory.other;
    }
  }

  ServiceStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return ServiceStatus.active;
      case 'inactive':
        return ServiceStatus.inactive;
      case 'seasonal':
        return ServiceStatus.seasonal;
      default:
        return ServiceStatus.active;
    }
  }

  void addService(Service service) {
    final currentServices = List<Service>.from(state.services);
    currentServices.add(service);
    state = state.copyWith(services: currentServices);
  }

  void updateService(Service service) {
    final currentServices = List<Service>.from(state.services);
    final index = currentServices.indexWhere((s) => s.id == service.id);

    if (index != -1) {
      currentServices[index] = service;
    }

    state = state.copyWith(services: currentServices);
  }

  void deleteService(String serviceId) {
    final currentServices =
        state.services.where((service) => service.id != serviceId).toList();
    state = state.copyWith(services: currentServices);
  }

  void toggleServiceStatus(String serviceId) {
    final currentServices = List<Service>.from(state.services);
    final index = currentServices.indexWhere((s) => s.id == serviceId);

    if (index != -1) {
      final service = currentServices[index];
      final newStatus = service.status == ServiceStatus.active
          ? ServiceStatus.inactive
          : ServiceStatus.active;

      // Create a new Service instance with updated status
      final updatedService = Service(
        id: service.id,
        shopId: service.shopId,
        name: service.name,
        category: service.category,
        description: service.description,
        image: service.image,
        basePrice: service.basePrice,
        duration: service.duration,
        status: newStatus,
        isVariantBased: service.isVariantBased,
        variants: service.variants,
        addOns: service.addOns,
        popularityScore: service.popularityScore,
        totalBookings: service.totalBookings,
        averageRating: service.averageRating,
        totalReviews: service.totalReviews,
        createdAt: service.createdAt,
        updatedAt: DateTime.now(),
      );

      currentServices[index] = updatedService;
      state = state.copyWith(services: currentServices);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final servicesProvider = StateNotifierProvider<ServicesNotifier, ServicesState>(
  (ref) => ServicesNotifier(),
);
