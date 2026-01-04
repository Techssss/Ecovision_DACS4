import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/aqi_map_service.dart';
import '../../data/models/aqi_station_model.dart';

/// Provider for AQI map service
final aqiMapServiceProvider = Provider<AQIMapService>((ref) {
  return AQIMapService();
});

/// Provider for AQI stations data
final aqiStationsProvider = FutureProvider<List<AQIStationModel>>((ref) async {
  final service = ref.read(aqiMapServiceProvider);
  return await service.getMapData();
});

/// Provider for selected AQI station
final selectedAQIStationProvider = StateProvider<AQIStationModel?>((ref) => null);
