import 'package:flutter_test/flutter_test.dart';
import 'package:customer_app/core/services/cache_service.dart';

void main() {
  late CacheService cacheService;

  setUp(() {
    cacheService = CacheService();
    cacheService.clear(); // Clear before each test
  });

  group('CacheService', () {
    test('should store and retrieve data', () {
      // Arrange
      const key = 'test_key';
      const value = 'test_value';

      // Act
      cacheService.set(key, value);
      final result = cacheService.get<String>(key);

      // Assert
      expect(result, equals(value));
    });

    test('should return null for non-existent key', () {
      // Act
      final result = cacheService.get<String>('non_existent');

      // Assert
      expect(result, isNull);
    });

    test('should expire data after duration', () async {
      // Arrange
      const key = 'test_key';
      const value = 'test_value';

      // Act
      cacheService.set(key, value, duration: const Duration(milliseconds: 100));
      await Future.delayed(const Duration(milliseconds: 150));
      final result = cacheService.get<String>(key);

      // Assert
      expect(result, isNull);
    });

    test('should check if key exists', () {
      // Arrange
      const key = 'test_key';
      const value = 'test_value';

      // Act
      cacheService.set(key, value);

      // Assert
      expect(cacheService.has(key), isTrue);
      expect(cacheService.has('non_existent'), isFalse);
    });

    test('should remove specific key', () {
      // Arrange
      const key = 'test_key';
      const value = 'test_value';
      cacheService.set(key, value);

      // Act
      cacheService.remove(key);

      // Assert
      expect(cacheService.has(key), isFalse);
    });

    test('should clear all cache', () {
      // Arrange
      cacheService.set('key1', 'value1');
      cacheService.set('key2', 'value2');

      // Act
      cacheService.clear();

      // Assert
      expect(cacheService.has('key1'), isFalse);
      expect(cacheService.has('key2'), isFalse);
    });

    test('should clear expired entries', () async {
      // Arrange
      cacheService.set(
        'key1',
        'value1',
        duration: const Duration(milliseconds: 100),
      );
      cacheService.set('key2', 'value2', duration: const Duration(hours: 1));

      // Act
      await Future.delayed(const Duration(milliseconds: 150));
      cacheService.clearExpired();

      // Assert
      expect(cacheService.has('key1'), isFalse);
      expect(cacheService.has('key2'), isTrue);
    });

    test('should handle different data types', () {
      // Arrange & Act
      cacheService.set('string', 'test');
      cacheService.set('int', 42);
      cacheService.set('bool', true);
      cacheService.set('list', [1, 2, 3]);
      cacheService.set('map', {'key': 'value'});

      // Assert
      expect(cacheService.get<String>('string'), equals('test'));
      expect(cacheService.get<int>('int'), equals(42));
      expect(cacheService.get<bool>('bool'), equals(true));
      expect(cacheService.get<List>('list'), equals([1, 2, 3]));
      expect(cacheService.get<Map>('map'), equals({'key': 'value'}));
    });
  });
}
