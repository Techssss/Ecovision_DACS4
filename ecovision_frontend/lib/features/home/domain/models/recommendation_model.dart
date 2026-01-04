import 'package:flutter/material.dart';

/// Model cho khuyến nghị từ AI
class RecommendationModel {
  final String id;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String timeRange;

  RecommendationModel({
    required this.id,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.timeRange,
  });

  // Mock data cho testing
  static List<RecommendationModel> getMockData() {
    return [
      RecommendationModel(
        id: '1',
        icon: Icons.directions_run,
        iconColor: const Color(0xFF4CAF50),
        title: 'Không khí tốt – phù hợp để chạy bộ buổi sáng',
        timeRange: '6:00 - 8:00 AM',
      ),
      RecommendationModel(
        id: '2',
        icon: Icons.warning_amber_rounded,
        iconColor: const Color(0xFFFF9800),
        title: 'Chiều nay có mưa lớn – tránh đường Nguyễn Văn Linh',
        timeRange: '4:00 - 6:00 PM',
      ),
      RecommendationModel(
        id: '3',
        icon: Icons.trending_up,
        iconColor: const Color(0xFF2196F3),
        title: 'Chất lượng không khí sẽ cải thiện vào chiều tối',
        timeRange: '6:00 PM trở đi',
      ),
    ];
  }
}
