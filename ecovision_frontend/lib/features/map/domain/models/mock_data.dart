import 'package:latlong2/latlong.dart';
import 'route_model.dart';

/// Mock data cho Map (Frontend only)
class MockMapData {
  static final List<RouteModel> routes = [
    RouteModel(
      id: '1',
      name: 'Tuyến sạch nhất',
      durationMinutes: 18,
      distanceKm: 4.2,
      avgAqi: 38,
      maxAqi: 56,
      features: ['Ưu tiên AQI', 'Nhiều cây xanh'],
      coordinates: [
        const LatLng(16.0544, 108.2022), // Start - Đà Nẵng
        const LatLng(16.0590, 108.2100),
        const LatLng(16.0650, 108.2180),
        const LatLng(16.0700, 108.2250), // End
      ],
      segmentAqis: [35, 38, 42, 56],
    ),
    RouteModel(
      id: '2',
      name: 'Tuyến cân bằng',
      durationMinutes: 15,
      distanceKm: 3.8,
      avgAqi: 45,
      maxAqi: 68,
      features: ['Thời gian tối ưu'],
      coordinates: [
        const LatLng(16.0544, 108.2022), // Start
        const LatLng(16.0580, 108.2080),
        const LatLng(16.0640, 108.2160),
        const LatLng(16.0700, 108.2250), // End
      ],
      segmentAqis: [42, 48, 65, 68],
    ),
    RouteModel(
      id: '3',
      name: 'Tuyến nhanh nhất',
      durationMinutes: 12,
      distanceKm: 3.5,
      avgAqi: 62,
      maxAqi: 85,
      features: ['Đường chính'],
      coordinates: [
        const LatLng(16.0544, 108.2022), // Start
        const LatLng(16.0570, 108.2060),
        const LatLng(16.0630, 108.2140),
        const LatLng(16.0700, 108.2250), // End
      ],
      segmentAqis: [55, 62, 75, 85],
    ),
  ];

  static const String mockAIAdvice = '''Khuyến nghị chọn "Tuyến sạch nhất" vì:
• AQI trung bình thấp nhất (38)
• Đi qua công viên 29/3 với nhiều cây xanh
• Tránh đường Nguyễn Văn Linh có lưu lượng xe cao''';

  // Tọa độ Đà Nẵng
  static const LatLng daNangCenter = LatLng(16.0544, 108.2022);
}
