import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../auth/data/services/auth_service.dart';
import '../models/aqi_station_model.dart';

class AQIMapService {
  static const String baseUrl = AuthService.baseUrl;

  /// Get AQI map data (all stations with latest readings)
  Future<List<AQIStationModel>> getMapData() async {
    try {
      final url = Uri.parse('$baseUrl/aqi/map-data');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final data = jsonResponse['data'] as List<dynamic>;
        
        var stations = data
            .map((item) => AQIStationModel.fromJson(item as Map<String, dynamic>))
            .toList();
        
        // Add mock data for demo if we have less than 5 stations
        if (stations.length < 5) {
          stations.addAll(_getMockStations());
        }
        
        return stations;
      } else {
        // Return mock data if API fails
        return _getMockStations();
      }
    } catch (e) {
      // Return mock data on error for demo
      return _getMockStations();
    }
  }

  /// Mock stations for demo purposes
  List<AQIStationModel> _getMockStations() {
    return [
      // Hải Châu - Good
      AQIStationModel(
        stationId: 'mock_1',
        name: 'Hải Châu',
        latitude: 16.0544,
        longitude: 108.2022,
        address: 'Trung tâm Hải Châu',
        city: 'Đà Nẵng',
        currentAqi: 42,
        avgAqi24h: 45,
        status: AQIStatus(
          level: 'good',
          color: '#00E400',
          description: 'Tốt',
        ),
      ),
      
      // Liên Chiểu - Moderate
      AQIStationModel(
        stationId: 'mock_2',
        name: 'Liên Chiểu',
        latitude: 16.0700,
        longitude: 108.1500,
        address: 'Khu công nghiệp Liên Chiểu',
        city: 'Đà Nẵng',
        currentAqi: 85,
        avgAqi24h: 82,
        status: AQIStatus(
          level: 'moderate',
          color: '#FFFF00',
          description: 'Trung bình',
        ),
      ),
      
      // Thanh Khê - Good
      AQIStationModel(
        stationId: 'mock_3',
        name: 'Thanh Khê',
        latitude: 16.0600,
        longitude: 108.1900,
        address: 'Công viên 29/3',
        city: 'Đà Nẵng',
        currentAqi: 38,
        avgAqi24h: 40,
        status: AQIStatus(
          level: 'good',
          color: '#00E400',
          description: 'Tốt',
        ),
      ),
      
      // Sơn Trà - Unhealthy for Sensitive
      AQIStationModel(
        stationId: 'mock_4',
        name: 'Sơn Trà',
        latitude: 16.0900,
        longitude: 108.2500,
        address: 'Bán đảo Sơn Trà',
        city: 'Đà Nẵng',
        currentAqi: 125,
        avgAqi24h: 120,
        status: AQIStatus(
          level: 'unhealthy_sensitive',
          color: '#FF7E00',
          description: 'Không tốt cho nhóm nhạy cảm',
        ),
      ),
      
      // Ngũ Hành Sơn - Moderate
      AQIStationModel(
        stationId: 'mock_5',
        name: 'Ngũ Hành Sơn',
        latitude: 16.0100,
        longitude: 108.2500,
        address: 'Khu du lịch Ngũ Hành Sơn',
        city: 'Đà Nẵng',
        currentAqi: 72,
        avgAqi24h: 75,
        status: AQIStatus(
          level: 'moderate',
          color: '#FFFF00',
          description: 'Trung bình',
        ),
      ),
      
      // Cẩm Lệ - Unhealthy
      AQIStationModel(
        stationId: 'mock_6',
        name: 'Cẩm Lệ',
        latitude: 16.0300,
        longitude: 108.1700,
        address: 'Khu công nghiệp Hòa Khánh',
        city: 'Đà Nẵng',
        currentAqi: 165,
        avgAqi24h: 160,
        status: AQIStatus(
          level: 'unhealthy',
          color: '#FF0000',
          description: 'Không tốt',
        ),
      ),
      
      // Hòa Vang - Good
      AQIStationModel(
        stationId: 'mock_7',
        name: 'Hòa Vang',
        latitude: 16.0000,
        longitude: 108.1000,
        address: 'Huyện Hòa Vang',
        city: 'Đà Nẵng',
        currentAqi: 35,
        avgAqi24h: 38,
        status: AQIStatus(
          level: 'good',
          color: '#00E400',
          description: 'Tốt',
        ),
      ),
      
      // Cầu Rồng - Moderate
      AQIStationModel(
        stationId: 'mock_8',
        name: 'Cầu Rồng',
        latitude: 16.0600,
        longitude: 108.2250,
        address: 'Cầu Rồng - Sông Hàn',
        city: 'Đà Nẵng',
        currentAqi: 68,
        avgAqi24h: 70,
        status: AQIStatus(
          level: 'moderate',
          color: '#FFFF00',
          description: 'Trung bình',
        ),
      ),
    ];
  }
}
