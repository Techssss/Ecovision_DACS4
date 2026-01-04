import 'package:latlong2/latlong.dart';

class AQIStationModel {
  final String stationId;
  final String name;
  final double latitude;
  final double longitude;
  final String? address;
  final String? city;
  final int? currentAqi;
  final int? avgAqi24h;
  final double? pm25;
  final double? pm10;
  final DateTime? lastUpdated;
  final AQIStatus status;

  AQIStationModel({
    required this.stationId,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.currentAqi,
    this.avgAqi24h,
    this.pm25,
    this.pm10,
    this.lastUpdated,
    required this.status,
  });

  factory AQIStationModel.fromJson(Map<String, dynamic> json) {
    // Safe parsing helper
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) {
        try {
          return double.parse(value);
        } catch (e) {
          return null;
        }
      }
      return null;
    }

    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        try {
          return int.parse(value);
        } catch (e) {
          return null;
        }
      }
      return null;
    }

    return AQIStationModel(
      stationId: json['station_id'] as String,
      name: json['name'] as String,
      latitude: parseDouble(json['latitude']) ?? 0.0,
      longitude: parseDouble(json['longitude']) ?? 0.0,
      address: json['address'] as String?,
      city: json['city'] as String?,
      currentAqi: parseInt(json['current_aqi']),
      avgAqi24h: parseInt(json['avg_aqi_24h']),
      pm25: parseDouble(json['pm25']),
      pm10: parseDouble(json['pm10']),
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'] as String)
          : null,
      status: AQIStatus.fromJson(json['status'] as Map<String, dynamic>),
    );
  }

  LatLng get position => LatLng(latitude, longitude);
}

class AQIStatus {
  final String level;
  final String color;
  final String description;

  AQIStatus({
    required this.level,
    required this.color,
    required this.description,
  });

  factory AQIStatus.fromJson(Map<String, dynamic> json) {
    return AQIStatus(
      level: json['level'] as String,
      color: json['color'] as String,
      description: json['description'] as String,
    );
  }
}
