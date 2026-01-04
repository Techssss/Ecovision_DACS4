/// Model cho báo cáo ô nhiễm
class ReportModel {
  final String id;
  final String type;
  final String location;
  final String status;
  final DateTime timestamp;
  final String? description;
  final String? imagePath;
  final String? trackingCode;

  ReportModel({
    required this.id,
    required this.type,
    required this.location,
    required this.status,
    required this.timestamp,
    this.description,
    this.imagePath,
    this.trackingCode,
  });

  // Format thời gian hiển thị
  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${difference.inDays} ngày trước';
    }
  }
}
