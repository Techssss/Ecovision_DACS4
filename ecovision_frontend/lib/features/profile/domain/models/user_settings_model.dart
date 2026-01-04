/// Model cho cài đặt user
class UserSettingsModel {
  final bool aqiNotifications;
  final bool autoLocation;
  final bool reminderNotifications;

  UserSettingsModel({
    required this.aqiNotifications,
    required this.autoLocation,
    required this.reminderNotifications,
  });

  UserSettingsModel copyWith({
    bool? aqiNotifications,
    bool? autoLocation,
    bool? reminderNotifications,
  }) {
    return UserSettingsModel(
      aqiNotifications: aqiNotifications ?? this.aqiNotifications,
      autoLocation: autoLocation ?? this.autoLocation,
      reminderNotifications:
          reminderNotifications ?? this.reminderNotifications,
    );
  }
}
