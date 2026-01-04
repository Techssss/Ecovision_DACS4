import 'package:flutter/material.dart';

/// Câu hỏi gợi ý cho user
class SuggestedQuestions {
  static final List<SuggestedQuestion> questions = [
    SuggestedQuestion(
      text: 'Hôm nay có nên chạy bộ không?',
      icon: Icons.directions_run,
    ),
    SuggestedQuestion(
      text: 'Thời điểm nào AQI tốt nhất?',
      icon: Icons.access_time,
    ),
    SuggestedQuestion(
      text: 'Đề xuất lộ trình tập thể dục',
      icon: Icons.location_on,
    ),
  ];
}

class SuggestedQuestion {
  final String text;
  final IconData icon;

  SuggestedQuestion({
    required this.text,
    required this.icon,
  });
}
