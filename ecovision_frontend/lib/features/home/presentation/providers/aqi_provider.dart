import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/aqi_data.dart';
import '../../data/services/aqicn_service.dart';
import '../../data/services/location_service.dart';
import '../../data/services/geocoding_service.dart';
import '../../data/services/aqi_trend_service.dart';
import '../../data/repositories/cache_manager.dart';
import '../../data/repositories/aqi_repository.dart';

// SharedPreferences provider
final sharedPrefsProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

// Services
final aqiServiceProvider = Provider<AQICNService>((ref) => AQICNService());
final locationServiceProvider = Provider<LocationService>((ref) => LocationService());
final geocodingServiceProvider = Provider<GeocodingService>((ref) => GeocodingService());

// Cache Manager - FutureProvider để handle async
final cacheManagerProvider = FutureProvider<CacheManager>((ref) async {
  final prefs = await ref.watch(sharedPrefsProvider.future);
  return CacheManager(prefs);
});

// Repository - FutureProvider để handle async dependencies
final aqiRepositoryProvider = FutureProvider<AQIRepository>((ref) async {
  final cacheManager = await ref.watch(cacheManagerProvider.future);
  return AQIRepository(
    ref.read(aqiServiceProvider),
    ref.read(locationServiceProvider),
    ref.read(geocodingServiceProvider),
    cacheManager,
  );
});

// Current AQI Data - Keep alive for 5 minutes
final currentAQIProvider = FutureProvider.autoDispose<AQIData>((ref) async {
  // Keep alive for 5 minutes
  final link = ref.keepAlive();
  Timer(const Duration(minutes: 5), () {
    link.close();
  });
  
  final repository = await ref.watch(aqiRepositoryProvider.future);
  return await repository.getCurrentAQI();
});

// AQI Trend Provider
final aqiTrendServiceProvider = Provider((ref) => AQITrendService());

final aqiTrendProvider = FutureProvider.autoDispose<List<AQITrendData>>((ref) async {
  try {
    final service = ref.watch(aqiTrendServiceProvider);
    print('🔄 Fetching AQI trend data...');
    final result = await service.getTrend(days: 7);
    print('✅ AQI trend data fetched: ${result.length} items');
    return result;
  } catch (e, stack) {
    print('❌ Error in aqiTrendProvider: $e');
    print('❌ Stack: $stack');
    rethrow;
  }
});