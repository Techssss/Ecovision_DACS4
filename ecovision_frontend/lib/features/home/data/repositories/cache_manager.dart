import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/aqi_data.dart';

class CacheManager {
  final SharedPreferences _prefs;
  
  static const String _cacheKey = 'aqi_cache';
  static const String _timestampKey = 'aqi_timestamp';
  static const int _cacheMinutes = 15;

  CacheManager(this._prefs);

  /// Get cached AQI if available and fresh (within 15 minutes)
  AQIData? getCachedAQI() {
    final cachedData = _prefs.getString(_cacheKey);
    final timestamp = _prefs.getInt(_timestampKey);

    if (cachedData == null || timestamp == null) return null;

    // Check if expired (15 minutes)
    final age = DateTime.now().millisecondsSinceEpoch - timestamp;
    final ageMinutes = age / 60000;

    if (ageMinutes > _cacheMinutes) {
      print('⏰ Cache expired (${ageMinutes.toInt()} min)');
      return null;
    }

    print('✅ Cache hit (${ageMinutes.toInt()} min old)');
    return AQIData.fromJson(jsonDecode(cachedData));
  }

  /// Get stale cache (even if expired) - useful for fallback
  AQIData? getStaleCache() {
    final cachedData = _prefs.getString(_cacheKey);
    final timestamp = _prefs.getInt(_timestampKey);

    if (cachedData == null || timestamp == null) return null;

    final age = DateTime.now().millisecondsSinceEpoch - timestamp;
    final ageMinutes = age / 60000;

    print('📦 Using stale cache (${ageMinutes.toInt()} min old)');
    return AQIData.fromJson(jsonDecode(cachedData));
  }

  Future<void> cacheAQI(AQIData data) async {
    await _prefs.setString(_cacheKey, jsonEncode(data.toJson()));
    await _prefs.setInt(_timestampKey, DateTime.now().millisecondsSinceEpoch);
    print('💾 AQI cached');
  }

  Future<void> clearCache() async {
    await _prefs.remove(_cacheKey);
    await _prefs.remove(_timestampKey);
  }
}
