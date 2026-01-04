import 'package:flutter/material.dart';
import '../../domain/models/user_profile_model.dart';

/// Header với avatar và thông tin user
class ProfileHeader extends StatelessWidget {
  final UserProfileModel profile;

  const ProfileHeader({
    super.key,
    required this.profile,
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
          // Avatar Circle
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: profile.avatarUrl != null
                  ? ClipOval(
                      child: Image.network(
                        profile.avatarUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Text(
                      profile.avatarInitials ?? 'U',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00D9A3),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            profile.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),

          // Email
          Text(
            profile.email,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),

          // Membership badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Text(
              profile.membershipBadge,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
