import 'dart:convert';

import '../../domain/entities/provider.dart';
import '../../domain/entities/search_filter.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/local/local_storage.dart';

class SearchRepositoryImpl implements SearchRepository {
  final LocalStorage _localStorage;

  SearchRepositoryImpl({required LocalStorage localStorage})
    : _localStorage = localStorage;

  @override
  Future<List<Provider>> searchProviders(SearchFilter filter) async {
    // Mock implementation - in real app, this would call an API
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock filtered providers based on search criteria
    final allProviders = _getMockProviders();

    List<Provider> filteredProviders = allProviders;

    if (filter.query != null && filter.query!.isNotEmpty) {
      final query = filter.query!.toLowerCase();
      filteredProviders = filteredProviders
          .where((provider) => provider.name.toLowerCase().contains(query))
          .toList();
    }

    if (filter.category != null) {
      filteredProviders = filteredProviders
          .where(
            (provider) =>
                provider.category.toLowerCase() ==
                filter.category!.toLowerCase(),
          )
          .toList();
    }

    if (filter.minRating != null) {
      filteredProviders = filteredProviders
          .where((provider) => provider.rating >= filter.minRating!)
          .toList();
    }

    if (filter.maxPrice != null) {
      filteredProviders = filteredProviders.where((provider) {
        // This would need price info from provider entity
        // For mock, we'll assume all providers are under the max price
        return true;
      }).toList();
    }

    if (filter.minPrice != null) {
      filteredProviders = filteredProviders.where((provider) {
        // This would need price info from provider entity
        // For mock, we'll assume all providers are above the min price
        return true;
      }).toList();
    }

    if (filter.location != null) {
      filteredProviders = filteredProviders
          .where(
            (provider) => provider.name.toLowerCase().contains(
              filter.location!.toLowerCase(),
            ),
          )
          .toList();
    }

    if (filter.services.isNotEmpty) {
      filteredProviders = filteredProviders.where((provider) {
        // This would need service info from provider entity
        // For mock, we'll assume all providers offer all services
        return true;
      }).toList();
    }

    return filteredProviders;
  }

  @override
  Future<List<Provider>> getPopularProviders() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _getMockProviders()
        .where((provider) => provider.rating >= 4.5)
        .toList();
  }

  @override
  Future<List<Provider>> getNearbyProviders(String location) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _getMockProviders()
        .where(
          (provider) =>
              provider.name.toLowerCase().contains(location.toLowerCase()),
        )
        .toList();
  }

  @override
  Future<List<Provider>> getProvidersByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _getMockProviders()
        .where(
          (provider) =>
              provider.category.toLowerCase() == category.toLowerCase(),
        )
        .toList();
  }

  @override
  Future<List<Provider>> getProvidersByService(List<String> services) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _getMockProviders();
  }

  List<Provider> _getMockProviders() {
    return [
      Provider(
        id: '1',
        name: 'Afro Cuts Salon',
        category: 'salon',
        rating: 4.8,
      ),
      Provider(id: '2', name: 'Barber Joe', category: 'barber', rating: 4.9),
      Provider(id: '3', name: 'Style Studio', category: 'salon', rating: 4.7),
      Provider(id: '4', name: 'Gentle Cuts', category: 'barber', rating: 4.6),
      Provider(id: '5', name: 'Urban Styles', category: 'salon', rating: 4.9),
    ];
  }
}
