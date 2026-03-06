import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalStorage {
  Future<void> save(String key, String value);
  Future<String?> get(String key);
  Future<void> remove(String key);
  Future<void> clear();
}

class LocalStorageImpl implements LocalStorage {
  SharedPreferences? _prefs;

  Future<void> _init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  @override
  Future<void> save(String key, String value) async {
    await _init();
    await _prefs!.setString(key, value);
  }

  @override
  Future<String?> get(String key) async {
    await _init();
    return _prefs!.getString(key);
  }

  @override
  Future<void> remove(String key) async {
    await _init();
    await _prefs!.remove(key);
  }

  @override
  Future<void> clear() async {
    await _init();
    await _prefs!.clear();
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
