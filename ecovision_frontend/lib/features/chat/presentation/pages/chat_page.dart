import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/models/message_model.dart';
import '../../domain/models/suggested_questions.dart';
import '../providers/chat_providers.dart';
import '../widgets/suggested_question_card.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/chat_input_field.dart';

/// Trang Trợ lý AI Chat
class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Preload location in background when page opens
    _preloadLocation();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Preload user location in background
  void _preloadLocation() {
    print('🔵 [Chat] Preloading location...');
    final repository = ref.read(chatRepositoryProvider);
    
    repository.getCurrentLocation().then((location) {
      if (location != null && mounted) {
        ref.read(userLocationProvider.notifier).state = location;
        print('✅ [Chat] Location preloaded: ${location.latitude}, ${location.longitude}');
      }
    }).catchError((e) {
      print('⚠️ [Chat] Location preload failed: $e');
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);
    final isTyping = ref.watch(isTypingProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Header
          _buildHeader(),

          // Messages list
          Expanded(
            child: messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length + (isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (isTyping && index == 0) {
                        return const TypingIndicator();
                      }

                      final messageIndex = isTyping ? index - 1 : index;
                      final message = messages[messageIndex];

                      return MessageBubble(
                        message: message,
                        onActionPressed: _handleAction,
                      );
                    },
                  ),
          ),

          // Input field
          ChatInputField(
            controller: _messageController,
            onSend: () => _handleSendMessage(_messageController.text),
            onSubmitted: _handleSendMessage,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 48, left: 20, right: 20, bottom: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00D9A3), Color(0xFF00B8D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          // Robot icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.smart_toy,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trợ lý AI',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Luôn sẵn sàng hỗ trợ bạn',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // Bot icon
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF00D9A3).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy,
              size: 64,
              color: Color(0xFF00D9A3),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Xin chào! 👋',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Tôi là trợ lý AI của bạn.\nHãy hỏi tôi bất cứ điều gì!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),

          const SizedBox(height: 32),

          // Suggested questions
          Text(
            'Câu hỏi gợi ý:',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),

          const SizedBox(height: 12),

          ...SuggestedQuestions.questions.map(
            (question) => SuggestedQuestionCard(
              question: question,
              onTap: () => _handleSendMessage(question.text),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSendMessage(String text) async {
    if (text.trim().isEmpty) return;

    print('🔵 [Chat] Sending message: $text');

    // Clear input immediately
    _messageController.clear();

    // Show typing indicator
    ref.read(isTypingProvider.notifier).state = true;
    ref.read(chatErrorProvider.notifier).state = null;

    try {
      // Get repository and session ID
      final repository = ref.read(chatRepositoryProvider);
      final sessionId = ref.read(sessionIdProvider);
      
      print('🔵 [Chat] Session ID: $sessionId');
      
      // Get user location (optional) - Don't wait if not available
      Position? userLocation = ref.read(userLocationProvider);
      
      // If no location cached, try to get it but don't wait
      if (userLocation == null) {
        print('🔵 [Chat] No cached location, will try in background');
        // Start getting location in background (don't await)
        repository.getCurrentLocation().then((location) {
          if (location != null) {
            ref.read(userLocationProvider.notifier).state = location;
            print('✅ [Chat] Location cached: ${location.latitude}, ${location.longitude}');
          }
        }).catchError((e) {
          print('⚠️ [Chat] Location error: $e');
        });
      } else {
        print('✅ [Chat] Using cached location: ${userLocation.latitude}, ${userLocation.longitude}');
      }

      print('🔵 [Chat] Calling API...');
      
      // Send message to API immediately (with or without location)
      final messages = await repository.sendMessageWithContext(
        content: text,
        sessionId: sessionId,
        userLocation: userLocation, // null is OK
      );

      print('✅ [Chat] API response received');

      // Add messages to UI
      final userMessage = messages['user']!;
      final botMessage = messages['bot']!;

      print('🔵 [Chat] User message: ${userMessage.text}');
      print('🔵 [Chat] Bot message: ${botMessage.text}');

      ref.read(chatMessagesProvider.notifier).addMessage(userMessage);
      ref.read(chatMessagesProvider.notifier).addMessage(botMessage);

      // Auto scroll to bottom
      _scrollToBottom();
      
      print('✅ [Chat] Message sent successfully');
    } catch (e, stackTrace) {
      print('❌ [Chat] Error: $e');
      print('❌ [Chat] Stack trace: $stackTrace');
      
      // Show error
      ref.read(chatErrorProvider.notifier).state = 
          'Không thể gửi tin nhắn. Vui lòng thử lại!';
      
      // Determine error type
      String errorMessage = 'Lỗi không xác định';
      if (e.toString().contains('Connection refused') || 
          e.toString().contains('Failed host lookup')) {
        errorMessage = 'Không thể kết nối server. Kiểm tra backend đang chạy!';
      } else if (e.toString().contains('Unauthorized')) {
        errorMessage = 'Chưa đăng nhập. Vui lòng đăng nhập trước!';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Timeout. Server phản hồi quá chậm!';
      } else {
        errorMessage = 'Lỗi: ${e.toString()}';
      }
      
      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Chi tiết',
              textColor: Colors.white,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Chi tiết lỗi'),
                    content: SingleChildScrollView(
                      child: Text(e.toString()),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Đóng'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }
    } finally {
      // Hide typing indicator
      ref.read(isTypingProvider.notifier).state = false;
    }
  }

  void _handleAction(MessageAction action) {
    switch (action.actionType) {
      case 'navigate_to_map':
        // Navigate to Map screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đang chuyển đến bản đồ...'),
            duration: Duration(seconds: 1),
          ),
        );
        // TODO: Navigate to map page
        break;
      case 'open_report':
        // Navigate to Report screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đang mở trang báo cáo...'),
            duration: Duration(seconds: 1),
          ),
        );
        // TODO: Navigate to report page
        break;
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
}
