// ===================== File: np_header_section.dart =====================
// Purpose:
// Profile header section (avatar + name + role + location)
//
// Notes:
// - Avatar is reused from existing widget
// - Center aligned clean layout
// ======================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../constants/constants.dart';
import '../profile_edit_avatar.dart';

class NpHeaderSection extends StatelessWidget {
  final String name;
  final String role;
  final String? location;
  final String? avatarPath;

  const NpHeaderSection({
    super.key,
    required this.name,
    required this.role,
    this.location,
    this.avatarPath,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ================= AVATAR =================
        CircleAvatar(
          radius: 40,
          backgroundImage:
          (avatarPath != null && avatarPath!.isNotEmpty)
              ? (avatarPath!.startsWith('http')
              ? NetworkImage(avatarPath!)
              : AssetImage(avatarPath!) as ImageProvider)
              : const AssetImage("assets/avatars/avatar1.jpg"),
        ),

        const SizedBox(height: AppSpacing.md),

        // ================= NAME =================
        Text(
          name,
          style: AppTextStyles.headline.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: AppSpacing.xs),

        // ================= ROLE =================
        Text(
          role,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),

        // ================= LOCATION =================
        if (location != null && location!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                PhosphorIcons.mapPin(),
                size: 14,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                location!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
