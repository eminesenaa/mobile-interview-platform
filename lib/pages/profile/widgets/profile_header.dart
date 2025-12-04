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
          CircleAvatar(
            radius: 48,
            backgroundColor: AppColors.surface,
            backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                ? NetworkImage(avatarUrl!)
                : null,
            child: (avatarUrl == null || avatarUrl!.isEmpty)
                ? const Icon(Icons.person, size: 48, color: AppColors.textMuted)
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
