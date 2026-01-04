/// Model cho dữ liệu chất lượng không khí
class AirQualityModel {
  final int aqi;
  final String status; // "Tốt", "Trung bình", etc.
  final double temperature;
  final int humidity;

  AirQualityModel({
    required this.aqi,
    required this.status,
    required this.temperature,
    required this.humidity,
  });

  // Mock data cho testing
  factory AirQualityModel.mock() {
    return AirQualityModel(
      aqi: 45,
      status: 'Tốt',
      temperature: 28.0,
      humidity: 75,
    );
  }
}
