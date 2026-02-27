import 'package:flutter/material.dart';
import 'package:interview_project/constants/constants.dart';

/// ===============================================================
/// PlayerAvatarWidget
/// ---------------------------------------------------------------
/// - Sadece avatar + username gösterir.
/// - Layout bilgisi içermez.
/// - Minimal ama hafif animasyonlu.
/// ===============================================================
class PlayerAvatarWidget extends StatelessWidget {
  final String username;
  final String? avatarAsset;
  final bool highlight;

  const PlayerAvatarWidget({
    super.key,
    required this.username,
    this.avatarAsset,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: AppDurations.normal,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: highlight
                ? const LinearGradient(
                    colors: [
                      AppColors.primaryAccent,
                      AppColors.primary,
                    ],
                  )
                : null,
          ),
          child: CircleAvatar(
            radius: 38,
            backgroundColor: Colors.white.withOpacity(0.9),
            backgroundImage:
                avatarAsset != null ? AssetImage(avatarAsset!) : null,
            child: avatarAsset == null
                ? Text(
                    username.isNotEmpty
                        ? username.substring(0, 1).toUpperCase()
                        : '?',
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.primary,
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          username,
          style: AppTextStyles.bodyStrong.copyWith(
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
