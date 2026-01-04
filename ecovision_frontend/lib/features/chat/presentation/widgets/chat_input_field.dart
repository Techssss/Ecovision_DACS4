import 'package:flutter/material.dart';

/// Thanh nhập tin nhắn dưới cùng
class ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final Function(String) onSubmitted;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Nhập câu hỏi của bạn...',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onSubmitted: onSubmitted,
            ),
          ),
          const SizedBox(width: 12),

          // Send button
          Material(
            color: const Color(0xFF00D9A3),
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onSend,
              customBorder: const CircleBorder(),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: const Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
