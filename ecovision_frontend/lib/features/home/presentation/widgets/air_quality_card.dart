import 'package:flutter/material.dart';
import '../../domain/models/air_quality_model.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';

/// Card hiển thị chỉ số chất lượng không khí
class AirQualityCard extends StatelessWidget {
  final AirQualityModel data;

  const AirQualityCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề
          Text(
            'Chỉ số chất lượng không khí',
            style: AppTextStyles.cardTitle,
          ),
          const SizedBox(height: 8),
          
          // Số AQI lớn
          Center(
            child: Text(
              '${data.aqi}',
              style: AppTextStyles.aqiNumber,
            ),
          ),
          
          // Badge trạng thái
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Text(
                data.status,
                style: AppTextStyles.statusBadge,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Nhiệt độ và độ ẩm
          Row(
            children: [
              // Nhiệt độ
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.air,
                  label: 'Nhiệt độ',
                  value: '${data.temperature.toInt()}°C',
                ),
              ),
              const SizedBox(width: 16),
              // Độ ẩm
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.water_drop_outlined,
                  label: 'Độ ẩm',
                  value: '${data.humidity}%',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: Colors.white70,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.cardTitle.copyWith(fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.appBarTitle.copyWith(fontSize: 24),
        ),
      ],
    );
  }
}
