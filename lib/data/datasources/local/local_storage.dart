import 'dart:convert';

abstract class LocalStorage {
  Future<void> save(String key, String value);
  Future<String?> get(String key);
  Future<void> remove(String key);
  Future<void> clear();
}

class LocalStorageImpl implements LocalStorage {
  final Map<String, String> _storage = {};

  @override
  Future<void> save(String key, String value) async {
    _storage[key] = value;
  }

  @override
  Future<String?> get(String key) async {
    return _storage[key];
  }

  @override
  Future<void> remove(String key) async {
    _storage.remove(key);
  }

  @override
  Future<void> clear() async {
    _storage.clear();
  }

  Future<void> saveObject<T>(String key, T object) async {
    await save(key, jsonEncode(object));
  }

  Future<T?> getObject<T>(String key, T Function(Map<String, dynamic>) fromJson) async {
    final value = await get(key);
    if (value != null) {
      return fromJson(jsonDecode(value));
    }
    return null;
  }
}
