import 'package:flutter/material.dart';

/// Model cho dữ liệu từ AQICN API
class AQIData {
  final int aqi;
  final String cityName;
  final double pm25;
  final double pm10;
  final double o3;
  final double temperature;
  final double humidity;
  final DateTime updateTime;
  final String attribution;

  AQIData({
    required this.aqi,
    required this.cityName,
    required this.pm25,
    required this.pm10,
    required this.o3,
    required this.temperature,
    required this.humidity,
    required this.updateTime,
    required this.attribution,
  });

  factory AQIData.fromJson(Map<String, dynamic> json) {
    final iaqi = json['iaqi'] as Map<String, dynamic>? ?? {};
    final rawCityName = json['city']?['name'] as String? ?? 'Unknown';
    
    print('🏙️ City from API: $rawCityName');
    
    // Clean up city name
    String cityName = rawCityName;
    if (rawCityName.contains('Da Nang') || rawCityName.contains('Đà Nẵng')) {
      // Extract district if available, otherwise use "Đà Nẵng"
      if (rawCityName.contains('Son Tra') || rawCityName.contains('Sơn Trà')) {
        cityName = 'Sơn Trà, Đà Nẵng';
      } else {
        cityName = 'Đà Nẵng';
      }
    }
    
    return AQIData(
      aqi: json['aqi'] as int? ?? 0,
      cityName: cityName,
      pm25: (iaqi['pm25']?['v'] ?? 0).toDouble(),
      pm10: (iaqi['pm10']?['v'] ?? 0).toDouble(),
      o3: (iaqi['o3']?['v'] ?? 0).toDouble(),
      temperature: (iaqi['t']?['v'] ?? 0).toDouble(),
      humidity: (iaqi['h']?['v'] ?? 0).toDouble(),
      updateTime: DateTime.parse(json['time']['s']),
      attribution: (json['attributions'] as List?)?.isNotEmpty == true
          ? json['attributions'][0]['name']
          : 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aqi': aqi,
      'city': {'name': cityName},
      'iaqi': {
        'pm25': {'v': pm25},
        'pm10': {'v': pm10},
        'o3': {'v': o3},
        't': {'v': temperature},
        'h': {'v': humidity},
      },
      'time': {'s': updateTime.toIso8601String()},
      'attributions': [{'name': attribution}],
    };
  }

  String get status {
    if (aqi <= 50) return 'Tốt';
    if (aqi <= 100) return 'Trung bình';
    if (aqi <= 150) return 'Kém (Nhạy cảm)';
    if (aqi <= 200) return 'Kém';
    if (aqi <= 300) return 'Rất kém';
    return 'Nguy hại';
  }

  Color get color {
    if (aqi <= 50) return Colors.green;
    if (aqi <= 100) return Colors.yellow[700]!;
    if (aqi <= 150) return Colors.orange;
    if (aqi <= 200) return Colors.red;
    if (aqi <= 300) return const Color(0xFF8B008B);
    return const Color(0xFF7E0023);
  }

  String get advice {
    if (aqi <= 50) return 'Không khí tốt, phù hợp mọi hoạt động';
    if (aqi <= 100) return 'Chấp nhận được cho hầu hết mọi người';
    if (aqi <= 150) return 'Người nhạy cảm nên hạn chế ra ngoài';
    if (aqi <= 200) return 'Không nên hoạt động ngoài trời lâu';
    if (aqi <= 300) return 'Tránh ra ngoài, đeo khẩu trang N95';
    return 'Nguy hiểm! Ở trong nhà, đóng cửa sổ';
  }
}
