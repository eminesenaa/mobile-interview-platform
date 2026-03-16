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
          child: ClipOval(
            child: _buildAvatarImage(),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          username.trim().isNotEmpty ? username : 'Player',
          style: AppTextStyles.bodyStrong.copyWith(
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarImage() {
    final bool hasAvatar = avatarAsset != null && avatarAsset!.trim().isNotEmpty;
    if (!hasAvatar) {
      return _buildFallback();
    }

    final isNetwork = avatarAsset!.startsWith('http');
    if (isNetwork) {
      return Image.network(
        avatarAsset!,
        width: 76,
        height: 76,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    } else {
      return Image.asset(
        avatarAsset!,
        width: 76,
        height: 76,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    }
  }

  Widget _buildFallback() {
    final String initial = (username.trim().isNotEmpty)
        ? username.trim().substring(0, 1).toUpperCase()
        : '?';

    return Container(
      width: 76,
      height: 76,
      color: Colors.white.withOpacity(0.9),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: AppTextStyles.title.copyWith(
          color: AppColors.primary,
        ),
      ),
    );
  }
}
