import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/message_model.dart';

/// Service để gọi Chat API
class ChatService {
  final String baseUrl;
  final String? authToken;

  ChatService({
    required this.baseUrl,
    this.authToken,
  });

  /// Gửi tin nhắn và nhận phản hồi từ bot
  Future<Map<String, dynamic>> sendMessage({
    required String content,
    String? sessionId,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/chat/message');
      
      final headers = {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

      final body = jsonEncode({
        'content': content,
        if (sessionId != null) 'session_id': sessionId,
      });

      final response = await http.post(
        url,
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          return data['data'];
        } else {
          throw Exception(data['message'] ?? 'Unknown error');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  /// Lấy lịch sử chat
  Future<List<MessageModel>> getChatHistory({
    String? sessionId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final queryParams = {
        'limit': limit.toString(),
        'offset': offset.toString(),
        if (sessionId != null) 'session_id': sessionId,
      };

      final url = Uri.parse('$baseUrl/chat/history')
          .replace(queryParameters: queryParams);

      final headers = {
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          final messages = (data['data']['data'] as List)
              .map((json) => MessageModel.fromJson(json))
              .toList();
          return messages;
        } else {
          throw Exception(data['message'] ?? 'Unknown error');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get chat history: $e');
    }
  }

  /// Xóa session chat
  Future<void> deleteSession(String sessionId) async {
    try {
      final url = Uri.parse('$baseUrl/chat/sessions/$sessionId');

      final headers = {
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

      final response = await http.delete(url, headers: headers);

      if (response.statusCode != 200) {
        throw Exception('Failed to delete session');
      }
    } catch (e) {
      throw Exception('Failed to delete session: $e');
    }
  }
}
