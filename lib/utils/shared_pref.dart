import 'dart:convert';

import 'package:billing/model/purchaser_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/customer_response_model.dart';

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

  static Future<void> setJson(String key, Map<String, dynamic> value) async {
    await _prefs?.setString(key, jsonEncode(value));
  }

  static Map<String, dynamic>? getJson(String key) {
    final str = _prefs?.getString(key);
    if (str == null || str.isEmpty) return null;
    try {
      final decoded = jsonDecode(str);
      if (decoded is Map<String, dynamic>) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {}
    return null;
  }

  // ---- Model-specific helpers for Datum ----
  static Future<void> setDatum(String key, Datum? value) async {
    if (value == null) {
      await _prefs?.remove(key);
      return;
    }
    await _prefs?.setString(key, jsonEncode(value.toJson()));
  }

  static Datum? getDatum(String key) {
    final map = getJson(key);
    if (map == null) return null;
    try {
      return Datum.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  // ---- Model-specific helpers for PurchaserData ----
  static Future<void> setPurchase(String key, PurchaserData? value) async {
    if (value == null) {
      await _prefs?.remove(key);
      return;
    }
    await _prefs?.setString(key, jsonEncode(value.toJson()));
  }

  static PurchaserData? getPurchase(String key) {
    final map = getJson(key);
    if (map == null) return null;
    try {
      return PurchaserData.fromJson(map);
    } catch (_) {
      return null;
    }
  }
}
