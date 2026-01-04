import '../services/profile_service.dart';
import '../models/profile_api_models.dart';
import '../../domain/models/user_profile_model.dart';
import '../../domain/models/activity_stats_model.dart';
import '../../domain/models/user_settings_model.dart';

/// Repository để quản lý business logic cho profile
class ProfileRepository {
  final ProfileService _service;

  ProfileRepository({ProfileService? service})
      : _service = service ?? ProfileService();

  /// Get user profile
  Future<UserProfileModel> getProfile() async {
    try {
      final response = await _service.getProfile();
      return response.toDomainModel();
    } catch (e) {
      // Fallback to mock data nếu có lỗi
      print('Error getting profile: $e');
      rethrow;
    }
  }

  /// Update user profile
  Future<UserProfileModel> updateProfile(UpdateProfileRequest request) async {
    try {
      final response = await _service.updateProfile(request);
      return response.toDomainModel();
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  /// Get user statistics
  Future<ActivityStatsModel> getStats() async {
    try {
      final response = await _service.getStats();
      return response.toDomainModel();
    } catch (e) {
      print('Error getting stats: $e');
      rethrow;
    }
  }

  /// Get favorite location name từ stats
  Future<String?> getFavoriteLocationName() async {
    try {
      final response = await _service.getStats();
      return response.getFavoriteLocationName();
    } catch (e) {
      print('Error getting favorite location: $e');
      return null;
    }
  }

  /// Get user settings
  Future<UserSettingsModel> getSettings() async {
    try {
      final response = await _service.getSettings();
      return response.toDomainModel();
    } catch (e) {
      print('Error getting settings: $e');
      rethrow;
    }
  }

  /// Update user settings
  Future<UserSettingsModel> updateSettings(UpdateSettingsRequest request) async {
    try {
      final response = await _service.updateSettings(request);
      return response.toDomainModel();
    } catch (e) {
      print('Error updating settings: $e');
      rethrow;
    }
  }

  /// Get favorite location name từ settings
  Future<String?> getFavoriteLocationNameFromSettings() async {
    try {
      final response = await _service.getSettings();
      return response.getFavoriteLocationName();
    } catch (e) {
      print('Error getting favorite location from settings: $e');
      return null;
    }
  }
}
