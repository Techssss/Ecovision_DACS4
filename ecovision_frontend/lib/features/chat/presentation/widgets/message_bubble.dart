import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/message_model.dart';
import 'action_button_chip.dart';

/// Chat bubble cho user và bot
class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final Function(MessageAction)? onActionPressed;

  const MessageBubble({
    super.key,
    required this.message,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: const BoxConstraints(maxWidth: 280),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Bubble container
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFF00D9A3) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft:
                      isUser ? const Radius.circular(16) : const Radius.circular(4),
                  bottomRight:
                      isUser ? const Radius.circular(4) : const Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 14,
                  color: isUser ? Colors.white : Colors.grey[800],
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 4),

            // Timestamp
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),

            // Action buttons (chỉ cho bot messages)
            if (!isUser && message.hasActions) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: message.actions!
                    .map((action) => ActionButtonChip(
                          label: action.label,
                          icon: action.icon,
                          onPressed: () => onActionPressed?.call(action),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';

    return DateFormat('HH:mm').format(time);
  }
}
