/// API response models cho profile
import '../../domain/models/user_profile_model.dart';
import '../../domain/models/activity_stats_model.dart';
import '../../domain/models/user_settings_model.dart';

/// Profile API response từ backend
class ProfileApiResponse {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? avatarUrl;
  final DateTime createdAt;

  ProfileApiResponse({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.avatarUrl,
    required this.createdAt,
  });

  factory ProfileApiResponse.fromJson(Map<String, dynamic> json) {
    return ProfileApiResponse(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert sang domain model
  UserProfileModel toDomainModel() {
    // Tạo avatar initials từ tên
    String? avatarInitials;
    if (avatarUrl == null && name.isNotEmpty) {
      final parts = name.trim().split(' ');
      if (parts.length >= 2) {
        avatarInitials = '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
      } else if (parts.isNotEmpty) {
        avatarInitials = parts[0][0].toUpperCase();
      }
    }

    // Xử lý avatar URL - nếu là relative path thì thêm base URL
    String? fullAvatarUrl = avatarUrl;
    if (avatarUrl != null && avatarUrl!.startsWith('/')) {
      // Relative path từ backend, cần thêm base URL
      // Backend base URL: http://10.0.2.2:8000 (không có /api/v1)
      const backendBaseUrl = 'http://10.0.2.2:8000';
      fullAvatarUrl = '$backendBaseUrl$avatarUrl';
    }

    return UserProfileModel(
      name: name,
      email: email,
      avatarInitials: avatarInitials,
      avatarUrl: fullAvatarUrl,
      memberSince: createdAt,
    );
  }
}

/// Stats API response từ backend
class StatsApiResponse {
  final int totalReports;
  final int usageDays;
  final int streak;
  final Map<String, dynamic>? favoriteLocation;

  StatsApiResponse({
    required this.totalReports,
    required this.usageDays,
    required this.streak,
    this.favoriteLocation,
  });

  factory StatsApiResponse.fromJson(Map<String, dynamic> json) {
    return StatsApiResponse(
      totalReports: json['total_reports'] as int? ?? 0,
      usageDays: json['usage_days'] as int? ?? 0,
      streak: json['streak'] as int? ?? 0,
      favoriteLocation: json['favorite_location'] as Map<String, dynamic>?,
    );
  }

  /// Convert sang domain model
  ActivityStatsModel toDomainModel() {
    return ActivityStatsModel(
      reportsCount: totalReports,
      appUsageDays: usageDays,
      streakDays: streak,
    );
  }

  /// Lấy tên favorite location
  String? getFavoriteLocationName() {
    return favoriteLocation?['name'] as String?;
  }
}

/// Settings API response từ backend
class SettingsApiResponse {
  final bool aqiNotifications;
  final bool autoLocation;
  final bool reminderNotifications;
  final double? favoriteLocationLat;
  final double? favoriteLocationLon;
  final String? favoriteLocationName;
  final String language;

  SettingsApiResponse({
    required this.aqiNotifications,
    required this.autoLocation,
    required this.reminderNotifications,
    this.favoriteLocationLat,
    this.favoriteLocationLon,
    this.favoriteLocationName,
    required this.language,
  });

  factory SettingsApiResponse.fromJson(Map<String, dynamic> json) {
    return SettingsApiResponse(
      aqiNotifications: json['aqi_notifications'] as bool? ?? true,
      autoLocation: json['auto_location'] as bool? ?? true,
      reminderNotifications: json['reminder_notifications'] as bool? ?? false,
      favoriteLocationLat: json['favorite_location_lat'] != null
          ? (json['favorite_location_lat'] as num).toDouble()
          : null,
      favoriteLocationLon: json['favorite_location_lon'] != null
          ? (json['favorite_location_lon'] as num).toDouble()
          : null,
      favoriteLocationName: json['favorite_location_name'] as String?,
      language: json['language'] as String? ?? 'vi',
    );
  }

  /// Convert sang domain model
  UserSettingsModel toDomainModel() {
    return UserSettingsModel(
      aqiNotifications: aqiNotifications,
      autoLocation: autoLocation,
      reminderNotifications: reminderNotifications,
    );
  }

  /// Lấy tên favorite location
  String? getFavoriteLocationName() {
    return favoriteLocationName;
  }
}

/// Update profile request
class UpdateProfileRequest {
  final String? name;
  final String? phone;

  UpdateProfileRequest({
    this.name,
    this.phone,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (name != null) json['name'] = name;
    if (phone != null) json['phone'] = phone;
    return json;
  }
}

/// Update settings request
class UpdateSettingsRequest {
  final bool? aqiNotifications;
  final bool? autoLocation;
  final bool? reminderNotifications;
  final double? favoriteLocationLat;
  final double? favoriteLocationLon;
  final String? favoriteLocationName;
  final String? language;

  UpdateSettingsRequest({
    this.aqiNotifications,
    this.autoLocation,
    this.reminderNotifications,
    this.favoriteLocationLat,
    this.favoriteLocationLon,
    this.favoriteLocationName,
    this.language,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (aqiNotifications != null) json['aqi_notifications'] = aqiNotifications;
    if (autoLocation != null) json['auto_location'] = autoLocation;
    if (reminderNotifications != null) json['reminder_notifications'] = reminderNotifications;
    if (favoriteLocationLat != null) json['favorite_location_lat'] = favoriteLocationLat;
    if (favoriteLocationLon != null) json['favorite_location_lon'] = favoriteLocationLon;
    if (favoriteLocationName != null) json['favorite_location_name'] = favoriteLocationName;
    if (language != null) json['language'] = language;
    return json;
  }
}
