/// Cache service for storing API responses and data
/// Provides both memory and persistent caching capabilities
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  final Map<String, CacheEntry> _memoryCache = {};

  /// Get cached data by key
  T? get<T>(String key) {
    final entry = _memoryCache[key];
    if (entry == null || entry.isExpired) {
      _memoryCache.remove(key);
      return null;
    }
    return entry.data as T;
  }

  /// Set data in cache with optional duration
  void set<T>(
    String key,
    T data, {
    Duration duration = const Duration(minutes: 5),
  }) {
    _memoryCache[key] = CacheEntry(
      data: data,
      expiresAt: DateTime.now().add(duration),
    );
  }

  /// Check if key exists and is not expired
  bool has(String key) {
    final entry = _memoryCache[key];
    if (entry == null || entry.isExpired) {
      _memoryCache.remove(key);
      return false;
    }
    return true;
  }

  /// Clear all cached data
  void clear() {
    _memoryCache.clear();
  }

  /// Clear specific key
  void remove(String key) {
    _memoryCache.remove(key);
  }

  /// Clear expired entries
  void clearExpired() {
    _memoryCache.removeWhere((key, entry) => entry.isExpired);
  }
}

/// Cache entry with expiration
class CacheEntry {
  final dynamic data;
  final DateTime expiresAt;

  CacheEntry({required this.data, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
