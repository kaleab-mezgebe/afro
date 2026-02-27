import 'package:flutter_test/flutter_test.dart';
import 'package:customer_app/data/repositories/search_repository_impl.dart';
import 'package:customer_app/domain/entities/search_filter.dart';
import 'package:customer_app/data/datasources/local/local_storage.dart';

class MockLocalStorage implements LocalStorage {
  @override
  Future<void> clear() async {
    // Mock implementation
  }

  @override
  Future<String?> get(String key) async {
    return null;
  }

  @override
  Future<void> remove(String key) async {
    // Mock implementation
  }

  @override
  Future<void> save(String key, String value) async {
    // Mock implementation
  }
}

void main() {
  group('SearchRepositoryImpl Tests', () {
    late SearchRepositoryImpl repository;

    setUp(() {
      repository = SearchRepositoryImpl(localStorage: MockLocalStorage());
    });

    test('searchProviders with no filters returns all providers', () async {
      final filter = SearchFilter();
      final result = await repository.searchProviders(filter);

      expect(result.length, 5);
      expect(result[0].name, 'Afro Cuts Salon');
      expect(result[1].name, 'Barber Joe');
    });

    test('searchProviders with query filter', () async {
      final filter = SearchFilter(query: 'salon');
      final result = await repository.searchProviders(filter);

      expect(result.length, 1);
      expect(result.every((p) => p.name.toLowerCase().contains('salon')), true);
    });

    test('searchProviders with category filter', () async {
      final filter = SearchFilter(category: 'salon');
      final result = await repository.searchProviders(filter);

      expect(result.length, 3);
      expect(result.every((p) => p.category.toLowerCase() == 'salon'), true);
    });

    test('searchProviders with minRating filter', () async {
      final filter = SearchFilter(minRating: 4.8);
      final result = await repository.searchProviders(filter);

      expect(result.length, 3);
      expect(result.every((p) => p.rating >= 4.8), true);
    });

    test('searchProviders with multiple filters', () async {
      final filter = SearchFilter(
        query: 'salon',
        category: 'salon',
        minRating: 4.7,
      );
      final result = await repository.searchProviders(filter);

      expect(result.length, 1);
      expect(
        result.every(
          (p) =>
              p.name.toLowerCase().contains('salon') &&
              p.category.toLowerCase() == 'salon' &&
              p.rating >= 4.7,
        ),
        true,
      );
    });

    test('getPopularProviders returns providers with rating >= 4.5', () async {
      final result = await repository.getPopularProviders();

      expect(result.length, 5);
      expect(result.every((p) => p.rating >= 4.5), true);
    });

    test('getNearbyProviders filters by location', () async {
      final result = await repository.getNearbyProviders('cuts');

      expect(result.length, 2);
      expect(result.every((p) => p.name.toLowerCase().contains('cuts')), true);
    });

    test('getProvidersByCategory filters by category', () async {
      final result = await repository.getProvidersByCategory('barber');

      expect(result.length, 2);
      expect(result.every((p) => p.category.toLowerCase() == 'barber'), true);
    });

    test('getProvidersByService returns all providers (mock)', () async {
      final result = await repository.getProvidersByService(['haircut']);

      expect(result.length, 5);
    });
  });
}
