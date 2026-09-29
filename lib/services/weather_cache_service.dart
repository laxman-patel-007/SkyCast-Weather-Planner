import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_forecast.dart';

/// Service responsible for local persistence and offline caching
/// of weather forecasts using SharedPreferences (Session 16).
class WeatherCacheService {
  static const String _keyForecast = 'skycast_cached_forecast_json';
  static const String _keyTimestamp = 'skycast_last_fetch_time';
  static const String _keyLocation = 'skycast_last_location';

  /// Save forecast asynchronously to persistent local storage
  Future<bool> cacheForecast(WeatherForecast forecast) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonMap = forecast.toJson();
      final jsonString = jsonEncode(jsonMap);

      await prefs.setString(_keyForecast, jsonString);
      await prefs.setInt(_keyTimestamp, DateTime.now().millisecondsSinceEpoch);
      await prefs.setString(_keyLocation, forecast.locationName);
      return true;
    } catch (e) {
      // Gracefully handle persistence failures without crashing
      return false;
    }
  }

  /// Retrieve the last cached forecast from local storage
  Future<WeatherForecast?> getCachedForecast() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyForecast);
      if (jsonString == null || jsonString.isEmpty) {
        return null;
      }

      final Map<String, dynamic> decoded = jsonDecode(jsonString);
      final forecast = WeatherForecast.fromJson(decoded);

      // Return instance with flag isFromCache = true
      return forecast.copyWith(isFromCache: true);
    } catch (e) {
      return null;
    }
  }

  /// Get the timestamp of the last cache write
  Future<DateTime?> getLastCachedTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final millis = prefs.getInt(_keyTimestamp);
      if (millis == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(millis);
    } catch (e) {
      return null;
    }
  }

  /// Clear cache if requested (e.g. for testing or reset)
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyForecast);
    await prefs.remove(_keyTimestamp);
    await prefs.remove(_keyLocation);
  }
}
