import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SunCache {
  static const _key = 'sun_cache';

  // Use named parameters for consistency with your helper
  static Future<void> save({
    required double latitude,
    required double longitude,
    required DateTime sunrise,
    required DateTime sunset,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'latitude': latitude,
      'longitude': longitude,
      'sunrise': sunrise.toIso8601String(),
      'sunset': sunset.toIso8601String(),
      'date': DateTime.now().toIso8601String().split('T')[0], // YYYY-MM-DD
    };
    await prefs.setString(_key, jsonEncode(data));
  }

  // Accept latitude and longitude to potentially add checks later
  static Future<Map<String, dynamic>?> get({
    required double latitude,
    required double longitude,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return null;

    final data = jsonDecode(jsonString);

    // Check if cached date is today
    final today = DateTime.now().toIso8601String().split('T')[0];
    if (data['date'] != today) return null;

    // Optionally check if location matches (latitude/longitude)
    if (data['latitude'] != latitude || data['longitude'] != longitude) {
      return null;
    }

    return data;
  }
}
