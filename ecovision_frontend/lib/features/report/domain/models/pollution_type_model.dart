import 'package:flutter/material.dart';

/// Model cho loại ô nhiễm
class PollutionTypeModel {
  final String id;
  final String label;
  final IconData icon;
  final Color iconColor;
  final String category;

  PollutionTypeModel({
    required this.id,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.category,
  });

  // Danh sách 6 loại ô nhiễm
  static List<PollutionTypeModel> getAllTypes() {
    return [
      PollutionTypeModel(
        id: 'air',
        label: 'Ô nhiễm không khí',
        icon: Icons.air,
        iconColor: const Color(0xFF81C784), // Light green
        category: 'air_pollution',
      ),
      PollutionTypeModel(
        id: 'water',
        label: 'Ô nhiễm nước',
        icon: Icons.water_drop,
        iconColor: const Color(0xFF64B5F6), // Blue
        category: 'water_pollution',
      ),
      PollutionTypeModel(
        id: 'trash',
        label: 'Rác thải',
        icon: Icons.delete_outline,
        iconColor: const Color(0xFFBDBDBD), // Gray
        category: 'trash',
      ),
      PollutionTypeModel(
        id: 'noise',
        label: 'Tiếng ồn',
        icon: Icons.volume_up,
        iconColor: const Color(0xFFBA68C8), // Purple
        category: 'noise_pollution',
      ),
      PollutionTypeModel(
        id: 'dust',
        label: 'Khói bụi',
        icon: Icons.blur_on,
        iconColor: const Color(0xFFE0E0E0), // Light gray
        category: 'dust',
      ),
      PollutionTypeModel(
        id: 'other',
        label: 'Khác',
        icon: Icons.warning,
        iconColor: const Color(0xFFFFB74D), // Orange
        category: 'other',
      ),
    ];
  }
}
