// ===================== File: ep_avatar_section.dart =====================
// Purpose:
// Displays avatar + helper text (top section)
//
// Notes:
// - Reuses ProfileEditAvatar
// - Centered layout
// =======================================================================

import 'package:flutter/material.dart';
import '../../../../constants/constants.dart';
import '../profile_edit_avatar.dart';


class EpAvatarSection extends StatelessWidget {
  const EpAvatarSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ProfileEditAvatar(),
        const SizedBox(height: AppSpacing.sm),
        Text(
          "Tap to change photo or choose avatar",
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
