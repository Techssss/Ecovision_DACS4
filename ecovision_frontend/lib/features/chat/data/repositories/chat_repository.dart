import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../../domain/models/message_model.dart';
import '../services/chat_service.dart';

/// Repository quản lý chat với context (AQI, location, etc.)
class ChatRepository {
  final ChatService chatService;

  ChatRepository({required this.chatService});

  /// Gửi tin nhắn với context đầy đủ
  Future<Map<String, MessageModel>> sendMessageWithContext({
    required String content,
    String? sessionId,
    Position? userLocation,
  }) async {
    try {
      // Gọi API với location nếu có
      final response = await chatService.sendMessage(
        content: content,
        sessionId: sessionId,
        latitude: userLocation?.latitude,
        longitude: userLocation?.longitude,
      );

      // Parse user message
      final userMessageData = response['user_message'];
      final userMessage = MessageModel.fromJson(userMessageData);

      // Parse bot message
      final botMessageData = response['bot_message'];
      final botMessage = MessageModel.fromJson(botMessageData);

      return {
        'user': userMessage,
        'bot': botMessage,
      };
    } catch (e) {
      rethrow;
    }
  }

  /// Lấy lịch sử chat
  Future<List<MessageModel>> getChatHistory({
    String? sessionId,
    int limit = 50,
  }) async {
    try {
      return await chatService.getChatHistory(
        sessionId: sessionId,
        limit: limit,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Xóa session
  Future<void> deleteSession(String sessionId) async {
    try {
      await chatService.deleteSession(sessionId);
    } catch (e) {
      rethrow;
    }
  }

  /// Lấy vị trí hiện tại của user
  Future<Position?> getCurrentLocation() async {
    try {
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      // Get location with timeout (don't wait too long)
      try {
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 5), // Max 5 seconds
        ).timeout(
          const Duration(seconds: 5),
          onTimeout: () async {
            print('⚠️ Location timeout, trying last known position');
            // Try to get last known position as fallback
            final lastKnown = await Geolocator.getLastKnownPosition();
            if (lastKnown != null) {
              return lastKnown;
            }
            // If no last known position, throw to be caught below
            throw TimeoutException('No location available');
          },
        );
      } on TimeoutException {
        print('⚠️ Location timeout, no fallback available');
        return null;
      }
    } catch (e) {
      print('Error getting location: $e');
      // Try last known position as fallback
      try {
        return await Geolocator.getLastKnownPosition();
      } catch (e2) {
        return null;
      }
    }
  }
}
