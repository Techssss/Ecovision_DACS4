import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_providers.dart';
import '../widgets/profile_header.dart';
import '../widgets/activity_stats_card.dart';
import '../widgets/setting_toggle_item.dart';
import '../widgets/info_menu_item.dart';
import '../../../auth/data/services/auth_service.dart';

/// Trang Hồ sơ/Profile
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final statsAsync = ref.watch(activityStatsProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final favoriteLocationAsync = ref.watch(favoriteLocationProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(userProfileProvider);
            ref.invalidate(activityStatsProvider);
            ref.invalidate(favoriteLocationProvider);
            ref.read(settingsProvider.notifier).refresh();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                profileAsync.when(
                  data: (profile) => ProfileHeader(profile: profile),
                  loading: () => const _LoadingHeader(),
                  error: (err, stack) => _ErrorHeader(
                    message: 'Không thể tải thông tin',
                    onRetry: () => ref.invalidate(userProfileProvider),
                  ),
                ),

                // Activity Stats
                statsAsync.when(
                  data: (stats) => ActivityStatsCard(stats: stats),
                  loading: () => const _LoadingStats(),
                  error: (err, stack) => const SizedBox.shrink(),
                ),

                // Settings Section
                settingsAsync.when(
                  data: (settings) => _buildSettingsSection(context, ref, settings),
                  loading: () => const _LoadingSettings(),
                  error: (err, stack) => _ErrorSection(
                    message: 'Không thể tải cài đặt',
                    onRetry: () => ref.read(settingsProvider.notifier).refresh(),
                  ),
                ),

                // Favorite Location
                favoriteLocationAsync.when(
                  data: (location) => _buildFavoriteLocation(
                    context,
                    ref,
                    location ?? 'Chưa đặt vị trí',
                  ),
                  loading: () => const _LoadingLocation(),
                  error: (err, stack) => _buildFavoriteLocation(
                    context,
                    ref,
                    'Chưa đặt vị trí',
                  ),
                ),

                // Info Section
                _buildInfoSection(context, ref),

                const SizedBox(height: 80), // Space cho bottom nav
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    WidgetRef ref,
    settings,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cài đặt',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                SettingToggleItem(
                  icon: Icons.notifications,
                  iconColor: const Color(0xFF64B5F6),
                  title: 'Thông báo AQI',
                  subtitle: 'Nhận cảnh báo khi chất lượng không khí xấu',
                  value: settings.aqiNotifications,
                  onChanged: (val) async {
                    await ref
                        .read(settingsProvider.notifier)
                        .toggleAqiNotifications(val);
                  },
                ),
                Divider(height: 1, indent: 60, color: Colors.grey[200]),
                SettingToggleItem(
                  icon: Icons.my_location,
                  iconColor: const Color(0xFF00D9A3),
                  title: 'Vị trí tự động',
                  subtitle: 'Tự động cập nhật vị trí của bạn',
                  value: settings.autoLocation,
                  onChanged: (val) async {
                    await ref
                        .read(settingsProvider.notifier)
                        .toggleAutoLocation(val);
                  },
                ),
                Divider(height: 1, indent: 60, color: Colors.grey[200]),
                SettingToggleItem(
                  icon: Icons.alarm,
                  iconColor: const Color(0xFFFFB74D),
                  title: 'Nhắc tập thể dục',
                  subtitle: 'Gửi thông báo khi không khí tốt',
                  value: settings.reminderNotifications,
                  onChanged: (val) async {
                    await ref
                        .read(settingsProvider.notifier)
                        .toggleReminderNotifications(val);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteLocation(
    BuildContext context,
    WidgetRef ref,
    String location,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vị trí ưa thích',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D9A3).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Color(0xFF00D9A3),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Vị trí mặc định',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),

                TextButton(
                  onPressed: () => _showLocationPicker(context, ref),
                  child: const Text(
                    'Thay đổi',
                    style: TextStyle(
                      color: Color(0xFF00D9A3),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                InfoMenuItem(
                  icon: Icons.email,
                  title: 'Liên hệ hỗ trợ',
                  onTap: () => _handleContact(context),
                ),
                Divider(height: 1, indent: 60, color: Colors.grey[200]),
                InfoMenuItem(
                  icon: Icons.info,
                  title: 'Về ứng dụng',
                  onTap: () => _handleAbout(context),
                ),
                Divider(height: 1, indent: 60, color: Colors.grey[200]),
                InfoMenuItem(
                  icon: Icons.shield,
                  title: 'Chính sách bảo mật',
                  onTap: () => _handlePrivacy(context),
                ),
                Divider(height: 1, indent: 60, color: Colors.grey[200]),
                InfoMenuItem(
                  icon: Icons.logout,
                  title: 'Đăng xuất',
                  iconColor: Colors.red,
                  textColor: Colors.red,
                  onTap: () => _handleLogout(context, ref),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      try {
        final authService = AuthService();
        await authService.logout();

        // Clear all providers
        ref.invalidate(userProfileProvider);
        ref.invalidate(activityStatsProvider);
        ref.invalidate(favoriteLocationProvider);
        ref.invalidate(settingsProvider);

        // Navigate to login
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi đăng xuất: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showLocationPicker(BuildContext context, WidgetRef ref) async {
    // TODO: Implement location picker với API
    // Hiện tại giữ nguyên UI nhưng cần update để gọi API
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn vị trí ưa thích'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LocationOption(
              location: 'Sơn Trà, Đà Nẵng',
              onTap: () async {
                // TODO: Update favorite location via API
                // final repository = ref.read(profileRepositoryProvider);
                // await repository.updateSettings(UpdateSettingsRequest(
                //   favoriteLocationName: 'Sơn Trà, Đà Nẵng',
                //   favoriteLocationLat: 16.0544,
                //   favoriteLocationLon: 108.2022,
                // ));
                ref.invalidate(favoriteLocationProvider);
                Navigator.pop(context);
              },
            ),
            _LocationOption(
              location: 'Hải Châu, Đà Nẵng',
              onTap: () async {
                // TODO: Update favorite location via API
                ref.invalidate(favoriteLocationProvider);
                Navigator.pop(context);
              },
            ),
            _LocationOption(
              location: 'Thanh Khê, Đà Nẵng',
              onTap: () async {
                // TODO: Update favorite location via API
                ref.invalidate(favoriteLocationProvider);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleContact(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Liên hệ hỗ trợ'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: support@danangai.vn'),
            SizedBox(height: 8),
            Text('Hotline: 0236.123.4567'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _handleAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Về ứng dụng'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Da Nang AI for Life'),
            SizedBox(height: 8),
            Text('Phiên bản: 1.0.0'),
            SizedBox(height: 8),
            Text(
              'Ứng dụng giúp bạn theo dõi chất lượng không khí và tìm lộ trình di chuyển thông minh.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _handlePrivacy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chính sách bảo mật'),
        content: const Text(
          'Chúng tôi cam kết bảo mật thông tin cá nhân của bạn...',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}

class _LocationOption extends StatelessWidget {
  final String location;
  final VoidCallback onTap;

  const _LocationOption({
    required this.location,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.location_on, color: Color(0xFF00D9A3)),
      title: Text(location),
      onTap: onTap,
    );
  }
}

/// Loading widget cho header
class _LoadingHeader extends StatelessWidget {
  const _LoadingHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00D9A3), Color(0xFF00B8D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}

/// Error widget cho header
class _ErrorHeader extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorHeader({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00D9A3), Color(0xFF00B8D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 48),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onRetry,
            child: const Text(
              'Thử lại',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

/// Loading widget cho stats
class _LoadingStats extends StatelessWidget {
  const _LoadingStats();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

/// Loading widget cho settings
class _LoadingSettings extends StatelessWidget {
  const _LoadingSettings();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

/// Error widget cho settings
class _ErrorSection extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorSection({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onRetry,
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}

/// Loading widget cho location
class _LoadingLocation extends StatelessWidget {
  const _LoadingLocation();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

