import 'package:latlong2/latlong.dart';

/// Model cho tuyến đường
class RouteModel {
  final String id;
  final String name;
  final int durationMinutes;
  final double distanceKm;
  final int avgAqi;
  final int maxAqi;
  final List<String> features;
  final List<LatLng> coordinates;
  final List<int> segmentAqis;

  RouteModel({
    required this.id,
    required this.name,
    required this.durationMinutes,
    required this.distanceKm,
    required this.avgAqi,
    required this.maxAqi,
    required this.features,
    required this.coordinates,
    required this.segmentAqis,
  });
}
