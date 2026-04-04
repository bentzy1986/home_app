import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      _prefs = null;
    }
  }

  static Future<void> saveJson(String key, dynamic data) async {
    try {
      await _prefs?.setString(key, jsonEncode(data));
    } catch (e) {
      // שגיאת שמירה — מתעלמים
    }
  }

  static dynamic loadJson(String key) {
    try {
      final str = _prefs?.getString(key);
      if (str == null) return null;
      return jsonDecode(str);
    } catch (e) {
      return null;
    }
  }

  static Future<void> remove(String key) async {
    try {
      await _prefs?.remove(key);
    } catch (e) {
      // שגיאת מחיקה — מתעלמים
    }
  }
}
