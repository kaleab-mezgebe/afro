import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/provider.dart';
import '../../domain/entities/search_filter.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/local/local_storage.dart';

class SearchRepositoryImpl implements SearchRepository {
  final LocalStorage _localStorage;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _historyKey = 'search_history';

  SearchRepositoryImpl({required LocalStorage localStorage})
    : _localStorage = localStorage;

  @override
  Future<List<Provider>> searchProviders(SearchFilter filter) async {
    Query query = _firestore.collection('providers');

    if (filter.category != null &&
        filter.category!.isNotEmpty &&
        filter.category != 'All') {
      query = query.where('category', isEqualTo: filter.category);
    }

    if (filter.minRating != null) {
      query = query.where('rating', isGreaterThanOrEqualTo: filter.minRating);
    }

    // Firestore doesn't support complex text search well without Algolia etc.
    // For many apps, we fetch and filter locally or use simple prefix matching.
    // I'll implement a basic filter here.

    final snapshot = await query.get();
    List<Provider> results = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Provider(
        id: doc.id,
        name: data['name'] ?? '',
        category: data['category'] ?? '',
        rating: (data['rating'] ?? 0.0).toDouble(),
        location: data['location'] ?? '',
        services: List<String>.from(data['services'] ?? []),
        minPrice: (data['minPrice'] ?? 0.0).toDouble(),
        maxPrice: (data['maxPrice'] ?? 0.0).toDouble(),
        imageUrl: data['imageUrl'],
      );
    }).toList();

    // Secondary local filtering for text search and complex filters
    if (filter.query != null && filter.query!.isNotEmpty) {
      final searchTerm = filter.query!.toLowerCase();
      results = results
          .where(
            (p) =>
                p.name.toLowerCase().contains(searchTerm) ||
                p.category.toLowerCase().contains(searchTerm) ||
                p.services.any((s) => s.toLowerCase().contains(searchTerm)),
          )
          .toList();
    }

    if (filter.category != null &&
        filter.category!.isNotEmpty &&
        filter.category != 'All') {
      results = results.where((p) => p.category == filter.category).toList();
    }

    if (filter.location != null && filter.location!.isNotEmpty) {
      final loc = filter.location!.toLowerCase();
      results = results
          .where((p) => p.location.toLowerCase().contains(loc))
          .toList();
    }

    if (filter.minPrice != null) {
      results = results.where((p) => p.minPrice >= filter.minPrice!).toList();
    }

    if (filter.maxPrice != null) {
      results = results.where((p) => p.maxPrice <= filter.maxPrice!).toList();
    }

    if (filter.services.isNotEmpty) {
      results = results
          .where((p) => filter.services.every((s) => p.services.contains(s)))
          .toList();
    }

    return results;
  }

  @override
  Future<List<Provider>> getPopularProviders() async {
    final snapshot = await _firestore
        .collection('providers')
        .where('rating', isGreaterThanOrEqualTo: 4.5)
        .limit(10)
        .get();

    return snapshot.docs.map((doc) => _mapDocToProvider(doc)).toList();
  }

  @override
  Future<List<Provider>> getNearbyProviders(String location) async {
    final snapshot = await _firestore
        .collection('providers')
        .where('location', isEqualTo: location)
        .get();

    return snapshot.docs.map((doc) => _mapDocToProvider(doc)).toList();
  }

  @override
  Future<List<Provider>> getProvidersByCategory(String category) async {
    final snapshot = await _firestore
        .collection('providers')
        .where('category', isEqualTo: category)
        .get();

    return snapshot.docs.map((doc) => _mapDocToProvider(doc)).toList();
  }

  @override
  Future<List<Provider>> getProvidersByService(List<String> services) async {
    // This is more complex in Firestore, we fetch all and filter locally for now
    final snapshot = await _firestore.collection('providers').get();
    final all = snapshot.docs.map((doc) => _mapDocToProvider(doc)).toList();

    return all
        .where((p) => services.every((s) => p.services.contains(s)))
        .toList();
  }

  Provider _mapDocToProvider(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Provider(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      location: data['location'] ?? '',
      services: List<String>.from(data['services'] ?? []),
      minPrice: (data['minPrice'] ?? 0.0).toDouble(),
      maxPrice: (data['maxPrice'] ?? 0.0).toDouble(),
      imageUrl: data['imageUrl'],
    );
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
