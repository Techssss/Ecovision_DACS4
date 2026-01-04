import 'package:flutter/material.dart';
import '../../domain/models/report_model.dart';

/// Card hiển thị báo cáo gần đây
class RecentReportCard extends StatelessWidget {
  final ReportModel report;

  const RecentReportCard({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(report.status);
    final icon = _getIcon(report.type);
    final iconColor = _getIconColor(report.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getTypeText(report.type),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  report.location,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  report.getTimeAgo(),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),

          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getStatusText(report.status),
              style: TextStyle(
                fontSize: 11,
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'chờ xử lý':
        return const Color(0xFF9E9E9E); // Gray
      case 'reviewing':
      case 'đang xử lý':
        return const Color(0xFFFFB74D); // Orange
      case 'resolved':
      case 'đã xử lý':
        return const Color(0xFF4CAF50); // Green
      case 'rejected':
      case 'từ chối':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Chờ xử lý';
      case 'reviewing':
        return 'Đang xử lý';
      case 'resolved':
        return 'Đã xử lý';
      case 'rejected':
        return 'Từ chối';
      default:
        return status;
    }
  }

  IconData _getIcon(String type) {
    switch (type.toLowerCase()) {
      case 'trash':
      case 'rác thải':
        return Icons.delete_outline;
      case 'water_pollution':
      case 'ô nhiễm nước':
        return Icons.water_drop;
      case 'air_pollution':
      case 'ô nhiễm không khí':
        return Icons.air;
      case 'noise':
      case 'tiếng ồn':
        return Icons.volume_up;
      case 'smoke':
      case 'khói bụi':
        return Icons.blur_on;
      default:
        return Icons.warning;
    }
  }

  String _getTypeText(String type) {
    switch (type.toLowerCase()) {
      case 'trash':
        return 'Rác thải';
      case 'water_pollution':
        return 'Ô nhiễm nước';
      case 'air_pollution':
        return 'Ô nhiễm không khí';
      case 'noise':
        return 'Tiếng ồn';
      case 'smoke':
        return 'Khói bụi';
      default:
        return type;
    }
  }

  Color _getIconColor(String type) {
    switch (type.toLowerCase()) {
      case 'trash':
      case 'rác thải':
        return const Color(0xFFBDBDBD);
      case 'water_pollution':
      case 'ô nhiễm nước':
        return const Color(0xFF64B5F6);
      case 'air_pollution':
      case 'ô nhiễm không khí':
        return const Color(0xFF81C784);
      case 'noise':
      case 'tiếng ồn':
        return const Color(0xFFBA68C8);
      case 'smoke':
      case 'khói bụi':
        return const Color(0xFFE0E0E0);
      default:
        return const Color(0xFFFFB74D);
    }
  }
}
