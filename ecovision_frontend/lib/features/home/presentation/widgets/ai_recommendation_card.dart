import 'package:flutter/material.dart';
import '../../domain/models/recommendation_model.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Card hiển thị khuyến nghị từ AI
class AiRecommendationCard extends StatelessWidget {
  final RecommendationModel recommendation;

  const AiRecommendationCard({
    super.key,
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Icon với background màu
          CircleAvatar(
            radius: 24,
            backgroundColor: recommendation.iconColor.withOpacity(0.15),
            child: Icon(
              recommendation.icon,
              color: recommendation.iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          
          // Nội dung
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation.title,
                  style: AppTextStyles.recommendationTitle,
                ),
                const SizedBox(height: 4),
                Text(
                  recommendation.timeRange,
                  style: AppTextStyles.recommendationTime,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
