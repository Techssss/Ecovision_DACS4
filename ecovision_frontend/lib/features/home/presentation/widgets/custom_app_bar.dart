import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';

/// Custom App Bar cho trang chủ
class CustomAppBar extends StatelessWidget {
  final String? locationName;
  
  const CustomAppBar({
    super.key,
    this.locationName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          // Thông tin app và location
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EcoVision',
                  style: AppTextStyles.appBarTitle,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 14,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        locationName ?? 'Đang tải vị trí...',
                        style: AppTextStyles.appBarSubtitle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Nút bản đồ
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.map_outlined,
                  size: 18,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  'Bản đồ',
                  style: AppTextStyles.appBarSubtitle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
