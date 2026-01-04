import '../models/aqi_data.dart';
import '../services/aqicn_service.dart';
import '../services/location_service.dart';
import '../services/geocoding_service.dart';
import 'cache_manager.dart';

class AQIRepository {
  final AQICNService _aqiService;
  final LocationService _locationService;
  final GeocodingService _geocodingService;
  final CacheManager _cacheManager;

  AQIRepository(
    this._aqiService,
    this._locationService,
    this._geocodingService,
    this._cacheManager,
  );

  Future<AQIData> getCurrentAQI() async {
    try {
      // 1. Check fresh cache first
      final cached = _cacheManager.getCachedAQI();
      if (cached != null) {
        print('💾 Using cached AQI');
        return cached;
      }

      // 2. Get GPS location
      print('📍 Getting location...');
      final position = await _locationService.getCurrentLocation();
      print('📍 Location: ${position.latitude}, ${position.longitude}');

      // 3. Get detailed address from GPS
      String address = 'Đà Nẵng'; // Default fallback
      try {
        address = await _geocodingService.getAddressFromPosition(position);
        print('📍 Address: $address');
      } catch (e) {
        print('⚠️ Geocoding failed, using default: $e');
      }

      // 4. Fetch from API
      final json = await _aqiService.fetchAQIByLocation(
        position.latitude,
        position.longitude,
      );

      final aqiData = AQIData.fromJson(json);
      
      // Override cityName with detailed address
      final detailedAqiData = AQIData(
        aqi: aqiData.aqi,
        cityName: address, // Use geocoded address
        pm25: aqiData.pm25,
        pm10: aqiData.pm10,
        o3: aqiData.o3,
        temperature: aqiData.temperature,
        humidity: aqiData.humidity,
        updateTime: aqiData.updateTime,
        attribution: aqiData.attribution,
      );

      // 5. Cache the result
      await _cacheManager.cacheAQI(detailedAqiData);

      return detailedAqiData;
    } catch (e) {
      print('❌ Error: $e');
      
      // Fallback 1: Try stale cache (even if expired)
      final staleCache = _cacheManager.getStaleCache();
      if (staleCache != null) {
        print('📦 Using stale cache as fallback');
        return staleCache;
      }
      
      // Fallback 2: Return default data for Đà Nẵng
      print('🔄 Using default fallback data');
      return _getDefaultAQIData();
    }
  }

  /// Default AQI data for Đà Nẵng (fallback when API fails)
  AQIData _getDefaultAQIData() {
    return AQIData(
      aqi: 45,
      cityName: 'Đà Nẵng',
      pm25: 30.0,
      pm10: 45.0,
      o3: 25.0,
      temperature: 28.0,
      humidity: 75.0,
      updateTime: DateTime.now(),
      attribution: 'EcoVision Default',
    );
  }

  Future<void> clearCache() async {
    await _cacheManager.clearCache();
  }
}
