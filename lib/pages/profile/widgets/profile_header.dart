// ===================== File: profile/widgets/profile_header.dart =====================

import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import '../../../constants/text_styles.dart';
import '../../../constants/constants.dart';

class ProfileHeader extends StatelessWidget {
  final String? avatarUrl;
  final String name;
  final String role;
  final String location;
  final VoidCallback onContactPressed;

  const ProfileHeader({
    super.key,
    required this.avatarUrl,
    required this.name,
    required this.role,
    required this.location,
    required this.onContactPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xl + 26,
      ),
      decoration: const BoxDecoration(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ---------------------
          // Avatar
          // ---------------------
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.4),
                width: 3,
              ),
              color: (avatarUrl == null || avatarUrl!.isEmpty)
                  ? _avatarColor(name)
                  : null,
              image: (avatarUrl != null && avatarUrl!.isNotEmpty)
                  ? DecorationImage(
                      image: avatarUrl!.startsWith('http')
                          ? NetworkImage(avatarUrl!)
                          : AssetImage(avatarUrl!) as ImageProvider,
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: (avatarUrl == null || avatarUrl!.isEmpty)
                ? _buildInitialAvatar(name)
                : null,
          ),

          const SizedBox(height: AppSpacing.md),

          // ---------------------
          // Name
          // ---------------------
          Text(
            name,
            style: AppTextStyles.headline.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),

          // ---------------------
          // Role
          // ---------------------
          if (role.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                role,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          const SizedBox(height: 4),

          // ---------------------
          // Location
          // ---------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (location.isNotEmpty)
                Text(
                  location,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              if (location.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    "•",
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ),
              GestureDetector(
                onTap: onContactPressed,
                child: Text(
                  "Contact Info",
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _buildInitialAvatar(String name) {
  final initials = _getInitials(name);

  return Center(
    child: Text(
      initials,
      style: AppTextStyles.headline.copyWith(
        color: Colors.white,
        fontSize: 28,
      ),
    ),
  );
}

String _getInitials(String name) {
  final parts = name.trim().split(" ");
  final first = parts.isNotEmpty ? parts[0][0] : '';
  final second = parts.length > 1 ? parts[1][0] : '';
  return (first + second).toUpperCase();
}

Color _avatarColor(String seed) {
  final colors = [
    AppColors.cinnabar,
    AppColors.accentWinePlum,
    AppColors.accentRoyalPlum,
    AppColors.stormyTeal,
    AppColors.accentCeladon,
    AppColors.accentSpicyOrange,
    AppColors.honeyBronze,
  ];
  final index = seed.codeUnits.fold(0, (a, b) => a + b) % colors.length;
  return colors[index];
}
