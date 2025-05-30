import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static SharedPreferences? _prefs;

  // Initialize only once
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Save a string
  static Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  // Get a string
  static String? getString(String key) {
    return _prefs?.getString(key);
  }

  // Save a boolean
  static Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  // Get a boolean
  static bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  // Save an integer
  static Future<void> setInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  // Get an integer
  static int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  // Remove a key
  static Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  // Clear all preferences
  static Future<void> clear() async {
    await _prefs?.clear();
  }
}
