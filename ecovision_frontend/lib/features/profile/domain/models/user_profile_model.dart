/// Model cho thông tin user profile
class UserProfileModel {
  final String name;
  final String email;
  final String? avatarInitials; // "ND" nếu không có ảnh
  final String? avatarUrl;
  final DateTime memberSince;

  UserProfileModel({
    required this.name,
    required this.email,
    this.avatarInitials,
    this.avatarUrl,
    required this.memberSince,
  });

  /// Lấy badge membership dựa trên thời gian tham gia
  String get membershipBadge {
    final daysSince = DateTime.now().difference(memberSince).inDays;
    if (daysSince > 365) return 'Thành viên Vàng';
    if (daysSince > 180) return 'Thành viên Xanh';
    return 'Thành viên Mới';
  }
}
