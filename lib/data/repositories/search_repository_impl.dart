import 'dart:convert';
import 'package:get/get.dart';

import '../../domain/entities/provider.dart';
import '../../domain/entities/search_filter.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/local/local_storage.dart';
import '../../core/services/barber_api_service.dart';

class SearchRepositoryImpl implements SearchRepository {
  final LocalStorage _localStorage;
  final BarberApiService _barberApiService = Get.find<BarberApiService>();
  static const String _historyKey = 'search_history';

  SearchRepositoryImpl({required LocalStorage localStorage})
    : _localStorage = localStorage;

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  Future<List<Provider>> searchProviders(SearchFilter filter) async {
    try {
      final List<dynamic> jsonList = await _barberApiService.getBarbers(
        search: filter.query,
        latitude: filter.latitude,
        longitude: filter.longitude,
        radius: filter.radius,
      );

      return jsonList.map((json) {
        return Provider(
          id: json['id'] ?? '',
          name: json['name'] ?? 'Unknown',
          category: json['category'] ?? 'barber',
          rating: _toDouble(json['rating']),
          location: json['address'] ?? json['location'] ?? '',
          services: List<String>.from(json['services'] ?? []),
          minPrice: _toDouble(json['minPrice']),
          maxPrice: _toDouble(json['maxPrice']),
          imageUrl:
              json['imageUrl'] ??
              'https://picsum.photos/seed/${json['id']}/200/200',
          reviewCount: json['totalReviews'] ?? 0,
          isVerified: json['isVerified'] ?? false,
          latitude: _toDouble(json['latitude']),
          longitude: _toDouble(json['longitude']),
        );
      }).toList();
    } catch (e) {
      print('SearchRepositoryImpl Error: $e');
      return [];
    }
  }

  @override
  Future<List<Provider>> getPopularProviders() async {
    return searchProviders(SearchFilter(minRating: 4.5));
  }

  @override
  Future<List<Provider>> getNearbyProviders(String location) async {
    return searchProviders(SearchFilter(location: location));
  }

  @override
  Future<List<Provider>> getProvidersByCategory(String category) async {
    return searchProviders(SearchFilter(category: category));
  }

  @override
  Future<List<Provider>> getProvidersByService(List<String> services) async {
    return searchProviders(SearchFilter(services: services));
  }

  @override
  Future<void> saveSearchHistory(String query) async {
    if (query.isEmpty) return;

    List<String> history = await getSearchHistory();
    history.remove(query); // Remove if already exists to move to top
    history.insert(0, query);

    if (history.length > 10) {
      history = history.sublist(0, 10);
    }

    await _localStorage.save(_historyKey, jsonEncode(history));
  }

  @override
  Future<List<String>> getSearchHistory() async {
    final data = await _localStorage.get(_historyKey);
    if (data != null) {
      try {
        return List<String>.from(jsonDecode(data));
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  @override
  Future<void> clearSearchHistory() async {
    await _localStorage.remove(_historyKey);
  }
}
