import 'package:flutter/material.dart';

/// Model cho tin nhắn chat
class MessageModel {
  final String id;
  final String text;
  final bool isUser; // true = user, false = bot
  final DateTime timestamp;
  final List<MessageAction>? actions;
  final String? sessionId;

  MessageModel({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.actions,
    this.sessionId,
  });

  bool get hasActions => actions != null && actions!.isNotEmpty;

  /// Parse từ JSON API response
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    // Parse actions từ metadata nếu có
    List<MessageAction>? actions;
    if (json['message_metadata'] != null) {
      final metadata = json['message_metadata'];
      if (metadata['suggested_actions'] != null) {
        actions = (metadata['suggested_actions'] as List)
            .map((action) => MessageAction(
                  label: action,
                  icon: Icons.help_outline,
                  actionType: 'quick_action',
                ))
            .toList();
      }
    }

    return MessageModel(
      id: json['id'],
      text: json['content'],
      isUser: json['is_user'] ?? false,
      timestamp: DateTime.parse(json['created_at']),
      actions: actions,
      sessionId: json['session_id'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': text,
      'is_user': isUser,
      'created_at': timestamp.toIso8601String(),
      if (sessionId != null) 'session_id': sessionId,
    };
  }
}

/// Model cho action buttons trong bot messages
class MessageAction {
  final String label;
  final IconData icon;
  final String actionType;
  final Map<String, dynamic>? data;

  MessageAction({
    required this.label,
    required this.icon,
    required this.actionType,
    this.data,
  });
}
