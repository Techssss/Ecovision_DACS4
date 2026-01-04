/// Model cho thống kê hoạt động
class ActivityStatsModel {
  final int reportsCount; // Số báo cáo đã gửi
  final int appUsageDays; // Điểm dùng app
  final int streakDays; // Số tuần liên tiếp

  ActivityStatsModel({
    required this.reportsCount,
    required this.appUsageDays,
    required this.streakDays,
  });
}
