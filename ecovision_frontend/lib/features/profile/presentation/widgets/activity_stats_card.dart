import 'package:flutter/material.dart';
import '../../domain/models/activity_stats_model.dart';

/// Card thống kê hoạt động
class ActivityStatsCard extends StatelessWidget {
  final ActivityStatsModel stats;

  const ActivityStatsCard({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thống kê hoạt động',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),

          // Stats Grid (3 columns)
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.description,
                  iconColor: const Color(0xFF64B5F6), // Blue
                  value: '${stats.reportsCount}',
                  label: 'Báo cáo đã gửi',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.favorite,
                  iconColor: const Color(0xFFE57373), // Red
                  value: '${stats.appUsageDays}',
                  label: 'Điểm dùng app',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.shield,
                  iconColor: const Color(0xFFBA68C8), // Purple
                  value: '${stats.streakDays}',
                  label: 'Tuần liên tiếp',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
