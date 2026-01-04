import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/user_profile_model.dart';
import '../../domain/models/activity_stats_model.dart';
import '../../domain/models/user_settings_model.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/models/profile_api_models.dart';

/// Repository provider
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

/// Provider cho user profile - fetch từ API
final userProfileProvider = FutureProvider<UserProfileModel>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  return await repository.getProfile();
});

/// Provider cho activity stats - fetch từ API
final activityStatsProvider = FutureProvider<ActivityStatsModel>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  return await repository.getStats();
});

/// Provider cho favorite location - fetch từ API
final favoriteLocationProvider = FutureProvider<String?>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  // Thử lấy từ settings trước, nếu không có thì lấy từ stats
  final locationName = await repository.getFavoriteLocationNameFromSettings();
  if (locationName != null && locationName.isNotEmpty) {
    return locationName;
  }
  return await repository.getFavoriteLocationName();
});

/// Notifier cho settings - fetch và update từ API
class SettingsNotifier extends StateNotifier<AsyncValue<UserSettingsModel>> {
  final ProfileRepository _repository;

  SettingsNotifier(this._repository)
      : super(const AsyncValue.loading()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      state = const AsyncValue.loading();
      final settings = await _repository.getSettings();
      state = AsyncValue.data(settings);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> toggleAqiNotifications(bool value) async {
    final currentState = state.value;
    if (currentState == null) return;

    // Optimistic update
    state = AsyncValue.data(
      currentState.copyWith(aqiNotifications: value),
    );

    try {
      final request = UpdateSettingsRequest(aqiNotifications: value);
      final updated = await _repository.updateSettings(request);
      state = AsyncValue.data(updated);
    } catch (e, stackTrace) {
      // Revert on error
      state = AsyncValue.data(currentState);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> toggleAutoLocation(bool value) async {
    final currentState = state.value;
    if (currentState == null) return;

    // Optimistic update
    state = AsyncValue.data(
      currentState.copyWith(autoLocation: value),
    );

    try {
      final request = UpdateSettingsRequest(autoLocation: value);
      final updated = await _repository.updateSettings(request);
      state = AsyncValue.data(updated);
    } catch (e, stackTrace) {
      // Revert on error
      state = AsyncValue.data(currentState);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> toggleReminderNotifications(bool value) async {
    final currentState = state.value;
    if (currentState == null) return;

    // Optimistic update
    state = AsyncValue.data(
      currentState.copyWith(reminderNotifications: value),
    );

    try {
      final request = UpdateSettingsRequest(reminderNotifications: value);
      final updated = await _repository.updateSettings(request);
      state = AsyncValue.data(updated);
    } catch (e, stackTrace) {
      // Revert on error
      state = AsyncValue.data(currentState);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _loadSettings();
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AsyncValue<UserSettingsModel>>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return SettingsNotifier(repository);
});
