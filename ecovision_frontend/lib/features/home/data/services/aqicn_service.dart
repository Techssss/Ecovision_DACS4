import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class AQICNService {
  static const String _token = 'dbc8c655ec89ad7348a462d694efcdcd66129964';
  static const String _baseUrl = 'https://api.waqi.info';

  Future<Map<String, dynamic>> fetchAQIByLocation(double lat, double lon) async {
    final url = '$_baseUrl/feed/geo:$lat;$lon/?token=$_token';
    
    print('🌍 Fetching AQI from: $url');
    
    // Retry logic: try 2 times with longer timeout
    for (int attempt = 1; attempt <= 2; attempt++) {
      try {
        print('🔄 Attempt $attempt/2...');
        
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Accept': 'application/json',
            'Connection': 'keep-alive',
          },
        ).timeout(
          const Duration(seconds: 20), // Increased timeout to 20 seconds
          onTimeout: () {
            print('⏱️ Timeout after 20 seconds');
            throw TimeoutException('Request timeout after 20 seconds');
          },
        );

        print('📡 Status: ${response.statusCode}');

        if (response.statusCode == 200) {
          final json = jsonDecode(response.body);
          
          if (json['status'] == 'ok') {
            print('✅ AQI: ${json['data']['aqi']}');
            return json['data'];
          } else {
            throw Exception('API error: ${json['status']}');
          }
        } else {
          throw Exception('HTTP ${response.statusCode}');
        }
      } catch (e) {
        if (attempt == 2) {
          // Last attempt failed, rethrow
          print('❌ All attempts failed: $e');
          rethrow;
        }
        // Wait a bit before retry
        await Future.delayed(const Duration(seconds: 2));
      }
    }
    
    throw Exception('Failed to fetch AQI after 2 attempts');
  }
}
