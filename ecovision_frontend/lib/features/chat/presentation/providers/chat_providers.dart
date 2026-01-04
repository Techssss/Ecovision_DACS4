import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/message_model.dart';
import '../../data/services/chat_service.dart';
import '../../data/repositories/chat_repository.dart';

/// Provider cho auth token từ SharedPreferences
final authTokenProvider = FutureProvider<String?>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('access_token');
});

/// Provider cho ChatService
final chatServiceProvider = Provider<ChatService>((ref) {
  // Get auth token (will be null initially, that's ok for testing)
  final authTokenAsync = ref.watch(authTokenProvider);
  final authToken = authTokenAsync.when(
    data: (token) => token,
    loading: () => null,
    error: (_, __) => null,
  );
  
  return ChatService(
    baseUrl: 'http://10.0.2.2:8000/api/v1', // Android emulator
    authToken: authToken,
  );
});

/// Provider cho ChatRepository
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final chatService = ref.watch(chatServiceProvider);
  return ChatRepository(chatService: chatService);
});

/// Provider cho session ID (persistent trong session)
final sessionIdProvider = StateProvider<String>((ref) {
  return const Uuid().v4();
});

/// Provider cho user location
final userLocationProvider = StateProvider<Position?>((ref) => null);

/// Provider cho danh sách tin nhắn
class ChatMessagesNotifier extends StateNotifier<List<MessageModel>> {
  ChatMessagesNotifier() : super([]);

  void addMessage(MessageModel message) {
    state = [message, ...state]; // Prepend (reverse list)
  }

  void addMessages(List<MessageModel> messages) {
    state = [...messages.reversed, ...state];
  }

  void clearMessages() {
    state = [];
  }
}

final chatMessagesProvider =
    StateNotifierProvider<ChatMessagesNotifier, List<MessageModel>>((ref) {
  return ChatMessagesNotifier();
});

/// Provider cho trạng thái typing
final isTypingProvider = StateProvider<bool>((ref) => false);

/// Provider cho error message
final chatErrorProvider = StateProvider<String?>((ref) => null);
