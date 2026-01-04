import 'package:flutter/material.dart';

/// Màu sắc cho Map và AQI
class MapColors {
  // AQI Colors
  static Color getAQIColor(int aqi) {
    if (aqi <= 50) return const Color(0xFF06FF64); // Green
    if (aqi <= 100) return const Color(0xFFFFFC00); // Yellow
    if (aqi <= 150) return const Color(0xFFFFA500); // Orange
    return const Color(0xFFFF1E00); // Red
  }

  // Route colors
  static const routeCleanest = Color(0xFF06FF64);
  static const routeBalanced = Color(0xFFFFFC00);
  static const routeFastest = Color(0xFFFFA500);

  // Background colors
  static const strategyBackground = Color(0xFFE3F2FD);
  static const chartBackground = Color(0xFFE3F2FD);
}
