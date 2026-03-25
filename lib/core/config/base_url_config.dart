import 'package:shared_preferences/shared_preferences.dart';

class BaseUrlConfig {
  static const String _prefsKey = 'base_url';
  static String _current = '';

  static String get current => _current;

  static Future<void> init({required String fallback}) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    _current = _normalize(saved?.isNotEmpty == true ? saved! : fallback);
  }

  static Future<void> set(String value) async {
    final normalized = _normalize(value);
    _current = normalized;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, normalized);
  }

  static String _normalize(String value) {
    var normalized = value.trim();
    while (normalized.endsWith('/') && normalized.length > 1) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    return normalized;
  }
}
