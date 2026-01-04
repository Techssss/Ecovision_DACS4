import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../auth/data/services/auth_service.dart';
import '../../../auth/data/models/auth_models.dart';

class AQITrendService {
  static const String baseUrl = AuthService.baseUrl;

  /// Get access token từ AuthService
  Future<String?> _getAccessToken() async {
    final authService = AuthService();
    return await authService.getAccessToken();
  }

  /// Get AQI trend data
  Future<List<AQITrendData>> getTrend({int days = 7}) async {
    try {
      final url = Uri.parse('$baseUrl/aqi/trend?days=$days');
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      // Try to get token, but don't require it (trend endpoint may be public)
      try {
        final token = await _getAccessToken();
        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
        }
      } catch (e) {
        // Ignore token errors, continue without auth
        print('⚠️ Token error (ignored): $e');
      }

      print('📊 Fetching AQI trend from: $url');
      print('📊 Headers: $headers');
      
      final response = await http.get(
        url, 
        headers: headers,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout after 10 seconds');
        },
      );
      
      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body length: ${response.body.length}');
      
      if (response.statusCode != 200) {
        print('❌ Error response: ${response.body}');
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      print('📡 Parsed JSON: success=${jsonResponse['success']}, data length=${jsonResponse['data']?.length ?? 0}');

      if (response.statusCode == 200) {
        // Parse response
        final success = jsonResponse['success'] as bool? ?? false;
        final message = jsonResponse['message'] as String? ?? '';
        final data = jsonResponse['data'];

        if (success && data != null) {
          // Data is a List
          if (data is List) {
            return data
                .map((item) => AQITrendData.fromJson(item as Map<String, dynamic>))
                .toList();
          } else {
            throw Exception('Invalid data format: expected List');
          }
        }
        throw Exception(message.isNotEmpty ? message : 'Failed to get AQI trend');
      } else {
        final errorMessage = jsonResponse['message'] as String? ??
            jsonResponse['detail'] as String? ??
            'Failed to get AQI trend';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('❌ AQI Trend Error: $e');
      print('❌ Error type: ${e.runtimeType}');
      if (e is http.ClientException) {
        throw Exception('Network error: Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.');
      } else if (e is FormatException) {
        throw Exception('Parse error: Dữ liệu không hợp lệ từ server.');
      } else if (e.toString().contains('timeout')) {
        throw Exception('Timeout: Kết nối quá lâu. Vui lòng thử lại.');
      } else if (e.toString().contains('Failed host lookup') || e.toString().contains('SocketException')) {
        throw Exception('Network error: Không thể kết nối đến server. Vui lòng kiểm tra backend có đang chạy không.');
      }
      // Re-throw with more context
      throw Exception('Lỗi tải dữ liệu: ${e.toString()}');
    }
  }
}

/// Model cho AQI trend data
class AQITrendData {
  final String date;
  final double avgAqi;
  final int maxAqi;
  final int minAqi;

  AQITrendData({
    required this.date,
    required this.avgAqi,
    required this.maxAqi,
    required this.minAqi,
  });

  factory AQITrendData.fromJson(Map<String, dynamic> json) {
    return AQITrendData(
      date: json['date'] as String,
      avgAqi: (json['avg_aqi'] as num).toDouble(),
      maxAqi: json['max_aqi'] as int,
      minAqi: json['min_aqi'] as int,
    );
  }

  /// Get day name (T2, T3, T4, etc.)
  String getDayName() {
    try {
      final dateTime = DateTime.parse(date);
      final dayNames = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
      return dayNames[dateTime.weekday % 7];
    } catch (e) {
      return date;
    }
  }
}

