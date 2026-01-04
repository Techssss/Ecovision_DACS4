import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../data/models/aqi_station_model.dart';
import 'dart:math' as math;

/// Custom heatmap layer for AQI visualization
class AQIHeatmapLayer extends StatelessWidget {
  final List<AQIStationModel> stations;
  final double radius; // Radius in meters
  final double opacity;

  const AQIHeatmapLayer({
    super.key,
    required this.stations,
    this.radius = 1500,
    this.opacity = 0.4,
  });

  @override
  Widget build(BuildContext context) {
    return CircleLayer(
      circles: _buildHeatmapCircles(),
    );
  }

  List<CircleMarker> _buildHeatmapCircles() {
    List<CircleMarker> circles = [];

    for (var station in stations) {
      if (station.currentAqi == null) continue;

      final aqi = station.currentAqi!;
      final color = _getHeatmapColor(aqi);

      // Create multiple concentric circles for gradient effect
      circles.addAll([
        // Outer circle (most transparent)
        CircleMarker(
          point: station.position,
          radius: radius,
          useRadiusInMeter: true,
          color: color.withOpacity(opacity * 0.3),
          borderColor: Colors.transparent,
          borderStrokeWidth: 0,
        ),
        // Middle circle
        CircleMarker(
          point: station.position,
          radius: radius * 0.6,
          useRadiusInMeter: true,
          color: color.withOpacity(opacity * 0.6),
          borderColor: Colors.transparent,
          borderStrokeWidth: 0,
        ),
        // Inner circle (most opaque)
        CircleMarker(
          point: station.position,
          radius: radius * 0.3,
          useRadiusInMeter: true,
          color: color.withOpacity(opacity * 0.9),
          borderColor: Colors.transparent,
          borderStrokeWidth: 0,
        ),
      ]);
    }

    return circles;
  }

  Color _getHeatmapColor(int aqi) {
    // Smooth gradient from green → yellow → orange → red → purple → maroon
    if (aqi <= 50) {
      // Green (0-50)
      return const Color(0xFF00E400);
    } else if (aqi <= 100) {
      // Green to Yellow (51-100)
      return Color.lerp(
        const Color(0xFF00E400),
        const Color(0xFFFFFF00),
        (aqi - 50) / 50,
      )!;
    } else if (aqi <= 150) {
      // Yellow to Orange (101-150)
      return Color.lerp(
        const Color(0xFFFFFF00),
        const Color(0xFFFF7E00),
        (aqi - 100) / 50,
      )!;
    } else if (aqi <= 200) {
      // Orange to Red (151-200)
      return Color.lerp(
        const Color(0xFFFF7E00),
        const Color(0xFFFF0000),
        (aqi - 150) / 50,
      )!;
    } else if (aqi <= 300) {
      // Red to Purple (201-300)
      return Color.lerp(
        const Color(0xFFFF0000),
        const Color(0xFF8F3F97),
        (aqi - 200) / 100,
      )!;
    } else {
      // Purple to Maroon (300+)
      return Color.lerp(
        const Color(0xFF8F3F97),
        const Color(0xFF7E0023),
        math.min((aqi - 300) / 200, 1.0),
      )!;
    }
  }
}
