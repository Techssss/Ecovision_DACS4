import 'user_profile_model.dart';
import 'activity_stats_model.dart';

/// Mock data cho profile
class MockProfileData {
  static final UserProfileModel userProfile = UserProfileModel(
    name: 'Nguyễn Văn A',
    email: 'nguyen.vana@example.com',
    avatarInitials: 'ND',
    avatarUrl: null,
    memberSince: DateTime(2024, 1, 15),
  );

  static final ActivityStatsModel stats = ActivityStatsModel(
    reportsCount: 12,
    appUsageDays: 485,
    streakDays: 8,
  );

  static final String favoriteLocation = 'Sơn Trà, Đà Nẵng';
}
